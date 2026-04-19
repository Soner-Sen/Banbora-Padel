import 'package:equatable/equatable.dart';
import 'package:sonrize_padel/core/game_engine/game_engine.dart';
import '../../domain/entities/entities.dart';

enum AmericanoStatus {
  initial,
  lobby,
  inProgress,
  matchComplete,
  sessionComplete,
  error,
}

class AmericanoState extends Equatable {
  const AmericanoState({
    this.status = AmericanoStatus.initial,
    this.session,
    this.leaderboard,
    this.currentMatch,
    this.selectedTargetPoints = 12,
    this.gameMode = GameModeType.americano,
    this.errorMessage,
  });

  final AmericanoStatus status;
  final AmericanoSession? session;
  final AmericanoLeaderboard? leaderboard;
  final AmericanoMatch? currentMatch;
  final int selectedTargetPoints;
  final GameModeType gameMode;
  final String? errorMessage;

  AmericanoState copyWith({
    AmericanoStatus? status,
    AmericanoSession? session,
    AmericanoLeaderboard? leaderboard,
    AmericanoMatch? currentMatch,
    int? selectedTargetPoints,
    GameModeType? gameMode,
    String? errorMessage,
  }) => AmericanoState(
    status: status ?? this.status,
    session: session ?? this.session,
    leaderboard: leaderboard ?? this.leaderboard,
    currentMatch: currentMatch ?? this.currentMatch,
    selectedTargetPoints: selectedTargetPoints ?? this.selectedTargetPoints,
    gameMode: gameMode ?? this.gameMode,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  /// Check if a match is complete based on game mode
  /// Americano: combined points = target (e.g., 6:6, 11:1, 4:8 for target 12)
  /// Liga: one team reaches target (e.g., 14:0, 14:9 for target 14)
  bool isMatchComplete(int teamAScore, int teamBScore) {
    if (gameMode == GameModeType.americano) {
      // Combined score must equal target
      return teamAScore + teamBScore >= selectedTargetPoints;
    } else {
      // One team reaches target
      return teamAScore >= selectedTargetPoints ||
          teamBScore >= selectedTargetPoints;
    }
  }

  /// Get remaining points for Americano mode
  /// Returns how many combined points are still needed
  int get remainingCombinedPoints {
    if (gameMode != GameModeType.americano) {
      return 0;
    }
    final currentMatch = this.currentMatch;
    if (currentMatch == null) {
      return selectedTargetPoints;
    }
    return selectedTargetPoints -
        (currentMatch.teamAScore + currentMatch.teamBScore);
  }

  @override
  List<Object?> get props => [
    status,
    session,
    leaderboard,
    currentMatch,
    selectedTargetPoints,
    gameMode,
    errorMessage,
  ];
}
