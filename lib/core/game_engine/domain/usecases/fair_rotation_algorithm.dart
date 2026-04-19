import '../entities/game_player.dart';
import '../entities/game_team.dart';

/// Constraints for fair pairing decisions
class RotationConstraints {
  const RotationConstraints({
    this.partnerHistory = const {},
    this.matchesPlayed = const {},
    this.benchCount = const {},
    this.sideHistory = const {},
    this.consecutiveBench = const {},
  });

  final Map<String, Set<String>> partnerHistory;
  final Map<String, int> matchesPlayed;
  final Map<String, int> benchCount;

  /// How many times each player has been on Team A (for side balancing)
  final Map<String, int> sideHistory;

  /// How many consecutive rounds each player has been on bench
  final Map<String, int> consecutiveBench;
}

/// Result of a rotation calculation
class RotationResult {
  const RotationResult({
    required this.courtPlayers,
    required this.benchPlayers,
    required this.teamA,
    required this.teamB,
    required this.pairingReason,
  });

  final List<GamePlayer> courtPlayers;
  final List<GamePlayer> benchPlayers;
  final GameTeam teamA;
  final GameTeam teamB;
  final String pairingReason;
}

/// FairRotationAlgorithm - Fair Round-Robin rotation for Americano/Liga
///
/// Guarantees:
/// 1. No player sits out twice in a row (when possible)
/// 2. Fair playtime distribution (max variance ≤ 2 rounds)
/// 3. Each player partners with every other player eventually
/// 4. Side distribution is balanced over time (Team A/B)
/// 5. Players rotate between sides with their partners
class FairRotationAlgorithm {
  const FairRotationAlgorithm();

  RotationResult calculateNextRound({
    required List<GamePlayer> allPlayers,
    required List<CompletedRound> completedRounds,
    RotationConstraints constraints = const RotationConstraints(),
  }) {
    if (allPlayers.length < 4) {
      throw ArgumentError('Need at least 4 players for a round');
    }

    final roundNumber = completedRounds.length + 1;

    if (allPlayers.length == 4) {
      return _createFairFourPlayerRound(allPlayers, roundNumber, constraints);
    }

    return _createFairMultiPlayerRound(
      allPlayers,
      completedRounds,
      constraints,
    );
  }

  Set<String> _getLastBenchPlayerIds(List<CompletedRound> completedRounds) {
    if (completedRounds.isEmpty) {
      return {};
    }
    return completedRounds.last.benchPlayerIds.toSet();
  }

  /// Creates a fair rotating round for exactly 4 players
  /// Ensures side rotation: players alternate between Team A and Team B
  /// Round 1: P0+P1 vs P2+P3
  /// Round 2: P0+P2 vs P1+P3
  /// Round 3: P0+P3 vs P1+P2
  /// Round 4: P1+P2 vs P0+P3 (rotate which pair is on which side)
  RotationResult _createFairFourPlayerRound(
    List<GamePlayer> players,
    int roundNumber,
    RotationConstraints constraints,
  ) {
    final patternIndex = (roundNumber - 1) % 6;

    List<GamePlayer> teamA;
    List<GamePlayer> teamB;

    // Round-robin with side rotation
    // Rotate which pairing plays on which side
    switch (patternIndex) {
      case 0:
        teamA = [players[0], players[1]];
        teamB = [players[2], players[3]];
        break;
      case 1:
        teamA = [players[0], players[2]];
        teamB = [players[1], players[3]];
        break;
      case 2:
        teamA = [players[0], players[3]];
        teamB = [players[1], players[2]];
        break;
      case 3:
        // Rotate sides for previous round 1 pairing
        teamA = [players[2], players[3]];
        teamB = [players[0], players[1]];
        break;
      case 4:
        // Rotate sides for previous round 2 pairing
        teamA = [players[1], players[3]];
        teamB = [players[0], players[2]];
        break;
      case 5:
        // Rotate sides for previous round 3 pairing
        teamA = [players[1], players[2]];
        teamB = [players[0], players[3]];
        break;
      default:
        teamA = [players[0], players[1]];
        teamB = [players[2], players[3]];
    }

    final teamAObj = GameTeam(
      players: teamA,
      side: TeamSide.a,
      isServing: true,
    );
    final teamBObj = GameTeam(
      players: teamB,
      side: TeamSide.b,
      isServing: false,
    );

    return RotationResult(
      courtPlayers: [...teamA, ...teamB],
      benchPlayers: const [],
      teamA: teamAObj,
      teamB: teamBObj,
      pairingReason: 'Round-robin rotation (round $roundNumber)',
    );
  }

  RotationResult _createFairMultiPlayerRound(
    List<GamePlayer> players,
    List<CompletedRound> completedRounds,
    RotationConstraints constraints,
  ) {
    final benchCount = players.length - 4;
    final lastBenchIds = _getLastBenchPlayerIds(completedRounds);

    // Calculate consecutive bench counts properly
    final consecutiveBench = _calculateConsecutiveBench(
      players,
      completedRounds,
    );

    // Step 1: Determine who should play vs sit out
    final playing = _selectPlayersForCourt(
      players,
      lastBenchIds,
      consecutiveBench,
      constraints,
      benchCount,
    );

    // Step 2: Select fair bench players (who sat out last get priority to play)
    final bench = players.where((p) => !playing.contains(p)).toList();

    // Step 3: Create fair pairs considering partner history and side balance
    final (teamA, teamB) = _createFairPairs(
      playing,
      completedRounds,
      constraints,
    );

    String reason;
    if (bench.isEmpty) {
      reason = 'All players on court';
    } else if (lastBenchIds.isNotEmpty &&
        bench.any((p) => !lastBenchIds.contains(p.id))) {
      reason =
          '${bench.map((p) => p.displayName.split(' ').first).join(', ')} sat out';
    } else {
      reason = 'Fair rotation';
    }

    return RotationResult(
      courtPlayers: [...teamA.players, ...teamB.players],
      benchPlayers: bench,
      teamA: teamA,
      teamB: teamB,
      pairingReason: reason,
    );
  }

  Map<String, int> _calculateConsecutiveBench(
    List<GamePlayer> players,
    List<CompletedRound> completedRounds,
  ) {
    final consecutiveBench = <String, int>{};

    for (final player in players) {
      consecutiveBench[player.id] = 0;
    }

    if (completedRounds.isEmpty) {
      return consecutiveBench;
    }

    // Look back through rounds to count consecutive bench for each player
    for (int i = completedRounds.length - 1; i >= 0; i--) {
      final round = completedRounds[i];
      final roundBenchIds = round.benchPlayerIds.toSet();

      bool anyPlayerBroke = false;
      for (final player in players) {
        if (roundBenchIds.contains(player.id)) {
          // Player was on bench this round
          if (consecutiveBench[player.id] == 0) {
            // Start or continue consecutive bench
            consecutiveBench[player.id] = consecutiveBench[player.id]! + 1;
          }
        } else {
          // Player was playing - reset their consecutive bench
          consecutiveBench[player.id] = 0;
          anyPlayerBroke = true;
        }
      }

      // Optimization: if all players broke their bench streak, stop
      if (!anyPlayerBroke && i < completedRounds.length - 1) {
        break;
      }
    }

    return consecutiveBench;
  }

  List<GamePlayer> _selectPlayersForCourt(
    List<GamePlayer> players,
    Set<String> lastBenchIds,
    Map<String, int> consecutiveBench,
    RotationConstraints constraints,
    int benchCount,
  ) {
    // Sort players by priority to PLAY (higher score = higher priority to play)
    final sortedForPlay = List<GamePlayer>.from(players);
    sortedForPlay.sort((a, b) {
      // Primary: players who benched last round get priority to PLAY
      // (they should NOT be benched again)
      final aBenchedLast = lastBenchIds.contains(a.id) ? 1 : 0;
      final bBenchedLast = lastBenchIds.contains(b.id) ? 1 : 0;
      if (aBenchedLast != bBenchedLast) {
        return bBenchedLast.compareTo(aBenchedLast); // Higher = play first
      }

      // Secondary: fewer consecutive bench rounds = priority to play
      final aConsecBench = consecutiveBench[a.id] ?? 0;
      final bConsecBench = consecutiveBench[b.id] ?? 0;
      if (aConsecBench != bConsecBench) {
        return aConsecBench.compareTo(bConsecBench);
      }

      // Tertiary: fewer total bench count = priority to play
      final aBenchCount = constraints.benchCount[a.id] ?? 0;
      final bBenchCount = constraints.benchCount[b.id] ?? 0;
      if (aBenchCount != bBenchCount) {
        return aBenchCount.compareTo(bBenchCount);
      }

      // Quaternary: fewer matches played = priority to play
      final aPlayed = constraints.matchesPlayed[a.id] ?? 0;
      final bPlayed = constraints.matchesPlayed[b.id] ?? 0;
      return aPlayed.compareTo(bPlayed);
    });

    // Return the top 4 players who should play
    return sortedForPlay.take(4).toList();
  }

  (GameTeam, GameTeam) _createFairPairs(
    List<GamePlayer> players,
    List<CompletedRound> completedRounds,
    RotationConstraints constraints,
  ) {
    if (players.length != 4) {
      throw ArgumentError('Need exactly 4 players for pairing');
    }

    // Calculate partner history and side history from completed rounds
    final partnerCounts = _buildPartnerCounts(players, completedRounds);
    final sideCounts = _buildSideCounts(players, completedRounds);

    // Try all possible pairings and score them
    final pairings = _generateAllPairings(players);

    GameTeam? bestTeamA;
    GameTeam? bestTeamB;
    int bestScore = -999999;

    for (final pairing in pairings) {
      final (teamA, teamB) = pairing;

      // Score this pairing based on fairness criteria
      int score = 0;

      // 1. Prefer pairings with less common partners (avoid repetition)
      score -= _getPartnerRepetitionPenalty(
        teamA.players,
        teamB.players,
        partnerCounts,
      );

      // 2. Balance side distribution (prefer players who have been less on their assigned side)
      score += _getSideBalanceBonus(
        teamA.players,
        teamB.players,
        sideCounts,
        completedRounds.length,
      );

      // 3. Avoid putting same partners together too often
      score += _getPartnerAvoidanceScore(
        teamA.players[0],
        teamA.players[1],
        partnerCounts,
      );
      score += _getPartnerAvoidanceScore(
        teamB.players[0],
        teamB.players[1],
        partnerCounts,
      );

      if (score > bestScore) {
        bestScore = score;
        bestTeamA = teamA;
        bestTeamB = teamB;
      }
    }

    return (bestTeamA!, bestTeamB!);
  }

  Map<String, Map<String, int>> _buildPartnerCounts(
    List<GamePlayer> players,
    List<CompletedRound> completedRounds,
  ) {
    final partnerCounts = <String, Map<String, int>>{};

    for (final player in players) {
      partnerCounts[player.id] = {};
    }

    for (final round in completedRounds) {
      // Team A partners
      if (round.teamAPlayerIds.length >= 2) {
        final p1 = round.teamAPlayerIds[0];
        final p2 = round.teamAPlayerIds[1];
        if (partnerCounts.containsKey(p1)) {
          partnerCounts[p1]![p2] = (partnerCounts[p1]![p2] ?? 0) + 1;
        }
        if (partnerCounts.containsKey(p2)) {
          partnerCounts[p2]![p1] = (partnerCounts[p2]![p1] ?? 0) + 1;
        }
      }

      // Team B partners
      if (round.teamBPlayerIds.length >= 2) {
        final p1 = round.teamBPlayerIds[0];
        final p2 = round.teamBPlayerIds[1];
        if (partnerCounts.containsKey(p1)) {
          partnerCounts[p1]![p2] = (partnerCounts[p1]![p2] ?? 0) + 1;
        }
        if (partnerCounts.containsKey(p2)) {
          partnerCounts[p2]![p1] = (partnerCounts[p2]![p1] ?? 0) + 1;
        }
      }
    }

    return partnerCounts;
  }

  Map<String, int> _buildSideCounts(
    List<GamePlayer> players,
    List<CompletedRound> completedRounds,
  ) {
    // Count how many times each player has been on Team A
    final sideCounts = <String, int>{};

    for (final player in players) {
      sideCounts[player.id] = 0;
    }

    for (final round in completedRounds) {
      for (final playerId in round.teamAPlayerIds) {
        if (sideCounts.containsKey(playerId)) {
          sideCounts[playerId] = sideCounts[playerId]! + 1;
        }
      }
    }

    return sideCounts;
  }

  List<(GameTeam, GameTeam)> _generateAllPairings(List<GamePlayer> players) {
    final pairings = <(GameTeam, GameTeam)>[];
    final p0 = players[0];

    // Player[0] can pair with player[1], player[2], or player[3]
    for (int i = 1; i < 4; i++) {
      final partner1 = players[i];
      final remaining = players
          .where((p) => p.id != p0.id && p.id != partner1.id)
          .toList();
      final partner2 = remaining[0];
      final partner3 = remaining[1];

      // Create pairing with p0 on Team A
      pairings.add((
        GameTeam(players: [p0, partner1], side: TeamSide.a, isServing: true),
        GameTeam(
          players: [partner2, partner3],
          side: TeamSide.b,
          isServing: false,
        ),
      ));

      // Also create pairing with p0 on Team B (for side rotation)
      pairings.add((
        GameTeam(
          players: [partner2, partner3],
          side: TeamSide.a,
          isServing: true,
        ),
        GameTeam(players: [p0, partner1], side: TeamSide.b, isServing: false),
      ));
    }

    return pairings;
  }

  int _getPartnerRepetitionPenalty(
    List<GamePlayer> teamA,
    List<GamePlayer> teamB,
    Map<String, Map<String, int>> partnerCounts,
  ) {
    int penalty = 0;

    // Team A partnership
    final a1Partners = partnerCounts[teamA[0].id] ?? {};
    final a1WithA2 = a1Partners[teamA[1].id] ?? 0;
    penalty += a1WithA2 * 10;

    // Team B partnership
    final b1Partners = partnerCounts[teamB[0].id] ?? {};
    final b1WithB2 = b1Partners[teamB[1].id] ?? 0;
    penalty += b1WithB2 * 10;

    return penalty;
  }

  int _getSideBalanceBonus(
    List<GamePlayer> teamA,
    List<GamePlayer> teamB,
    Map<String, int> sideCounts,
    int roundsPlayed,
  ) {
    int bonus = 0;

    // For Team A: prefer players with lower Team A count (they need more B time)
    for (final player in teamA) {
      final aCount = sideCounts[player.id] ?? 0;
      if (roundsPlayed == 0) {
        bonus += 1; // Neutral starting point
      } else {
        // Bonus if player has been on Team A less than average
        final idealOnA = roundsPlayed / 2;
        if (aCount < idealOnA) {
          bonus += (idealOnA - aCount).round();
        }
      }
    }

    // For Team B: prefer players with higher Team A count (they need B time)
    for (final player in teamB) {
      final aCount = sideCounts[player.id] ?? 0;
      if (roundsPlayed == 0) {
        bonus += 1; // Neutral starting point
      } else {
        final idealOnA = roundsPlayed / 2;
        if (aCount > idealOnA) {
          bonus += (aCount - idealOnA).round();
        }
      }
    }

    return bonus;
  }

  int _getPartnerAvoidanceScore(
    GamePlayer p1,
    GamePlayer p2,
    Map<String, Map<String, int>> partnerCounts,
  ) {
    final partners = partnerCounts[p1.id] ?? {};
    final timesTogether = partners[p2.id] ?? 0;

    if (timesTogether == 0) {
      return 100;
    }
    if (timesTogether == 1) {
      return 50;
    }
    if (timesTogether == 2) {
      return 0;
    }
    return -50 * (timesTogether - 2);
  }
}

/// Represents a completed round for tracking purposes
class CompletedRound {
  const CompletedRound({
    required this.roundNumber,
    required this.teamAPlayerIds,
    required this.teamBPlayerIds,
    required this.benchPlayerIds,
    required this.teamAScore,
    required this.teamBScore,
    this.winnerSide,
  });

  final int roundNumber;
  final List<String> teamAPlayerIds;
  final List<String> teamBPlayerIds;
  final List<String> benchPlayerIds;
  final int teamAScore;
  final int teamBScore;
  final TeamSide? winnerSide;

  bool playerWon(String playerId) {
    if (winnerSide == null) {
      return false;
    }
    if (winnerSide == TeamSide.a) {
      return teamAPlayerIds.contains(playerId);
    }
    return teamBPlayerIds.contains(playerId);
  }

  int getPlayerScore(String playerId) {
    if (teamAPlayerIds.contains(playerId)) {
      return teamAScore;
    }
    if (teamBPlayerIds.contains(playerId)) {
      return teamBScore;
    }
    return 0;
  }
}
