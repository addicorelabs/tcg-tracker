import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'sync_backend.dart';

/// [SyncBackend] on top of Supabase Auth and a single `snapshots` table.
///
/// The SQL this expects — table, row level security and the `push_snapshot`
/// function — lives in `docs/supabase/schema.sql`.
class SupabaseSyncBackend implements SyncBackend {
  SupabaseSyncBackend(this._client);

  SupabaseSyncBackend.instance() : _client = sb.Supabase.instance.client;

  final sb.SupabaseClient _client;

  static const _table = 'snapshots';
  static const _pushFunction = 'push_snapshot';

  /// Postgres serialization-failure code, which `push_snapshot` reuses to say
  /// "someone else got here first".
  static const _conflictCode = '40001';

  @override
  SyncAccount? get account => _accountOf(_client.auth.currentUser);

  @override
  Stream<SyncAccount?> get accountChanges => _client.auth.onAuthStateChange.map(
    (state) => _accountOf(state.session?.user),
  );

  SyncAccount? _accountOf(sb.User? user) {
    if (user == null) return null;
    return SyncAccount(id: user.id, email: user.email ?? '');
  }

  @override
  Future<SyncAccount> signIn({
    required String email,
    required String password,
  }) async {
    return _guard(() async {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final account = _accountOf(response.user);
      if (account == null) throw SyncException('Sign in returned no user');
      return account;
    });
  }

  @override
  Future<SyncAccount> signUp({
    required String email,
    required String password,
  }) async {
    return _guard(() async {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
      );

      // A project with email confirmation on — the Supabase default — creates
      // the user but no session. Reporting that as success would leave the
      // user staring at a sync that never starts.
      if (response.session == null) {
        throw EmailConfirmationRequired(email.trim());
      }

      final account = _accountOf(response.user);
      if (account == null) throw SyncException('Sign up returned no user');
      return account;
    });
  }

  @override
  Future<void> signOut() => _guard(() => _client.auth.signOut());

  @override
  Future<void> sendPasswordReset(String email) =>
      _guard(() => _client.auth.resetPasswordForEmail(email.trim()));

  @override
  Future<RemoteSnapshotMeta?> fetchMeta() {
    return _guard(() async {
      final row = await _client
          .from(_table)
          .select('revision, updated_at, device')
          .maybeSingle();
      return row == null ? null : _metaOf(row);
    });
  }

  @override
  Future<RemoteSnapshot?> fetchSnapshot() {
    return _guard(() async {
      final row = await _client
          .from(_table)
          .select('revision, updated_at, device, payload')
          .maybeSingle();
      if (row == null) return null;

      final payload = row['payload'];
      if (payload is! Map<String, dynamic>) {
        throw SyncException('The cloud snapshot is not a backup document');
      }

      return RemoteSnapshot(meta: _metaOf(row), payload: payload);
    });
  }

  @override
  Future<int> push({
    required Map<String, dynamic> payload,
    required int expectedRevision,
    String? device,
  }) {
    return _guard(() async {
      final revision = await _client.rpc(
        _pushFunction,
        params: {
          'p_payload': payload,
          'p_expected': expectedRevision,
          'p_device': device,
        },
      );

      if (revision is! int) {
        throw SyncException('The server did not return a revision');
      }
      return revision;
    });
  }

  RemoteSnapshotMeta _metaOf(Map<String, dynamic> row) {
    return RemoteSnapshotMeta(
      revision: (row['revision'] as num).toInt(),
      updatedAt: DateTime.parse(row['updated_at'] as String).toLocal(),
      device: row['device'] as String?,
    );
  }

  /// Turns every way Supabase can fail into a [SyncException].
  ///
  /// Without this the UI would have to know about three unrelated exception
  /// types, and an offline device would surface a raw socket error where a
  /// sentence belongs.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on SyncException {
      rethrow;
    } on sb.AuthException catch (error) {
      throw SyncException(error.message);
    } on sb.PostgrestException catch (error) {
      if (error.code == _conflictCode) {
        // No revision attached: the caller re-reads it, rather than parsing a
        // number back out of an error message written by Postgres.
        throw SyncConflictException(error.message);
      }
      throw SyncException(error.message);
    } catch (error) {
      throw SyncException(error.toString());
    }
  }
}
