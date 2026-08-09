import 'package:flutter/foundation.dart';

/// The signed-in user, reduced to what the app actually shows.
@immutable
class SyncAccount {
  const SyncAccount({required this.id, required this.email});

  final String id;
  final String email;

  @override
  bool operator ==(Object other) =>
      other is SyncAccount && other.id == id && other.email == email;

  @override
  int get hashCode => Object.hash(id, email);
}

/// What the cloud holds, without the payload.
///
/// Fetched on its own because deciding whether a sync is needed must not cost
/// the download of an entire database.
@immutable
class RemoteSnapshotMeta {
  const RemoteSnapshotMeta({
    required this.revision,
    required this.updatedAt,
    this.device,
  });

  /// Monotonic counter, bumped by the server on every accepted push.
  final int revision;
  final DateTime updatedAt;

  /// Free-text label of the device that pushed it, shown when resolving a
  /// conflict so "keep the cloud copy" is an informed choice.
  final String? device;
}

/// A remote snapshot together with the backup document it carries.
@immutable
class RemoteSnapshot {
  const RemoteSnapshot({required this.meta, required this.payload});

  final RemoteSnapshotMeta meta;
  final Map<String, dynamic> payload;
}

/// Anything the backend refuses to do, with a message fit to show the user.
class SyncException implements Exception {
  SyncException(this.message);

  final String message;

  @override
  String toString() => 'SyncException: $message';
}

/// The cloud moved on since this device last synced.
///
/// Raised by a push whose expected revision no longer matches, which is the
/// only moment two devices can be found to disagree. Resolving it is a user
/// decision, never an automatic one.
class SyncConflictException extends SyncException {
  SyncConflictException(super.message, {this.remoteRevision});

  /// The revision the cloud is really at, when the backend can say so. Null
  /// leaves the caller to re-read it, which it has to be able to do anyway:
  /// the number could have moved again between the refusal and the retry.
  final int? remoteRevision;
}

/// Sign-up that needs the user to click a link before the account works.
class EmailConfirmationRequired extends SyncException {
  EmailConfirmationRequired(this.email) : super('Confirm $email to continue');

  final String email;
}

/// Everything the app needs from the server, with no Supabase types in sight.
///
/// The interface exists so the sync logic can be tested against a fake: the
/// real implementation opens sockets, and a widget test must not.
abstract interface class SyncBackend {
  /// Emits on every sign-in and sign-out, starting with the current state.
  Stream<SyncAccount?> get accountChanges;

  SyncAccount? get account;

  Future<SyncAccount> signIn({required String email, required String password});

  /// Throws [EmailConfirmationRequired] when the project has confirmations on,
  /// which is the Supabase default.
  Future<SyncAccount> signUp({required String email, required String password});

  Future<void> signOut();

  Future<void> sendPasswordReset(String email);

  Future<RemoteSnapshotMeta?> fetchMeta();

  Future<RemoteSnapshot?> fetchSnapshot();

  /// Uploads [payload] and returns the new revision.
  ///
  /// [expectedRevision] is what this device believes the cloud is at — 0 when
  /// nothing has ever been pushed. The server compares before writing and
  /// throws [SyncConflictException] on a mismatch, so two devices pushing at
  /// once cannot silently overwrite one another.
  Future<int> push({
    required Map<String, dynamic> payload,
    required int expectedRevision,
    String? device,
  });
}
