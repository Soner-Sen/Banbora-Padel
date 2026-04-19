import 'americano_participant.dart';

/// Leaderboard entry for a single player in Americano
class AmericanoLeaderboardEntry {
  const AmericanoLeaderboardEntry({
    required this.participant,
    required this.totalPoints,
    required this.matchesPlayed,
    this.matchesWon = 0,
    this.matchesLost = 0,
    this.matchesDrawn = 0,
    this.averagePointsPerMatch = 0.0,
    this.winRate = 0.0,
  });

  final AmericanoParticipant participant;
  final int totalPoints;
  final int matchesPlayed;
  final int matchesWon;
  final int matchesLost;
  final int matchesDrawn;
  final double averagePointsPerMatch;
  final double winRate;

  AmericanoLeaderboardEntry copyWith({
    AmericanoParticipant? participant,
    int? totalPoints,
    int? matchesPlayed,
    int? matchesWon,
    int? matchesLost,
    int? matchesDrawn,
    double? averagePointsPerMatch,
    double? winRate,
  }) => AmericanoLeaderboardEntry(
    participant: participant ?? this.participant,
    totalPoints: totalPoints ?? this.totalPoints,
    matchesPlayed: matchesPlayed ?? this.matchesPlayed,
    matchesWon: matchesWon ?? this.matchesWon,
    matchesLost: matchesLost ?? this.matchesLost,
    matchesDrawn: matchesDrawn ?? this.matchesDrawn,
    averagePointsPerMatch: averagePointsPerMatch ?? this.averagePointsPerMatch,
    winRate: winRate ?? this.winRate,
  );

  /// Ranking score for Americano - just total points
  int get rankingScoreAmericano => totalPoints;

  /// Ranking score for Liga - wins primary, points as tiebreaker
  /// Uses average stats when players have played different numbers of matches
  /// for fairness: averageWinRate * 100000 + averagePoints
  int get rankingScoreLiga {
    if (matchesPlayed == 0) {
      return 0;
    }
    final avgWins = matchesWon / matchesPlayed;
    final avgPoints = averagePointsPerMatch;
    // Scale: wins are most important (×100000), then points
    return (avgWins * 100000 + avgPoints).round();
  }
}

/// Leaderboard for Americano/Liga session, sorted by total points
class AmericanoLeaderboard {
  const AmericanoLeaderboard({
    required this.sessionId,
    required this.entries,
    required this.lastUpdated,
    this.useLigaScoring = false,
  });

  final String sessionId;
  final List<AmericanoLeaderboardEntry> entries;
  final DateTime lastUpdated;
  final bool useLigaScoring;

  /// Sort entries by ranking score
  /// For Americano: sort by total points
  /// For Liga: sort by wins (as ratio), then points as tiebreaker
  List<AmericanoLeaderboardEntry> get sortedByPoints {
    final sorted = List<AmericanoLeaderboardEntry>.from(entries);
    if (useLigaScoring) {
      sorted.sort((a, b) => b.rankingScoreLiga.compareTo(a.rankingScoreLiga));
    } else {
      sorted.sort(
        (a, b) => b.rankingScoreAmericano.compareTo(a.rankingScoreAmericano),
      );
    }
    return sorted;
  }

  AmericanoLeaderboardEntry? getEntry(String playerId) {
    try {
      return entries.firstWhere((e) => e.participant.id == playerId);
    } catch (_) {
      return null;
    }
  }

  int? getRank(String playerId) {
    final sorted = sortedByPoints;
    final index = sorted.indexWhere((e) => e.participant.id == playerId);
    return index >= 0 ? index + 1 : null;
  }

  AmericanoLeaderboard copyWith({
    String? sessionId,
    List<AmericanoLeaderboardEntry>? entries,
    DateTime? lastUpdated,
    bool? useLigaScoring,
  }) => AmericanoLeaderboard(
    sessionId: sessionId ?? this.sessionId,
    entries: entries ?? this.entries,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    useLigaScoring: useLigaScoring ?? this.useLigaScoring,
  );
}
