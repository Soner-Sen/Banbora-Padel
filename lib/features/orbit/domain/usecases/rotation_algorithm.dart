import 'dart:math';
import '../entities/entities.dart';

class RotationResult {
  const RotationResult({
    required this.courtPlayers,
    required this.benchPlayers,
    required this.teamA,
    required this.teamB,
    required this.pairingReason,
  });
  final List<Player> courtPlayers;
  final List<Player> benchPlayers;
  final Team teamA;
  final Team teamB;
  final String pairingReason;
}

class PairingConstraints {
  const PairingConstraints({
    this.partnerHistory = const {},
    this.opponentHistory = const {},
    this.matchesPlayed = const {},
    this.benchCount = const {},
    this.maxSamePartnerInARow,
  });
  final Map<String, Set<String>> partnerHistory;
  final Map<String, Set<String>> opponentHistory;
  final Map<String, int> matchesPlayed;
  final Map<String, int> benchCount;
  final int? maxSamePartnerInARow;
}

class RotationAlgorithm {
  static const int _repeatPartnerPenalty = 100;
  static const int _repeatOpponentPenalty = 30;
  static const int _sitOutStreakPenalty = 80;
  static const int _matchesPlayedImbalancePenalty = 10;
  static const int _immediateRematchPenalty = 150;

  RotationResult calculateNextRound({
    required List<Participant> allParticipants,
    required List<Round> completedRounds,
    required PairingConstraints constraints,
    int targetPoints = 12,
  }) {
    if (allParticipants.length < 4) {
      throw ArgumentError('Need at least 4 participants for a round');
    }

    if (allParticipants.length == 4) {
      return _createFixedRound(allParticipants, targetPoints);
    }

    final availablePlayers = allParticipants
        .map((p) => _participantToPlayer(p))
        .toList();

    final allCombinations = _generateAllCombinations(availablePlayers);
    final scoredCombinations = allCombinations.map((combo) {
      final score = _calculateCombinationScore(
        combo,
        availablePlayers,
        constraints,
      );
      return MapEntry(combo, score);
    }).toList();

    scoredCombinations.sort((a, b) => a.value.compareTo(b.value));
    final bestCombination = scoredCombinations.first.key;

    return _createRoundFromCombination(
      bestCombination,
      availablePlayers,
      targetPoints,
      constraints,
    );
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

  List<List<Player>> _generateAllCombinations(List<Player> players) {
    final combinations = <List<Player>>[];
    final n = players.length;

    for (int i = 0; i < n; i++) {
      for (int j = i + 1; j < n; j++) {
        for (int k = j + 1; k < n; k++) {
          for (int l = k + 1; l < n; l++) {
            combinations.add([players[i], players[j], players[k], players[l]]);
          }
        }
      }
    }

    return combinations;
  }

  double _calculateCombinationScore(
    List<Player> combo,
    List<Player> allPlayers,
    PairingConstraints constraints,
  ) {
    double score = 0;
    final comboSet = combo.toSet();

    for (int i = 0; i < combo.length; i++) {
      for (int j = i + 1; j < combo.length; j++) {
        final player1 = combo[i].id;
        final player2 = combo[j].id;
        final partners = constraints.partnerHistory[player1] ?? {};
        final opponents = constraints.opponentHistory[player1] ?? {};

        if (partners.contains(player2)) {
          score += _repeatPartnerPenalty;
        }

        for (final other in combo) {
          if (other.id != player1 && other.id != player2) {
            if (opponents.contains(other.id)) {
              score += _repeatOpponentPenalty;
            }
          }
        }
      }
    }

    if (combo.length == 4) {
      final aTeam = [combo[0], combo[1]];
      final bTeam = [combo[2], combo[3]];

      if (_wasLastRoundMatchup(
        aTeam.map((p) => p.id).toSet(),
        bTeam.map((p) => p.id).toSet(),
        constraints,
      )) {
        score += _immediateRematchPenalty;
      }
    }

    for (final player in combo) {
      final bench = constraints.benchCount[player.id] ?? 0;
      if (bench > 2) {
        score -= _sitOutStreakPenalty;
      }

      final played = constraints.matchesPlayed[player.id] ?? 0;
      final minPlayed = allPlayers
          .map((p) => constraints.matchesPlayed[p.id] ?? 0)
          .reduce(min);
      if (played > minPlayed + 1) {
        score += _matchesPlayedImbalancePenalty * (played - minPlayed);
      }
    }

    for (final player in allPlayers) {
      if (!comboSet.contains(player)) {
        final bench = constraints.benchCount[player.id] ?? 0;
        score -= bench * 5;
      }
    }

    return score;
  }

  bool _wasLastRoundMatchup(
    Set<String> teamA,
    Set<String> teamB,
    PairingConstraints constraints,
  ) {
    for (final entry in constraints.partnerHistory.entries) {
      final player = entry.key;
      for (final partner in entry.value) {
        if (teamA.contains(player) && teamA.contains(partner)) {
          final teamBMembers = teamB.toList();
          for (final opp in teamBMembers) {
            // ignore: unused_local_variable
            final oppOpponents = constraints.opponentHistory[opp] ?? {};
            if (teamA.contains(opp)) {
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  RotationResult _createFixedRound(
    List<Participant> participants,
    int targetPoints,
  ) {
    final players = participants.map((p) => _participantToPlayer(p)).toList();

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

  RotationResult _createRoundFromCombination(
    List<Player> combo,
    List<Player> allPlayers,
    int targetPoints,
    PairingConstraints constraints,
  ) {
    final teamA = Team(
      players: [combo[0], combo[1]],
      side: TeamSide.a,
      isServing: true,
    );
    final teamB = Team(
      players: [combo[2], combo[3]],
      side: TeamSide.b,
      isServing: false,
    );

    final benchPlayers = allPlayers.where((p) => !combo.contains(p)).toList();

    String reason = 'New partner combination';
    if (benchPlayers.isNotEmpty) {
      reason = 'Long bench time balanced';
    }

    return RotationResult(
      courtPlayers: combo,
      benchPlayers: benchPlayers,
      teamA: teamA,
      teamB: teamB,
      pairingReason: reason,
    );
  }

  Round createRound({
    required String roundId,
    required int roundNumber,
    required RotationResult rotationResult,
    required int targetPoints,
  }) {
    final serveState = ServeState(
      currentServer: rotationResult.teamA.players[0],
      currentReturner: rotationResult.teamB.players[0],
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
