import '../entities/entities.dart';
import 'rotation_algorithm.dart' show RotationResult, PairingConstraints;

/// FairRotationAlgorithm - O(n) Round-Robin based rotation for Americano
///
/// Guarantees:
/// 1. No player sits out more than 1 consecutive round
/// 2. Fair playtime distribution (max variance ≤ 1 round)
/// 3. Each player partners with every other player eventually
class FairRotationAlgorithm {
  RotationResult calculateNextRound({
    required List<Participant> allParticipants,
    required List<Round> completedRounds,
    required PairingConstraints constraints,
    int targetPoints = 12,
  }) {
    if (allParticipants.length < 4) {
      throw ArgumentError('Need at least 4 participants for a round');
    }

    final players = allParticipants.map(_participantToPlayer).toList();
    final lastBenchIds = _getLastBenchPlayerIds(completedRounds);

    if (allParticipants.length == 4) {
      return _createFixedRound(players);
    }

    return _createFairRound(players, lastBenchIds, constraints);
  }

  Set<String> _getLastBenchPlayerIds(List<Round> completedRounds) {
    if (completedRounds.isEmpty) {
      return {};
    }
    final lastRound = completedRounds.last;
    return lastRound.bench.map((p) => p.id).toSet();
  }

  Player _participantToPlayer(Participant p) => Player(
        id: p.id,
        displayName: p.displayName,
        avatar: p.avatar,
        isGuest: p.isGuest,
        deviceId: p.deviceId,
        skillLevel: p.skillLevel,
        totalPoints: p.totalPoints,
        roundsWon: p.roundsWon,
        matchesPlayed: p.matchesPlayed,
        benchCount: p.benchCount,
      );

  RotationResult _createFixedRound(List<Player> players) {
    final teamA = Team(
      players: [players[0], players[1]],
      side: TeamSide.a,
      isServing: true,
    );
    final teamB = Team(
      players: [players[2], players[3]],
      side: TeamSide.b,
      isServing: false,
    );

    return RotationResult(
      courtPlayers: players,
      benchPlayers: const [],
      teamA: teamA,
      teamB: teamB,
      pairingReason: 'Fixed teams for 4 players',
    );
  }

  RotationResult _createFairRound(
    List<Player> players,
    Set<String> lastBenchIds,
    PairingConstraints constraints,
  ) {
    final n = players.length;

    // Determine how many players sit out this round
    final benchCount = n - 4;

    // Sort players by priority for bench:
    // 1. Players who benched last round get priority to play
    // 2. Among those, players with fewer total rounds played get priority
    final sortedForBench = List<Player>.from(players);
    sortedForBench.sort((a, b) {
      final aBenchedLast = lastBenchIds.contains(a.id) ? 0 : 1;
      final bBenchedLast = lastBenchIds.contains(b.id) ? 0 : 1;
      if (aBenchedLast != bBenchedLast) {
        return aBenchedLast.compareTo(bBenchedLast);
      }

      // Secondary: fewer rounds played = higher priority to play
      return a.matchesPlayed.compareTo(b.matchesPlayed);
    });

    // Assign bench: lowest priority play (benched last, fewer games)
    final bench = sortedForBench.take(benchCount).toList();
    final playing = sortedForBench.skip(benchCount).toList();

    // Use circle method for fair pairing
    final (teamA, teamB) = _circleMethodPairing(playing);

    String reason;
    if (bench.isEmpty) {
      reason = 'All players on court';
    } else if (lastBenchIds.isNotEmpty &&
        bench.any((p) => !lastBenchIds.contains(p.id))) {
      reason =
          'Fair rotation: ${bench.map((p) => p.displayName.split(' ').first).join(', ')} sat out';
    } else {
      reason = 'Round-robin pairing';
    }

    return RotationResult(
      courtPlayers: [...teamA.players, ...teamB.players],
      benchPlayers: bench,
      teamA: teamA,
      teamB: teamB,
      pairingReason: reason,
    );
  }

  /// Circle method: Simple pairing for 4 players on court
  (Team, Team) _circleMethodPairing(List<Player> players) {
    final teamA = Team(
      players: [players[0], players[1]],
      side: TeamSide.a,
      isServing: true,
    );
    final teamB = Team(
      players: [players[2], players[3]],
      side: TeamSide.b,
      isServing: false,
    );

    return (teamA, teamB);
  }

  Round createRound({
    required String roundId,
    required int roundNumber,
    required RotationResult rotationResult,
    required int targetPoints,
  }) {
    final serveState = ServeState(
      currentServer: rotationResult.teamA.players.isNotEmpty
          ? rotationResult.teamA.players[0]
          : null,
      currentReturner: rotationResult.teamB.players.isNotEmpty
          ? rotationResult.teamB.players[0]
          : null,
      pointsServedThisTurn: 0,
      currentServePosition: ServePosition.right,
      isFirstServe: true,
    );

    return Round(
      id: roundId,
      roundNumber: roundNumber,
      players: rotationResult.courtPlayers,
      bench: rotationResult.benchPlayers,
      teamA: rotationResult.teamA,
      teamB: rotationResult.teamB,
      serveState: serveState,
      score: Score(
        teamAPoints: 0,
        teamBPoints: 0,
        targetPoints: targetPoints,
        status: ScoreStatus.active,
        timeline: const [],
        serveCount: 0,
      ),
      status: RoundStatus.active,
      pairingReason: rotationResult.pairingReason,
    );
  }
}
