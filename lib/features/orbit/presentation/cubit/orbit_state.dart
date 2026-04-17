import 'package:equatable/equatable.dart';

enum OrbitStatus {
  initial,
  loading,
  ready,
  roundInProgress,
  roundComplete,
  sessionComplete,
  error,
}

class OrbitState extends Equatable {
  const OrbitState({
    this.status = OrbitStatus.initial,
    this.mode = 'orbit',
    this.targetPoints = 12,
    this.currentRound = 0,
    this.teamAScore = 0,
    this.teamBScore = 0,
    this.teamAPlayer1 = '',
    this.teamAPlayer2 = '',
    this.teamBPlayer1 = '',
    this.teamBPlayer2 = '',
    this.waitingPlayers = const [],
    this.serverIndex = 0,
    this.scoreHistory = const [],
    this.leaderboard = const [],
    this.errorMessage,
  });

  final OrbitStatus status;
  final String mode;
  final int targetPoints;
  final int currentRound;
  final int teamAScore;
  final int teamBScore;
  final String teamAPlayer1;
  final String teamAPlayer2;
  final String teamBPlayer1;
  final String teamBPlayer2;
  final List<String> waitingPlayers;
  final int serverIndex;
  final List<ScoreEvent> scoreHistory;
  final List<LeaderboardEntry> leaderboard;
  final String? errorMessage;

  bool get canUndo =>
      scoreHistory.isNotEmpty && status == OrbitStatus.roundInProgress;

  bool get isRoundComplete =>
      teamAScore >= targetPoints || teamBScore >= targetPoints;

  OrbitState copyWith({
    OrbitStatus? status,
    String? mode,
    int? targetPoints,
    int? currentRound,
    int? teamAScore,
    int? teamBScore,
    String? teamAPlayer1,
    String? teamAPlayer2,
    String? teamBPlayer1,
    String? teamBPlayer2,
    List<String>? waitingPlayers,
    int? serverIndex,
    List<ScoreEvent>? scoreHistory,
    List<LeaderboardEntry>? leaderboard,
    String? errorMessage,
  }) => OrbitState(
    status: status ?? this.status,
    mode: mode ?? this.mode,
    targetPoints: targetPoints ?? this.targetPoints,
    currentRound: currentRound ?? this.currentRound,
    teamAScore: teamAScore ?? this.teamAScore,
    teamBScore: teamBScore ?? this.teamBScore,
    teamAPlayer1: teamAPlayer1 ?? this.teamAPlayer1,
    teamAPlayer2: teamAPlayer2 ?? this.teamAPlayer2,
    teamBPlayer1: teamBPlayer1 ?? this.teamBPlayer1,
    teamBPlayer2: teamBPlayer2 ?? this.teamBPlayer2,
    waitingPlayers: waitingPlayers ?? this.waitingPlayers,
    serverIndex: serverIndex ?? this.serverIndex,
    scoreHistory: scoreHistory ?? this.scoreHistory,
    leaderboard: leaderboard ?? this.leaderboard,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [
    status,
    mode,
    targetPoints,
    currentRound,
    teamAScore,
    teamBScore,
    teamAPlayer1,
    teamAPlayer2,
    teamBPlayer1,
    teamBPlayer2,
    waitingPlayers,
    serverIndex,
    scoreHistory,
    leaderboard,
    errorMessage,
  ];
}

class ScoreEvent extends Equatable {
  const ScoreEvent({required this.isTeamA, required this.timestamp});

  final bool isTeamA;
  final DateTime timestamp;

  @override
  List<Object?> get props => [isTeamA, timestamp];
}

class LeaderboardEntry extends Equatable {
  const LeaderboardEntry({
    required this.playerName,
    required this.totalPoints,
    required this.wins,
    required this.matchesPlayed,
  });

  final String playerName;
  final int totalPoints;
  final int wins;
  final int matchesPlayed;

  @override
  List<Object?> get props => [playerName, totalPoints, wins, matchesPlayed];
}
