/// Where sync currently stands, for the Settings row.
enum SyncPhase { off, signedOut, idle, running, failed }

class SyncState {
  const SyncState({
    required this.phase,
    this.lastSyncedAt,
    this.message,
    this.recordCount = 0,
    this.isAnonymous = true,
    this.email,
  });

  static const off = SyncState(phase: SyncPhase.off);

  final SyncPhase phase;
  final DateTime? lastSyncedAt;

  /// Why the last attempt failed, in plain language. Never a stack trace.
  final String? message;

  final int recordCount;

  /// Anonymous accounts live and die with the app install, so the UI has to
  /// be able to say that out loud and offer to link a real identity.
  final bool isAnonymous;

  /// The linked Google account, once there is one.
  final String? email;

  SyncState copyWith({
    SyncPhase? phase,
    DateTime? lastSyncedAt,
    String? message,
    int? recordCount,
    bool? isAnonymous,
  }) => SyncState(
    phase: phase ?? this.phase,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    message: message,
    recordCount: recordCount ?? this.recordCount,
    isAnonymous: isAnonymous ?? this.isAnonymous,
  );
}
