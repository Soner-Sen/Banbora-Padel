import 'orbit_entities.dart';

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.playerId,
    required this.displayName,
    required this.avatar,
    this.totalPoints = 0,
    this.roundsWon = 0,
    this.matchesPlayed = 0,
    this.benchCount = 0,
    this.currentStreak = 0,
    this.lastRoundPlacement,
    this.averagePointsPerMatch = 0.0,
  });
  final String playerId;
  final String displayName;
  final PlayerAvatar avatar;
  final int totalPoints;
  final int roundsWon;
  final int matchesPlayed;
  final int benchCount;
  final int currentStreak;
  final int? lastRoundPlacement;
  final double averagePointsPerMatch;

  LeaderboardEntry copyWith({
    String? playerId,
    String? displayName,
    PlayerAvatar? avatar,
    int? totalPoints,
    int? roundsWon,
    int? matchesPlayed,
    int? benchCount,
    int? currentStreak,
    int? lastRoundPlacement,
    double? averagePointsPerMatch,
  }) => LeaderboardEntry(
    playerId: playerId ?? this.playerId,
    displayName: displayName ?? this.displayName,
    avatar: avatar ?? this.avatar,
    totalPoints: totalPoints ?? this.totalPoints,
    roundsWon: roundsWon ?? this.roundsWon,
    matchesPlayed: matchesPlayed ?? this.matchesPlayed,
    benchCount: benchCount ?? this.benchCount,
    currentStreak: currentStreak ?? this.currentStreak,
    lastRoundPlacement: lastRoundPlacement ?? this.lastRoundPlacement,
    averagePointsPerMatch: averagePointsPerMatch ?? this.averagePointsPerMatch,
  );

  int get rankingScore =>
      (totalPoints * 100) + (roundsWon * 10) - (benchCount * 5);
}

class Leaderboard {
  const Leaderboard({
    required this.sessionId,
    required this.entries,
    required this.lastUpdated,
    this.showTeamRanking = false,
    this.showIndividualRanking = true,
  });
  final String sessionId;
  final List<LeaderboardEntry> entries;
  final DateTime lastUpdated;
  final bool showTeamRanking;
  final bool showIndividualRanking;

  Leaderboard copyWith({
    String? sessionId,
    List<LeaderboardEntry>? entries,
    DateTime? lastUpdated,
    bool? showTeamRanking,
    bool? showIndividualRanking,
  }) => Leaderboard(
    sessionId: sessionId ?? this.sessionId,
    entries: entries ?? this.entries,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    showTeamRanking: showTeamRanking ?? this.showTeamRanking,
    showIndividualRanking: showIndividualRanking ?? this.showIndividualRanking,
  );

  List<LeaderboardEntry> get sortedByPoints {
    final sorted = List<LeaderboardEntry>.from(entries);
    sorted.sort((a, b) => b.rankingScore.compareTo(a.rankingScore));
    return sorted;
  }

  LeaderboardEntry? getEntryByPlayerId(String playerId) {
    try {
      return entries.firstWhere((e) => e.playerId == playerId);
    } catch (_) {
      return null;
    }
  }
}
