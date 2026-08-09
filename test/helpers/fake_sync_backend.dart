import 'dart:async';

import 'package:tcg_tracker/data/sync/sync_backend.dart';

/// An in-memory stand-in for Supabase.
///
/// It keeps the one rule the real server enforces — a push is accepted only
/// when the caller names the revision the cloud is actually at — because that
/// rule is what every conflict test is about.
class FakeSyncBackend implements SyncBackend {
  final _accounts = StreamController<SyncAccount?>.broadcast();

  SyncAccount? _account;
  Map<String, dynamic>? _payload;
  int _revision = 0;
  DateTime _updatedAt = DateTime(2026, 1, 1);
  String? _device;

  /// Pushes accepted so far, so a test can tell "synced" from "did nothing".
  int pushes = 0;

  /// Thrown by the next call, then cleared.
  Object? nextFailure;

  /// Snapshot the server would hand back, or null when nothing was ever
  /// pushed.
  Map<String, dynamic>? get storedPayload => _payload;

  int get storedRevision => _revision;

  /// Puts a snapshot in the cloud as if another device had pushed it.
  void seedCloud(
    Map<String, dynamic> payload, {
    int revision = 1,
    String device = 'iOS',
    DateTime? updatedAt,
  }) {
    _payload = payload;
    _revision = revision;
    _device = device;
    _updatedAt = updatedAt ?? DateTime(2026, 6, 1, 12);
  }

  void emitSignedIn(SyncAccount account) {
    _account = account;
    _accounts.add(account);
  }

  Future<void> dispose() => _accounts.close();

  @override
  SyncAccount? get account => _account;

  @override
  Stream<SyncAccount?> get accountChanges => _accounts.stream;

  @override
  Future<SyncAccount> signIn({
    required String email,
    required String password,
  }) async {
    _check();
    final account = SyncAccount(id: 'user-$email', email: email);
    emitSignedIn(account);
    return account;
  }

  @override
  Future<SyncAccount> signUp({
    required String email,
    required String password,
  }) => signIn(email: email, password: password);

  @override
  Future<void> signOut() async {
    _check();
    _account = null;
    _accounts.add(null);
  }

  @override
  Future<void> sendPasswordReset(String email) async => _check();

  @override
  Future<RemoteSnapshotMeta?> fetchMeta() async {
    _check();
    if (_payload == null) return null;
    return RemoteSnapshotMeta(
      revision: _revision,
      updatedAt: _updatedAt,
      device: _device,
    );
  }

  @override
  Future<RemoteSnapshot?> fetchSnapshot() async {
    final meta = await fetchMeta();
    if (meta == null) return null;
    return RemoteSnapshot(meta: meta, payload: _payload!);
  }

  @override
  Future<int> push({
    required Map<String, dynamic> payload,
    required int expectedRevision,
    String? device,
  }) async {
    _check();

    if (expectedRevision != _revision) {
      throw SyncConflictException(
        'cloud is at $_revision, expected $expectedRevision',
      );
    }

    _payload = payload;
    _revision += 1;
    _device = device;
    _updatedAt = DateTime(2026, 6, 2, 12);
    pushes += 1;
    return _revision;
  }

  void _check() {
    final failure = nextFailure;
    if (failure == null) return;
    nextFailure = null;
    throw failure;
  }
}
