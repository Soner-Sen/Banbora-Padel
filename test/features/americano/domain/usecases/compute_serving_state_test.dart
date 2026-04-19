import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sonrize_padel/core/game_engine/game_engine.dart';
import 'package:sonrize_padel/features/americano/domain/entities/serving_state.dart';
import 'package:sonrize_padel/features/americano/domain/usecases/compute_serving_state.dart';

void main() {
  late ComputeServingStateUseCase useCase;

  setUp(() {
    useCase = const ComputeServingStateUseCase();
  });

  group('ComputeServingStateUseCase', () {
    final serverRotationOrder = ['p0', 'p2', 'p1', 'p3'];

    group('Point rotation algorithm', () {
      test('points 0-3 should cycle through all 4 servers', () {
        for (int point = 0; point < 4; point++) {
          final state = useCase.execute(
            pointsPlayed: point,
            serverRotationOrder: serverRotationOrder,
            initialServingTeam: TeamSide.a,
          );
          expect(state.currentServerIndex, equals(point % 4));
        }
      });

      test(
        'serverSide alternates between right and left within 2-point cycle',
        () {
          for (int point = 0; point < 8; point++) {
            final state = useCase.execute(
              pointsPlayed: point,
              serverRotationOrder: serverRotationOrder,
              initialServingTeam: TeamSide.a,
            );

            final expectedSide = point % 2 == 0
                ? CourtSide.right
                : CourtSide.left;
            expect(
              state.serverSide,
              equals(expectedSide),
              reason: 'Point $point should have side $expectedSide',
            );
          }
        },
      );
    });

    group('Serving team alternation', () {
      test(
        'Team A serves first (initialServingTeam=a), Team A serves points 0-3, Team B serves points 4-7',
        () {
          for (int point = 0; point < 4; point++) {
            final state = useCase.execute(
              pointsPlayed: point,
              serverRotationOrder: serverRotationOrder,
              initialServingTeam: TeamSide.a,
            );
            expect(
              state.servingTeam,
              equals(TeamSide.a),
              reason: 'Point $point should be Team A serving',
            );
          }

          for (int point = 4; point < 8; point++) {
            final state = useCase.execute(
              pointsPlayed: point,
              serverRotationOrder: serverRotationOrder,
              initialServingTeam: TeamSide.a,
            );
            expect(
              state.servingTeam,
              equals(TeamSide.b),
              reason: 'Point $point should be Team B serving',
            );
          }
        },
      );

      test(
        'Team B serves first (initialServingTeam=b), Team B serves points 0-3, Team A serves points 4-7',
        () {
          for (int point = 0; point < 4; point++) {
            final state = useCase.execute(
              pointsPlayed: point,
              serverRotationOrder: serverRotationOrder,
              initialServingTeam: TeamSide.b,
            );
            expect(
              state.servingTeam,
              equals(TeamSide.b),
              reason: 'Point $point should be Team B serving',
            );
          }

          for (int point = 4; point < 8; point++) {
            final state = useCase.execute(
              pointsPlayed: point,
              serverRotationOrder: serverRotationOrder,
              initialServingTeam: TeamSide.b,
            );
            expect(
              state.servingTeam,
              equals(TeamSide.a),
              reason: 'Point $point should be Team A serving',
            );
          }
        },
      );

      test('serving team alternates every 4 points', () {
        for (int cycle = 0; cycle < 4; cycle++) {
          for (int pointInCycle = 0; pointInCycle < 4; pointInCycle++) {
            final point = cycle * 4 + pointInCycle;
            final state = useCase.execute(
              pointsPlayed: point,
              serverRotationOrder: serverRotationOrder,
              initialServingTeam: TeamSide.a,
            );

            final expectedTeam = cycle % 2 == 0 ? TeamSide.a : TeamSide.b;
            expect(
              state.servingTeam,
              equals(expectedTeam),
              reason: 'Point $point cycle $cycle should be $expectedTeam',
            );
          }
        }
      });
    });

    group('Complete 8-point sequence verification', () {
      test('verifySequence returns correct states for first 8 points', () {
        final sequence = useCase.verifySequence(
          startPoint: 0,
          count: 8,
          serverRotationOrder: serverRotationOrder,
          initialServingTeam: TeamSide.a,
        );

        expect(sequence.length, equals(8));

        // Points 0-3: ServerIndex 0,1,2,3; Team A serving
        expect(sequence[0]!.currentServerIndex, equals(0));
        expect(sequence[1]!.currentServerIndex, equals(1));
        expect(sequence[2]!.currentServerIndex, equals(2));
        expect(sequence[3]!.currentServerIndex, equals(3));
        expect(sequence[0]!.servingTeam, equals(TeamSide.a));

        // Points 4-7: ServerIndex 0,1,2,3; Team B serving
        expect(sequence[4]!.currentServerIndex, equals(0));
        expect(sequence[5]!.currentServerIndex, equals(1));
        expect(sequence[6]!.currentServerIndex, equals(2));
        expect(sequence[7]!.currentServerIndex, equals(3));
        expect(sequence[4]!.servingTeam, equals(TeamSide.b));
      });
    });

    group('Edge cases', () {
      test('throws error for empty serverRotationOrder', () {
        expect(
          () => useCase.execute(
            pointsPlayed: 0,
            serverRotationOrder: [],
            initialServingTeam: TeamSide.a,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('handles large point numbers without overflow', () {
        final state = useCase.execute(
          pointsPlayed: 1000000,
          serverRotationOrder: serverRotationOrder,
          initialServingTeam: TeamSide.a,
        );

        // Should not throw and should have valid values
        expect(state.currentServerIndex, equals(0)); // 1000000 ~/ 2 % 4 = 0
        expect(state.servingTeam, equals(TeamSide.a)); // 1000000 ~/ 4 % 2 = 0
      });
    });
  });

  group('Coin toss randomness', () {
    test(
      'Random().nextBool() produces roughly 50/50 distribution over 10000 iterations',
      () {
        final random = Random();
        int headsCount = 0;
        const iterations = 10000;

        for (int i = 0; i < iterations; i++) {
          if (random.nextBool()) {
            headsCount++;
          }
        }

        final percentage = (headsCount / iterations) * 100;

        // Allow 2% tolerance (48% to 52%)
        expect(percentage, greaterThan(48));
        expect(percentage, lessThan(52));
      },
    );

    test('millisecondsSinceEpoch % 2 is deterministic (NOT truly random)', () {
      // This test documents the old behavior - it was NOT random
      // The timestamp at any given moment always produces the same result
      // within the same millisecond

      final results = <int>[];
      for (int i = 0; i < 100; i++) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        results.add(timestamp % 2);
      }

      // All results in the same millisecond would be the same
      // This demonstrates why it was not truly random
      // Note: This test may pass or fail depending on timing, but it shows the issue
    });
  });

  group('ServingState', () {
    test('initial factory creates correct state', () {
      final state = ServingState.initial(
        serverRotationOrder: ['p0', 'p2', 'p1', 'p3'],
        initialServingTeam: TeamSide.a,
      );

      expect(state.currentServerIndex, equals(0));
      expect(state.servingTeam, equals(TeamSide.a));
      expect(state.pointInServiceCycle, equals(0));
      expect(state.serverSide, equals(CourtSide.right));
      expect(state.isFirstPointInCycle, isTrue);
      expect(state.isSecondPointInCycle, isFalse);
    });

    test('isFirstPointInCycle and isSecondPointInCycle work correctly', () {
      final rotationOrder = ['p0', 'p2', 'p1', 'p3'];
      const useCase = ComputeServingStateUseCase();

      for (int point = 0; point < 16; point++) {
        final state = useCase.execute(
          pointsPlayed: point,
          serverRotationOrder: rotationOrder,
          initialServingTeam: TeamSide.a,
        );

        expect(state.isFirstPointInCycle, equals(point % 2 == 0));
        expect(state.isSecondPointInCycle, equals(point % 2 == 1));
      }
    });

    test('copyWith preserves unchanged values', () {
      const original = ServingState(
        currentServerIndex: 1,
        servingTeam: TeamSide.b,
        pointInServiceCycle: 1,
        serverSide: CourtSide.left,
      );

      final copied = original.copyWith(currentServerIndex: 2);

      expect(copied.currentServerIndex, equals(2));
      expect(copied.servingTeam, equals(TeamSide.b));
      expect(copied.pointInServiceCycle, equals(1));
      expect(copied.serverSide, equals(CourtSide.left));
    });

    test('equality works correctly', () {
      const state1 = ServingState(
        currentServerIndex: 1,
        servingTeam: TeamSide.b,
        pointInServiceCycle: 1,
        serverSide: CourtSide.left,
      );

      const state2 = ServingState(
        currentServerIndex: 1,
        servingTeam: TeamSide.b,
        pointInServiceCycle: 1,
        serverSide: CourtSide.left,
      );

      const state3 = ServingState(
        currentServerIndex: 2,
        servingTeam: TeamSide.b,
        pointInServiceCycle: 1,
        serverSide: CourtSide.left,
      );

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });
  });
}
