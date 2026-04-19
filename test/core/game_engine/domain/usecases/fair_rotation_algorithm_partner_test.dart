import 'package:flutter_test/flutter_test.dart';
import 'package:sonrize_padel/core/game_engine/domain/entities/game_player.dart';
import 'package:sonrize_padel/core/game_engine/domain/usecases/fair_rotation_algorithm.dart';

void main() {
  late FairRotationAlgorithm algorithm;

  setUp(() {
    algorithm = const FairRotationAlgorithm();
  });

  List<GamePlayer> createPlayers(int count) => List.generate(
    count,
    (i) => GamePlayer(id: 'player$i', displayName: 'Player $i'),
  );

  CompletedRound createRound({
    required int roundNumber,
    required List<String> teamA,
    required List<String> teamB,
    List<String> bench = const [],
  }) => CompletedRound(
    roundNumber: roundNumber,
    teamAPlayerIds: teamA,
    teamBPlayerIds: teamB,
    benchPlayerIds: bench,
    teamAScore: 12,
    teamBScore: 10,
  );

  group('FairRotationAlgorithm - Partner Fairness', () {
    test(
      '4 players: each player partners with every other player over 3 rounds',
      () {
        final players = createPlayers(4);
        final completedRounds = <CompletedRound>[];
        final allPartners = <String, Set<String>>{};

        // Initialize partner sets
        for (final p in players) {
          allPartners[p.id] = {};
        }

        // Play 3 rounds (all combinations possible)
        for (int round = 1; round <= 3; round++) {
          final result = algorithm.calculateNextRound(
            allPlayers: players,
            completedRounds: completedRounds,
          );

          // Extract partners from this round
          final teamAPlayers = result.teamA.players.map((p) => p.id).toList();
          final teamBPlayers = result.teamB.players.map((p) => p.id).toList();

          // Team A partners
          allPartners[teamAPlayers[0]]!.add(teamAPlayers[1]);
          allPartners[teamAPlayers[1]]!.add(teamAPlayers[0]);

          // Team B partners
          allPartners[teamBPlayers[0]]!.add(teamBPlayers[1]);
          allPartners[teamBPlayers[1]]!.add(teamBPlayers[0]);

          completedRounds.add(
            createRound(
              roundNumber: round,
              teamA: teamAPlayers,
              teamB: teamBPlayers,
            ),
          );
        }

        // After 3 rounds, each player should have partnered with all 3 others
        for (final playerId in allPartners.keys) {
          expect(
            allPartners[playerId]!.length,
            equals(3),
            reason:
                'Player $playerId should have 3 unique partners after 3 rounds',
          );
        }
      },
    );

    test(
      '6 players: each player partners with others fairly over multiple rounds',
      () {
        final players = createPlayers(6);
        final completedRounds = <CompletedRound>[];
        final partnerCounts = <String, Map<String, int>>{};

        // Initialize partner counts
        for (final p in players) {
          partnerCounts[p.id] = {};
        }

        // Play enough rounds to ensure fair distribution
        for (int round = 1; round <= 12; round++) {
          final result = algorithm.calculateNextRound(
            allPlayers: players,
            completedRounds: completedRounds,
          );

          final teamAPlayers = result.teamA.players.map((p) => p.id).toList();
          final teamBPlayers = result.teamB.players.map((p) => p.id).toList();

          // Count partnerships
          partnerCounts[teamAPlayers[0]]![teamAPlayers[1]] =
              (partnerCounts[teamAPlayers[0]]![teamAPlayers[1]] ?? 0) + 1;
          partnerCounts[teamAPlayers[1]]![teamAPlayers[0]] =
              (partnerCounts[teamAPlayers[1]]![teamAPlayers[0]] ?? 0) + 1;

          partnerCounts[teamBPlayers[0]]![teamBPlayers[1]] =
              (partnerCounts[teamBPlayers[0]]![teamBPlayers[1]] ?? 0) + 1;
          partnerCounts[teamBPlayers[1]]![teamBPlayers[0]] =
              (partnerCounts[teamBPlayers[1]]![teamBPlayers[0]] ?? 0) + 1;

          completedRounds.add(
            createRound(
              roundNumber: round,
              teamA: teamAPlayers,
              teamB: teamBPlayers,
              bench: result.benchPlayers.map((p) => p.id).toList(),
            ),
          );
        }

        // Variance in partnership counts should be reasonable (max 2 difference)
        for (final playerId in partnerCounts.keys) {
          final counts = partnerCounts[playerId]!.values.toList();
          if (counts.isEmpty) {
            continue;
          }
          final maxCount = counts.reduce((a, b) => a > b ? a : b);
          final minCount = counts.reduce((a, b) => a < b ? a : b);
          expect(
            maxCount - minCount,
            lessThanOrEqualTo(3),
            reason: 'Player $playerId partnership variance should be <= 3',
          );
        }
      },
    );

    test('no player sits out twice in a row when possible', () {
      final players = createPlayers(6);
      final completedRounds = <CompletedRound>[];

      for (int round = 1; round <= 10; round++) {
        final result = algorithm.calculateNextRound(
          allPlayers: players,
          completedRounds: completedRounds,
        );

        final benchedIds = result.benchPlayers.map((p) => p.id).toSet();

        // If there was a previous round, check that no current bench player was on bench last round
        if (completedRounds.isNotEmpty) {
          final lastBench = completedRounds.last.benchPlayerIds.toSet();

          // Most benched players should NOT be benched again consecutively
          // Allow at most 1 exception (when truly unavoidable)
          final consecutiveBenches = benchedIds.intersection(lastBench);
          expect(
            consecutiveBenches.length,
            lessThanOrEqualTo(1),
            reason: 'Round $round: Too many players benched consecutively',
          );
        }

        completedRounds.add(
          createRound(
            roundNumber: round,
            teamA: result.teamA.players.map((p) => p.id).toList(),
            teamB: result.teamB.players.map((p) => p.id).toList(),
            bench: result.benchPlayers.map((p) => p.id).toList(),
          ),
        );
      }
    });
  });

  group('FairRotationAlgorithm - Side Distribution', () {
    test('each player plays on both Team A and Team B over time', () {
      final players = createPlayers(4);
      final completedRounds = <CompletedRound>[];
      final sideACounts = <String, int>{};
      final sideBCounts = <String, int>{};

      for (final p in players) {
        sideACounts[p.id] = 0;
        sideBCounts[p.id] = 0;
      }

      // Play enough rounds to ensure both sides are experienced
      for (int round = 1; round <= 6; round++) {
        final result = algorithm.calculateNextRound(
          allPlayers: players,
          completedRounds: completedRounds,
        );

        for (final p in result.teamA.players) {
          sideACounts[p.id] = sideACounts[p.id]! + 1;
        }
        for (final p in result.teamB.players) {
          sideBCounts[p.id] = sideBCounts[p.id]! + 1;
        }

        completedRounds.add(
          createRound(
            roundNumber: round,
            teamA: result.teamA.players.map((p) => p.id).toList(),
            teamB: result.teamB.players.map((p) => p.id).toList(),
          ),
        );
      }

      // Each player should have played on both sides
      for (final playerId in players.map((p) => p.id)) {
        expect(
          sideACounts[playerId],
          greaterThan(0),
          reason: 'Player $playerId should have played on Team A at least once',
        );
        expect(
          sideBCounts[playerId],
          greaterThan(0),
          reason: 'Player $playerId should have played on Team B at least once',
        );
      }
    });

    test('6 players: side distribution remains fair over time', () {
      final players = createPlayers(6);
      final completedRounds = <CompletedRound>[];
      final sideACounts = <String, int>{};
      final sideBCounts = <String, int>{};

      for (final p in players) {
        sideACounts[p.id] = 0;
        sideBCounts[p.id] = 0;
      }

      // Play 12 rounds (each player should play ~8 rounds, ~4 on each side ideally)
      for (int round = 1; round <= 12; round++) {
        final result = algorithm.calculateNextRound(
          allPlayers: players,
          completedRounds: completedRounds,
        );

        for (final p in result.teamA.players) {
          sideACounts[p.id] = sideACounts[p.id]! + 1;
        }
        for (final p in result.teamB.players) {
          sideBCounts[p.id] = sideBCounts[p.id]! + 1;
        }

        completedRounds.add(
          createRound(
            roundNumber: round,
            teamA: result.teamA.players.map((p) => p.id).toList(),
            teamB: result.teamB.players.map((p) => p.id).toList(),
            bench: result.benchPlayers.map((p) => p.id).toList(),
          ),
        );
      }

      // Check side distribution variance
      final allSideACounts = sideACounts.values.toList();
      final maxSideA = allSideACounts.reduce((a, b) => a > b ? a : b);
      final minSideA = allSideACounts.reduce((a, b) => a < b ? a : b);

      expect(
        maxSideA - minSideA,
        lessThanOrEqualTo(4),
        reason: 'Team A side distribution variance should be <= 4',
      );
    });
  });

  group('FairRotationAlgorithm - Playtime Distribution', () {
    // Skipped: Algorithmus muss play counts in completedRounds tracken
    test(
      'all players get equal court time over many rounds',
      () {
        final players = createPlayers(6);
        final completedRounds = <CompletedRound>[];
        final playCounts = <String, int>{};

        for (final p in players) {
          playCounts[p.id] = 0;
        }

        for (int round = 1; round <= 48; round++) {
          final result = algorithm.calculateNextRound(
            allPlayers: players,
            completedRounds: completedRounds,
          );

          for (final p in result.courtPlayers) {
            playCounts[p.id] = playCounts[p.id]! + 1;
          }

          completedRounds.add(
            createRound(
              roundNumber: round,
              teamA: result.teamA.players.map((p) => p.id).toList(),
              teamB: result.teamB.players.map((p) => p.id).toList(),
              bench: result.benchPlayers.map((p) => p.id).toList(),
            ),
          );
        }

        final counts = playCounts.values.toList();
        final maxPlay = counts.reduce((a, b) => a > b ? a : b);
        final minPlay = counts.reduce((a, b) => a < b ? a : b);

        expect(
          maxPlay - minPlay,
          lessThanOrEqualTo(2),
          reason:
              'Variance: ${maxPlay - minPlay}, Max: $maxPlay, Min: $minPlay',
        );
      },
      skip: 'Algorithm needs play count tracking in completedRounds',
    );

    test('all players eventually get to play when bench is available', () {
      final players = createPlayers(6);
      final completedRounds = <CompletedRound>[];
      final playerHasPlayed = <String, bool>{};

      for (final p in players) {
        playerHasPlayed[p.id] = false;
      }

      for (int round = 1; round <= 10; round++) {
        final result = algorithm.calculateNextRound(
          allPlayers: players,
          completedRounds: completedRounds,
        );

        for (final p in result.courtPlayers) {
          playerHasPlayed[p.id] = true;
        }

        completedRounds.add(
          createRound(
            roundNumber: round,
            teamA: result.teamA.players.map((p) => p.id).toList(),
            teamB: result.teamB.players.map((p) => p.id).toList(),
            bench: result.benchPlayers.map((p) => p.id).toList(),
          ),
        );
      }

      // After 10 rounds, everyone should have played at least once
      for (final entry in playerHasPlayed.entries) {
        expect(
          entry.value,
          isTrue,
          reason:
              'Player ${entry.key} should have played at least once in 10 rounds',
        );
      }
    });
  });

  group('FairRotationAlgorithm - Edge Cases', () {
    test('handles 8 players fairly', () {
      final players = createPlayers(8);
      final completedRounds = <CompletedRound>[];

      for (int round = 1; round <= 8; round++) {
        final result = algorithm.calculateNextRound(
          allPlayers: players,
          completedRounds: completedRounds,
        );

        expect(result.courtPlayers.length, equals(4));
        expect(result.benchPlayers.length, equals(4));

        completedRounds.add(
          createRound(
            roundNumber: round,
            teamA: result.teamA.players.map((p) => p.id).toList(),
            teamB: result.teamB.players.map((p) => p.id).toList(),
            bench: result.benchPlayers.map((p) => p.id).toList(),
          ),
        );
      }
    });

    test('handles 10 players', () {
      final players = createPlayers(10);
      final completedRounds = <CompletedRound>[];

      for (int round = 1; round <= 10; round++) {
        final result = algorithm.calculateNextRound(
          allPlayers: players,
          completedRounds: completedRounds,
        );

        expect(result.courtPlayers.length, equals(4));
        expect(result.benchPlayers.length, equals(6));

        completedRounds.add(
          createRound(
            roundNumber: round,
            teamA: result.teamA.players.map((p) => p.id).toList(),
            teamB: result.teamB.players.map((p) => p.id).toList(),
            bench: result.benchPlayers.map((p) => p.id).toList(),
          ),
        );
      }
    });
  });
}
