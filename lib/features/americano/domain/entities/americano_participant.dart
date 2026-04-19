import 'package:sonrize_padel/core/game_engine/game_engine.dart';

/// Participant in an Americano session with accumulated stats
class AmericanoParticipant {
  const AmericanoParticipant({
    required this.id,
    required this.displayName,
    this.avatar = GamePlayerAvatar.avatar1,
    this.isGuest = false,
    this.deviceId,
    this.skillLevel,
    this.totalPoints = 0,
    this.matchesPlayed = 0,
    this.matchesWon = 0,
    this.benchCount = 0,
  });

  final String id;
  final String displayName;
  final GamePlayerAvatar avatar;
  final bool isGuest;
  final String? deviceId;
  final int? skillLevel;
  final int totalPoints;
  final int matchesPlayed;
  final int matchesWon;
  final int benchCount;

  GamePlayer toPlayer() => GamePlayer(
        id: id,
        displayName: displayName,
        avatar: avatar,
        isGuest: isGuest,
        deviceId: deviceId,
        skillLevel: skillLevel,
      );

  AmericanoParticipant copyWith({
    String? id,
    String? displayName,
    GamePlayerAvatar? avatar,
    bool? isGuest,
    String? deviceId,
    int? skillLevel,
    int? totalPoints,
    int? matchesPlayed,
    int? matchesWon,
    int? benchCount,
  }) =>
      AmericanoParticipant(
        id: id ?? this.id,
        displayName: displayName ?? this.displayName,
        avatar: avatar ?? this.avatar,
        isGuest: isGuest ?? this.isGuest,
        deviceId: deviceId ?? this.deviceId,
        skillLevel: skillLevel ?? this.skillLevel,
        totalPoints: totalPoints ?? this.totalPoints,
        matchesPlayed: matchesPlayed ?? this.matchesPlayed,
        matchesWon: matchesWon ?? this.matchesWon,
        benchCount: benchCount ?? this.benchCount,
      );

  double get averagePointsPerMatch =>
      matchesPlayed > 0 ? totalPoints / matchesPlayed : 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AmericanoParticipant &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
