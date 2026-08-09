import 'package:flutter/foundation.dart';

import 'sync_backend.dart';

/// The cloud and this device both moved since they last agreed.
///
/// Held as state rather than thrown at the UI because resolving it is a
/// decision, not an error: one of the two copies is about to be discarded and
/// only the user knows which.
@immutable
class SyncConflict {
  const SyncConflict({
    required this.remoteRevision,
    required this.remoteUpdatedAt,
    this.remoteDevice,
  });

  final int remoteRevision;
  final DateTime remoteUpdatedAt;
  final String? remoteDevice;
}

/// Everything the account screen needs to draw itself.
@immutable
class SyncStatus {
  const SyncStatus({
    this.configured = false,
    this.account,
    this.busy = false,
    this.dirty = false,
    this.autoSync = true,
    this.baseRevision = 0,
    this.lastSyncAt,
    this.error,
    this.conflict,
  });

  /// False when the build carries no Supabase credentials, which makes every
  /// other field meaningless.
  final bool configured;

  final SyncAccount? account;

  /// A sync is running. Nothing else may start one meanwhile.
  final bool busy;

  /// Local data changed since the last successful push.
  final bool dirty;

  final bool autoSync;

  /// The cloud revision this device's data is based on. Zero means this device
  /// has never completed a sync with the account it is signed into.
  final int baseRevision;

  final DateTime? lastSyncAt;

  /// Last failure, kept until the next attempt so it does not vanish with a
  /// snackbar the user was not looking at.
  final String? error;

  final SyncConflict? conflict;

  bool get signedIn => account != null;

  /// Nothing left to send and nothing waiting to be resolved.
  bool get upToDate =>
      signedIn && !dirty && conflict == null && error == null && !busy;

  SyncStatus copyWith({
    bool? configured,
    SyncAccount? account,
    bool clearAccount = false,
    bool? busy,
    bool? dirty,
    bool? autoSync,
    int? baseRevision,
    DateTime? lastSyncAt,
    bool clearLastSyncAt = false,
    String? error,
    bool clearError = false,
    SyncConflict? conflict,
    bool clearConflict = false,
  }) {
    return SyncStatus(
      configured: configured ?? this.configured,
      account: clearAccount ? null : (account ?? this.account),
      busy: busy ?? this.busy,
      dirty: dirty ?? this.dirty,
      autoSync: autoSync ?? this.autoSync,
      baseRevision: baseRevision ?? this.baseRevision,
      lastSyncAt: clearLastSyncAt ? null : (lastSyncAt ?? this.lastSyncAt),
      error: clearError ? null : (error ?? this.error),
      conflict: clearConflict ? null : (conflict ?? this.conflict),
    );
  }
}
