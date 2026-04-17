import 'orbit_entities.dart';
import 'round.dart';

class Session {
  const Session({
    required this.id,
    required this.mode,
    required this.targetPoints,
    required this.createdAt,
    required this.hostDeviceId,
    required this.status,
    required this.participants,
    required this.rounds,
    required this.rules,
  });
  final String id;
  final String mode;
  final int targetPoints;
  final DateTime createdAt;
  final String hostDeviceId;
  final SessionStatus status;
  final List<Participant> participants;
  final List<Round> rounds;
  final SessionModeRules rules;

  Session copyWith({
    String? id,
    String? mode,
    int? targetPoints,
    DateTime? createdAt,
    String? hostDeviceId,
    SessionStatus? status,
    List<Participant>? participants,
    List<Round>? rounds,
    SessionModeRules? rules,
  }) => Session(
    id: id ?? this.id,
    mode: mode ?? this.mode,
    targetPoints: targetPoints ?? this.targetPoints,
    createdAt: createdAt ?? this.createdAt,
    hostDeviceId: hostDeviceId ?? this.hostDeviceId,
    status: status ?? this.status,
    participants: participants ?? this.participants,
    rounds: rounds ?? this.rounds,
    rules: rules ?? this.rules,
  );

  Round? get currentRound {
    if (rounds.isEmpty) {
      return null;
    }
    return rounds.last;
  }

  List<Player> get activePlayers {
    if (currentRound == null) {
      return [];
    }
    return currentRound!.players;
  }

  List<Player> get benchPlayers {
    if (currentRound == null) {
      return [];
    }
    return currentRound!.bench;
  }
}

enum SessionStatus { lobby, active, completed }

enum SessionModeRules { orbit, classic, chaosRally }

class Participant {
  const Participant({
    required this.id,
    required this.displayName,
    required this.avatar,
    required this.isGuest,
    this.deviceId,
    this.skillLevel,
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
  final int totalPoints;
  final int roundsWon;
  final int matchesPlayed;
  final int benchCount;

  Participant copyWith({
    String? id,
    String? displayName,
    PlayerAvatar? avatar,
    bool? isGuest,
    String? deviceId,
    int? skillLevel,
    int? totalPoints,
    int? roundsWon,
    int? matchesPlayed,
    int? benchCount,
  }) => Participant(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    avatar: avatar ?? this.avatar,
    isGuest: isGuest ?? this.isGuest,
    deviceId: deviceId ?? this.deviceId,
    skillLevel: skillLevel ?? this.skillLevel,
    totalPoints: totalPoints ?? this.totalPoints,
    roundsWon: roundsWon ?? this.roundsWon,
    matchesPlayed: matchesPlayed ?? this.matchesPlayed,
    benchCount: benchCount ?? this.benchCount,
  );
}
