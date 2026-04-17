import 'orbit_entities.dart';

class Round {
  const Round({
    required this.id,
    required this.roundNumber,
    required this.players,
    required this.bench,
    required this.teamA,
    required this.teamB,
    required this.serveState,
    required this.score,
    required this.status,
    this.pairingReason,
  });
  final String id;
  final int roundNumber;
  final List<Player> players;
  final List<Player> bench;
  final Team teamA;
  final Team teamB;
  final ServeState serveState;
  final Score score;
  final RoundStatus status;
  final String? pairingReason;

  Round copyWith({
    String? id,
    int? roundNumber,
    List<Player>? players,
    List<Player>? bench,
    Team? teamA,
    Team? teamB,
    ServeState? serveState,
    Score? score,
    RoundStatus? status,
    String? pairingReason,
  }) => Round(
    id: id ?? this.id,
    roundNumber: roundNumber ?? this.roundNumber,
    players: players ?? this.players,
    bench: bench ?? this.bench,
    teamA: teamA ?? this.teamA,
    teamB: teamB ?? this.teamB,
    serveState: serveState ?? this.serveState,
    score: score ?? this.score,
    status: status ?? this.status,
    pairingReason: pairingReason ?? this.pairingReason,
  );

  bool get isComplete =>
      score.teamAPoints >= score.targetPoints ||
      score.teamBPoints >= score.targetPoints ||
      score.status == ScoreStatus.completed;
}

class Player {
  const Player({
    required this.id,
    required this.displayName,
    required this.avatar,
    required this.isGuest,
    this.deviceId,
    this.skillLevel,
    this.position = PlayerPosition.center,
    this.totalPoints = 0,
    this.roundsWon = 0,
    this.matchesPlayed = 0,
    this.benchCount = 0,
  });
  final String id;
  final String displayName;
  final PlayerAvatar avatar;
  final bool isGuest;
  final String? deviceId;
  final int? skillLevel;
  final PlayerPosition position;
  final int totalPoints;
  final int roundsWon;
  final int matchesPlayed;
  final int benchCount;

  Player copyWith({
    String? id,
    String? displayName,
    PlayerAvatar? avatar,
    bool? isGuest,
    String? deviceId,
    int? skillLevel,
    PlayerPosition? position,
    int? totalPoints,
    int? roundsWon,
    int? matchesPlayed,
    int? benchCount,
  }) => Player(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    avatar: avatar ?? this.avatar,
    isGuest: isGuest ?? this.isGuest,
    deviceId: deviceId ?? this.deviceId,
    skillLevel: skillLevel ?? this.skillLevel,
    position: position ?? this.position,
    totalPoints: totalPoints ?? this.totalPoints,
    roundsWon: roundsWon ?? this.roundsWon,
    matchesPlayed: matchesPlayed ?? this.matchesPlayed,
    benchCount: benchCount ?? this.benchCount,
  );
}

enum PlayerPosition {
  teamAPlayer1,
  teamAPlayer2,
  teamBPlayer1,
  teamBPlayer2,
  center,
  bench,
}

class Team {
  const Team({
    required this.players,
    required this.side,
    this.isServing = false,
  });
  final List<Player> players;
  final TeamSide side;
  final bool isServing;

  Team copyWith({List<Player>? players, TeamSide? side, bool? isServing}) =>
      Team(
        players: players ?? this.players,
        side: side ?? this.side,
        isServing: isServing ?? this.isServing,
      );
}

enum TeamSide { a, b }

enum RoundStatus { pending, active, completed }

class Score {
  const Score({
    this.teamAPoints = 0,
    this.teamBPoints = 0,
    this.targetPoints = 12,
    this.status = ScoreStatus.active,
    this.timeline = const [],
    this.serveCount = 0,
  });
  final int teamAPoints;
  final int teamBPoints;
  final int targetPoints;
  final ScoreStatus status;
  final List<ScoreEvent> timeline;
  final int serveCount;

  Score copyWith({
    int? teamAPoints,
    int? teamBPoints,
    int? targetPoints,
    ScoreStatus? status,
    List<ScoreEvent>? timeline,
    int? serveCount,
  }) => Score(
    teamAPoints: teamAPoints ?? this.teamAPoints,
    teamBPoints: teamBPoints ?? this.teamBPoints,
    targetPoints: targetPoints ?? this.targetPoints,
    status: status ?? this.status,
    timeline: timeline ?? this.timeline,
    serveCount: serveCount ?? this.serveCount,
  );
}

class ScoreEvent {
  const ScoreEvent({
    required this.playerId,
    required this.scoringTeam,
    required this.teamAPointsBefore,
    required this.teamBPointsBefore,
    required this.teamAPointsAfter,
    required this.teamBPointsAfter,
    required this.timestamp,
    this.wasUndone = false,
  });
  final String playerId;
  final TeamSide scoringTeam;
  final int teamAPointsBefore;
  final int teamBPointsBefore;
  final int teamAPointsAfter;
  final int teamBPointsAfter;
  final DateTime timestamp;
  final bool wasUndone;
}

enum ScoreStatus { active, completed }

class ServeState {
  const ServeState({
    this.currentServer,
    this.currentReturner,
    this.pointsServedThisTurn = 0,
    this.currentServePosition = ServePosition.right,
    this.isFirstServe = true,
  });
  final Player? currentServer;
  final Player? currentReturner;
  final int pointsServedThisTurn;
  final ServePosition currentServePosition;
  final bool isFirstServe;

  ServeState copyWith({
    Player? currentServer,
    Player? currentReturner,
    int? pointsServedThisTurn,
    ServePosition? currentServePosition,
    bool? isFirstServe,
  }) => ServeState(
    currentServer: currentServer ?? this.currentServer,
    currentReturner: currentReturner ?? this.currentReturner,
    pointsServedThisTurn: pointsServedThisTurn ?? this.pointsServedThisTurn,
    currentServePosition: currentServePosition ?? this.currentServePosition,
    isFirstServe: isFirstServe ?? this.isFirstServe,
  );
}

enum ServePosition { left, right }
