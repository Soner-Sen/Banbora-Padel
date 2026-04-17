import '../../domain/entities/entities.dart';

enum OrbitSessionStatus {
  initial,
  lobby,
  active,
  roundComplete,
  sessionComplete,
  error,
}

class OrbitSessionState {
  const OrbitSessionState({
    this.status = OrbitSessionStatus.initial,
    this.session,
    this.currentRound,
    this.leaderboard = const [],
    this.participants = const [],
    this.joinCode,
    this.sessionId,
    this.hostDeviceId,
    this.targetPoints = 12,
    this.canUndo = false,
    this.lastPairingReason,
    this.errorMessage,
  });
  final OrbitSessionStatus status;
  final Session? session;
  final Round? currentRound;
  final List<LeaderboardEntry> leaderboard;
  final List<Participant> participants;
  final String? joinCode;
  final String? sessionId;
  final String? hostDeviceId;
  final int targetPoints;
  final bool canUndo;
  final String? lastPairingReason;
  final String? errorMessage;

  OrbitSessionState copyWith({
    OrbitSessionStatus? status,
    Session? session,
    Round? currentRound,
    List<LeaderboardEntry>? leaderboard,
    List<Participant>? participants,
    String? joinCode,
    String? sessionId,
    String? hostDeviceId,
    int? targetPoints,
    bool? canUndo,
    String? lastPairingReason,
    String? errorMessage,
  }) => OrbitSessionState(
    status: status ?? this.status,
    session: session ?? this.session,
    currentRound: currentRound ?? this.currentRound,
    leaderboard: leaderboard ?? this.leaderboard,
    participants: participants ?? this.participants,
    joinCode: joinCode ?? this.joinCode,
    sessionId: sessionId ?? this.sessionId,
    hostDeviceId: hostDeviceId ?? this.hostDeviceId,
    targetPoints: targetPoints ?? this.targetPoints,
    canUndo: canUndo ?? this.canUndo,
    lastPairingReason: lastPairingReason ?? this.lastPairingReason,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  bool get hasMinimumPlayers => participants.length >= 4;
  bool get isLobbyActive => status == OrbitSessionStatus.lobby;
  bool get isSessionActive => status == OrbitSessionStatus.active;
  bool get isRoundInProgress =>
      currentRound != null && !currentRound!.isComplete;
}
