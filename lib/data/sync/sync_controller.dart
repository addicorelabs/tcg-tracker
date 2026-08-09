import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/settings/providers/app_settings_provider.dart';
import '../backup/backup_service.dart';
import '../db/app_database.dart';
import '../db/database_provider.dart';
import 'sync_backend.dart';
import 'sync_config.dart';
import 'sync_status.dart';

/// The backend the app syncs through, or null when this build has no Supabase
/// credentials.
///
/// Overridden by tests with a fake. Nothing else in the app constructs a
/// backend, so no code path can reach the network by accident.
final syncBackendProvider = Provider<SyncBackend?>((ref) => null);

/// How long local changes settle before an automatic push.
///
/// Long enough that filling in a round is one upload rather than six, short
/// enough that closing the browser straight after a match does not lose it.
/// A provider so tests can shorten it instead of waiting out five real seconds.
final syncPushDelayProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 5),
);

/// Sync between the local database and the account's cloud snapshot.
///
/// **What is synced is the whole database, as one document.** Not row by row:
/// this app is one person's tournament history, a few hundred rows, and a
/// per-row merge would cost a schema of tombstones and cursors to solve a
/// problem the user does not have. The price is stated plainly in the account
/// screen — edit on two devices without syncing in between and one of the two
/// copies is discarded, by the user's choice, never silently.
///
/// The counter that makes this safe is [SyncStatus.baseRevision]: the cloud
/// revision this device's data came from. A push is accepted only when the
/// cloud is still at that revision, so a device that has not seen someone
/// else's changes cannot overwrite them.
class SyncController extends Notifier<SyncStatus> {
  static const _revisionKey = 'sync.baseRevision';
  static const _dirtyKey = 'sync.dirty';
  static const _lastSyncKey = 'sync.lastSyncAt';
  static const _autoSyncKey = 'sync.autoSync';
  static const _accountKey = 'sync.accountId';

  Timer? _pushTimer;
  StreamSubscription<void>? _accountSubscription;
  StreamSubscription<void>? _changeSubscription;

  /// True while a pulled snapshot is being written into the local database.
  ///
  /// Without it the writes of a pull would look exactly like the user's own
  /// edits, mark the device dirty, and push straight back what it just
  /// downloaded — forever.
  bool _applyingRemote = false;

  /// Set when the provider is torn down. Every await here outlives something,
  /// and touching a disposed container throws.
  bool _disposed = false;

  SyncBackend? get _backend => ref.read(syncBackendProvider);
  AppDatabase get _db => ref.read(appDatabaseProvider);
  BackupService get _backup => ref.read(backupServiceProvider);
  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  SyncStatus build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final backend = ref.watch(syncBackendProvider);

    ref.onDispose(() {
      _disposed = true;
      _pushTimer?.cancel();
      _accountSubscription?.cancel();
      _changeSubscription?.cancel();
    });

    if (backend == null) {
      return SyncStatus(configured: SyncConfig.isConfigured);
    }

    _accountSubscription = backend.accountChanges.listen(_onAccountChanged);
    unawaited(_watchLocalChanges(ref.watch(appDatabaseProvider)));

    final account = backend.account;
    return SyncStatus(
      configured: true,
      account: account,
      autoSync: prefs.getBool(_autoSyncKey) ?? true,
      dirty: account == null ? false : prefs.getBool(_dirtyKey) ?? false,
      baseRevision: account == null ? 0 : _storedRevisionFor(account),
      lastSyncAt: DateTime.tryParse(prefs.getString(_lastSyncKey) ?? ''),
    );
  }

  /// Watches every table for writes, once the database has finished opening.
  ///
  /// Any write means this device holds something the cloud does not. Listening
  /// to the database rather than to each repository means a feature added
  /// later is synced without anyone having to remember to say so.
  ///
  /// The wait matters: opening runs the migration, the schema repair and the
  /// seed, and those writes are the app installing itself, not the user's
  /// work. Counting them would have every cold start upload a copy of a
  /// database nobody touched.
  Future<void> _watchLocalChanges(AppDatabase db) async {
    await db.customSelect('SELECT 1').getSingle();
    await _drainUpdates();
    if (_disposed) return;
    _changeSubscription = db.tableUpdates().listen((_) => _onLocalChange());
  }

  /// Lets drift deliver the notifications for writes already made.
  ///
  /// They arrive a turn late, so anything that has to be invisible to the
  /// change listener has to outlast its own writes by one turn of the loop.
  Future<void> _drainUpdates() => Future<void>.delayed(Duration.zero);

  /// The stored revision, but only if it belongs to this account.
  ///
  /// Signing into a different account on the same device makes the old number
  /// a lie, and a lie here is what lets one account's data land in another's.
  int _storedRevisionFor(SyncAccount account) {
    if (_prefs.getString(_accountKey) != account.id) return 0;
    return _prefs.getInt(_revisionKey) ?? 0;
  }

  // ---------------------------------------------------------------- account

  Future<void> signIn({required String email, required String password}) {
    return _run(() async {
      await _requireBackend().signIn(email: email, password: password);
      await _syncOnSignIn();
    });
  }

  Future<void> signUp({required String email, required String password}) {
    return _run(() async {
      await _requireBackend().signUp(email: email, password: password);
      await _syncOnSignIn();
    });
  }

  Future<void> sendPasswordReset(String email) {
    return _run(() => _requireBackend().sendPasswordReset(email));
  }

  /// Signs out without touching the local database.
  ///
  /// Deleting the data would be the one irreversible thing this screen could
  /// do, and "sign out" never means "erase my decks".
  Future<void> signOut() => _run(() => _requireBackend().signOut());

  Future<void> setAutoSync(bool enabled) async {
    state = state.copyWith(autoSync: enabled);
    await _prefs.setBool(_autoSyncKey, enabled);
    if (enabled && state.dirty) unawaited(syncNow());
  }

  void _onAccountChanged(SyncAccount? account) {
    if (account == null) {
      _pushTimer?.cancel();
      state = state.copyWith(
        clearAccount: true,
        clearConflict: true,
        clearLastSyncAt: true,
        baseRevision: 0,
        dirty: false,
      );
      return;
    }

    if (account == state.account) return;

    state = state.copyWith(
      account: account,
      clearConflict: true,
      clearError: true,
      baseRevision: _storedRevisionFor(account),
      dirty: _prefs.getString(_accountKey) == account.id
          ? _prefs.getBool(_dirtyKey) ?? false
          : false,
    );

    // A session restored at startup arrives here with nothing in flight, and
    // has to sync itself. One that arrives mid sign-in does not: the sign-in
    // is already going to, and two syncs at once would leave one of them
    // silently skipped.
    if (!state.busy) unawaited(_run(_syncOnSignIn));
  }

  /// First sync after signing in.
  ///
  /// Local data that has never been pushed counts as unsynced work, even
  /// though nothing was edited in this session: without that, a device holding
  /// a season of tournaments would quietly pull the cloud over the top of it.
  Future<void> _syncOnSignIn() async {
    if (state.baseRevision == 0 && await _hasLocalData()) {
      await _setDirty(true);
    }
    await _sync();
  }

  // ------------------------------------------------------------------- sync

  /// Brings this device and the cloud together, or reports why it cannot.
  Future<void> syncNow() => _run(_sync);

  Future<void> _sync() async {
    final backend = _requireBackend();
    if (!state.signedIn) return;

    final meta = await backend.fetchMeta();

    // Nothing in the cloud yet: this device is the first, whatever it holds.
    if (meta == null) {
      await _push(expectedRevision: 0);
      return;
    }

    if (meta.revision == state.baseRevision) {
      if (state.dirty) {
        await _push(expectedRevision: state.baseRevision);
      } else {
        await _markSynced(state.baseRevision);
      }
      return;
    }

    // The cloud moved. Safe to take it wholesale only if this device has
    // nothing of its own to lose.
    if (!state.dirty) {
      await _pull();
      return;
    }

    state = state.copyWith(conflict: _conflictOf(meta));
  }

  /// Resolves a conflict by overwriting the cloud with this device.
  Future<void> resolveKeepLocal() {
    return _run(() async {
      final meta = await _requireBackend().fetchMeta();
      await _push(expectedRevision: meta?.revision ?? 0);
    });
  }

  /// Resolves a conflict by discarding this device's changes.
  Future<void> resolveKeepCloud() => _run(_pull);

  Future<void> _push({required int expectedRevision}) async {
    final backend = _requireBackend();
    final payload = await _backup.exportToJson();

    try {
      final revision = await backend.push(
        payload: payload,
        expectedRevision: expectedRevision,
        device: deviceLabel,
      );
      await _markSynced(revision);
    } on SyncConflictException {
      // Someone pushed between reading the revision and writing it. Re-read
      // rather than trust the number that was already wrong once.
      final meta = await backend.fetchMeta();
      if (meta == null) rethrow;
      state = state.copyWith(conflict: _conflictOf(meta));
    }
  }

  Future<void> _pull() async {
    final snapshot = await _requireBackend().fetchSnapshot();
    if (snapshot == null) return;

    _applyingRemote = true;
    try {
      await _backup.importFromJson(snapshot.payload);
      await _drainUpdates();
    } on BackupFormatException catch (error) {
      throw SyncException(error.message);
    } finally {
      _applyingRemote = false;
    }

    await _markSynced(snapshot.meta.revision);
  }

  SyncConflict _conflictOf(RemoteSnapshotMeta meta) {
    return SyncConflict(
      remoteRevision: meta.revision,
      remoteUpdatedAt: meta.updatedAt,
      remoteDevice: meta.device,
    );
  }

  Future<void> _markSynced(int revision) async {
    final now = DateTime.now();
    state = state.copyWith(
      baseRevision: revision,
      dirty: false,
      lastSyncAt: now,
      clearConflict: true,
      clearError: true,
    );

    await _prefs.setInt(_revisionKey, revision);
    await _prefs.setBool(_dirtyKey, false);
    await _prefs.setString(_lastSyncKey, now.toIso8601String());
    final id = state.account?.id;
    if (id != null) await _prefs.setString(_accountKey, id);
  }

  // ---------------------------------------------------------- local changes

  void _onLocalChange() {
    if (_disposed || _applyingRemote || !state.signedIn) return;

    unawaited(_setDirty(true));

    if (!state.autoSync) return;

    _pushTimer?.cancel();
    _pushTimer = Timer(ref.read(syncPushDelayProvider), () {
      // A conflict already waiting for an answer must not be papered over by
      // an automatic push: the user has not chosen yet.
      if (!_disposed && state.conflict == null) unawaited(syncNow());
    });
  }

  Future<void> _setDirty(bool dirty) async {
    if (state.dirty != dirty) state = state.copyWith(dirty: dirty);
    await _prefs.setBool(_dirtyKey, dirty);
  }

  /// Whether this device holds work of the user's own.
  ///
  /// Decks, tournaments and matches only. Opponent archetypes are deliberately
  /// left out: the app ships with a list of them, so counting them would make
  /// every fresh install look like it held data, and every first sign-in would
  /// raise a conflict instead of simply downloading the account.
  ///
  /// What that leaves unprotected is an archetype typed by hand and never
  /// played against, which a pull would discard. It costs one line to type
  /// again; the alternative costs a conflict dialog on every new device.
  Future<bool> _hasLocalData() async {
    final row = await _db
        .customSelect(
          'SELECT (SELECT COUNT(*) FROM decks)'
          ' + (SELECT COUNT(*) FROM tournaments)'
          ' + (SELECT COUNT(*) FROM matches) AS total',
        )
        .getSingle();
    return row.read<int>('total') > 0;
  }

  // ------------------------------------------------------------------ plumbing

  SyncBackend _requireBackend() {
    final backend = _backend;
    if (backend == null) throw SyncException('Sync is not configured');
    return backend;
  }

  /// Runs [action] as the one operation in flight, turning any failure into a
  /// message on the status instead of an unhandled exception.
  Future<void> _run(Future<void> Function() action) async {
    if (state.busy) return;
    state = state.copyWith(busy: true, clearError: true);
    try {
      await action();
    } on SyncException catch (error) {
      state = state.copyWith(error: error.message);
    } catch (error) {
      state = state.copyWith(error: error.toString());
    } finally {
      state = state.copyWith(busy: false);
    }
  }
}

/// Which device pushed a snapshot, shown when two of them disagree.
///
/// The platform name is not a great label, but it is one the user can read
/// without ever having been asked to name anything: on this app's devices it
/// comes out as "iOS" for the phone and "windows" for the desktop browser.
String get deviceLabel => defaultTargetPlatform.name;

final syncControllerProvider = NotifierProvider<SyncController, SyncStatus>(
  SyncController.new,
);
