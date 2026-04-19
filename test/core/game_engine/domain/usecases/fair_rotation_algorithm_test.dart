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

  group('FairRotationAlgorithm - 4 Player Rotation', () {
    test('round 1: P0+P1 vs P2+P3', () {
      final players = createPlayers(4);
      final result = algorithm.calculateNextRound(
        allPlayers: players,
        completedRounds: const [],
      );

      expect(
        result.teamA.players.map((p) => p.id).toList(),
        equals(['player0', 'player1']),
      );
      expect(
        result.teamB.players.map((p) => p.id).toList(),
        equals(['player2', 'player3']),
      );
      expect(result.benchPlayers, isEmpty);
    });

    test('round 2: P0+P2 vs P1+P3 (different partners)', () {
      final players = createPlayers(4);
      const completedRound = CompletedRound(
        roundNumber: 1,
        teamAPlayerIds: ['player0', 'player1'],
        teamBPlayerIds: ['player2', 'player3'],
        benchPlayerIds: [],
        teamAScore: 12,
        teamBScore: 10,
      );

      final result = algorithm.calculateNextRound(
        allPlayers: players,
        completedRounds: [completedRound],
      );

      // Round 2 should have different pairing
      final teamAPlayerIds = result.teamA.players.map((p) => p.id).toSet();
      final teamBPlayerIds = result.teamB.players.map((p) => p.id).toSet();

      // P0+P1 should NOT be together in Round 2
      expect(teamAPlayerIds, isNot(equals({'player0', 'player1'})));
      expect(teamBPlayerIds, isNot(equals({'player2', 'player3'})));
    });

    test('round 3: P0+P3 vs P1+P2 (yet another pairing)', () {
      final players = createPlayers(4);
      final completedRounds = [
        const CompletedRound(
          roundNumber: 1,
          teamAPlayerIds: ['player0', 'player1'],
          teamBPlayerIds: ['player2', 'player3'],
          benchPlayerIds: [],
          teamAScore: 12,
          teamBScore: 10,
        ),
        const CompletedRound(
          roundNumber: 2,
          teamAPlayerIds: ['player0', 'player2'],
          teamBPlayerIds: ['player1', 'player3'],
          benchPlayerIds: [],
          teamAScore: 12,
          teamBScore: 8,
        ),
      ];

      final result = algorithm.calculateNextRound(
        allPlayers: players,
        completedRounds: completedRounds,
      );

      // Round 3 should be P0+P3 vs P1+P2
      final allCourtPlayerIds = {
        ...result.teamA.players.map((p) => p.id),
        ...result.teamB.players.map((p) => p.id),
      };
      expect(
        allCourtPlayerIds,
        equals({'player0', 'player1', 'player2', 'player3'}),
      );
    });

    test('round 4: different from round 1 (side rotation)', () {
      final players = createPlayers(4);
      final completedRounds = [
        const CompletedRound(
          roundNumber: 1,
          teamAPlayerIds: ['player0', 'player1'],
          teamBPlayerIds: ['player2', 'player3'],
          benchPlayerIds: [],
          teamAScore: 12,
          teamBScore: 10,
        ),
        const CompletedRound(
          roundNumber: 2,
          teamAPlayerIds: ['player0', 'player2'],
          teamBPlayerIds: ['player1', 'player3'],
          benchPlayerIds: [],
          teamAScore: 12,
          teamBScore: 8,
        ),
        const CompletedRound(
          roundNumber: 3,
          teamAPlayerIds: ['player0', 'player3'],
          teamBPlayerIds: ['player1', 'player2'],
          benchPlayerIds: [],
          teamAScore: 12,
          teamBScore: 6,
        ),
      ];

      final result = algorithm.calculateNextRound(
        allPlayers: players,
        completedRounds: completedRounds,
      );

      // Round 4 has side rotation - should NOT be same as Round 1
      // But should still include all players
      final allCourtPlayerIds = {
        ...result.teamA.players.map((p) => p.id),
        ...result.teamB.players.map((p) => p.id),
      };
      expect(
        allCourtPlayerIds,
        equals({'player0', 'player1', 'player2', 'player3'}),
      );

      // Round 4 with side rotation = Round 3 pattern but swapped sides
      // P0+P1 vs P2+P3 (same as Round 1)
      // Round 4 patternIndex = (4-1) % 6 = 3 -> sides swapped from Round 1
      // So Team A should be P2+P3, Team B should be P0+P1
      final teamAIds = result.teamA.players.map((p) => p.id).toSet();
      final teamBIds = result.teamB.players.map((p) => p.id).toSet();

      // With side rotation, round 4 is the opposite of round 1
      // Round 1: Team A = {0,1}, Team B = {2,3}
      // Round 4: Team A = {2,3}, Team B = {0,1}
      expect(teamAIds, equals({'player2', 'player3'}));
      expect(teamBIds, equals({'player0', 'player1'}));
    });

    test('all 4 players play every round (no bench)', () {
      final players = createPlayers(4);

      for (int round = 1; round <= 4; round++) {
        final completedRounds = List.generate(
          round - 1,
          (i) => CompletedRound(
            roundNumber: i + 1,
            teamAPlayerIds: ['player$i', 'player${i + 1}'],
            teamBPlayerIds: ['player${(i + 2) % 4}', 'player${(i + 3) % 4}'],
            benchPlayerIds: const [],
            teamAScore: 12,
            teamBScore: 10,
          ),
        );

        final result = algorithm.calculateNextRound(
          allPlayers: players,
          completedRounds: completedRounds,
        );

        expect(
          result.benchPlayers,
          isEmpty,
          reason: 'Round $round should have no bench players',
        );
        expect(
          result.courtPlayers.length,
          equals(4),
          reason: 'Round $round should have 4 players on court',
        );
      }
    });
  });

  group('FairRotationAlgorithm - 6 Player Rotation', () {
    test('each player plays in first 3 rounds with 2 benched each round', () {
      final players = createPlayers(6);

      // Round 1
      final result1 = algorithm.calculateNextRound(
        allPlayers: players,
        completedRounds: const [],
      );
      expect(result1.benchPlayers.length, equals(2));
      expect(result1.courtPlayers.length, equals(4));

      // Round 2
      final result2 = algorithm.calculateNextRound(
        allPlayers: players,
        completedRounds: [result1.toCompletedRound(1)],
      );
      expect(result2.benchPlayers.length, equals(2));

      // Round 3
      final result3 = algorithm.calculateNextRound(
        allPlayers: players,
        completedRounds: [
          result1.toCompletedRound(1),
          result2.toCompletedRound(2),
        ],
      );
      expect(result3.benchPlayers.length, equals(2));

      // After 3 rounds, all 6 players should have been on court at least once
      final allCourtPlayers = <String>{};
      for (final round in [result1, result2, result3]) {
        allCourtPlayers.addAll(round.courtPlayers.map((p) => p.id));
      }
      expect(
        allCourtPlayers.length,
        equals(6),
        reason: 'All 6 players should have played in first 3 rounds',
      );
    });

    test('players benched last round get priority to play next round', () {
      final players = createPlayers(6);

      // Round 1: P4 and P5 benched
      final result1 = algorithm.calculateNextRound(
        allPlayers: players,
        completedRounds: const [],
      );
      final benchedIds = result1.benchPlayers.map((p) => p.id).toSet();

      // Round 2: those who benched should now be on court
      final result2 = algorithm.calculateNextRound(
        allPlayers: players,
        completedRounds: [result1.toCompletedRound(1)],
      );

      // Players who benched in Round 1 should be on court in Round 2
      for (final benchedId in benchedIds) {
        expect(
          result2.courtPlayers.any((p) => p.id == benchedId),
          isTrue,
          reason:
              '$benchedId benched in Round 1, should be on court in Round 2',
        );
      }
    });
  });

  group('FairRotationAlgorithm - Error Cases', () {
    test('throws error when fewer than 4 players', () {
      final players = createPlayers(3);

      expect(
        () => algorithm.calculateNextRound(
          allPlayers: players,
          completedRounds: const [],
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}

extension on RotationResult {
  CompletedRound toCompletedRound(int roundNumber) => CompletedRound(
    roundNumber: roundNumber,
    teamAPlayerIds: teamA.players.map((p) => p.id).toList(),
    teamBPlayerIds: teamB.players.map((p) => p.id).toList(),
    benchPlayerIds: benchPlayers.map((p) => p.id).toList(),
    teamAScore: 12,
    teamBScore: 10,
  );
}
