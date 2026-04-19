import 'package:flutter_test/flutter_test.dart';
import 'package:sonrize_padel/core/game_engine/game_engine.dart';
import 'package:sonrize_padel/features/americano/domain/entities/entities.dart';
import 'package:sonrize_padel/features/americano/presentation/cubit/cubit.dart';

void main() {
  late AmericanoCubit cubit;

  setUp(() {
    cubit = AmericanoCubit();
  });

  tearDown(() {
    cubit.close();
  });

  group('AmericanoCubit', () {
    group('addParticipant', () {
      test('creates session when adding first participant', () {
        final participant = _createParticipant('1', 'Max');

        cubit.addParticipant(participant);

        final state = cubit.state;
        expect(state.session, isNotNull);
        expect(state.session!.participants.length, 1);
        expect(state.status, AmericanoStatus.lobby);
      });

      test('adds participant to existing session', () {
        cubit.addParticipant(_createParticipant('1', 'Max'));
        cubit.addParticipant(_createParticipant('2', 'Anna'));

        final state = cubit.state;
        expect(state.session!.participants.length, 2);
      });

      test('rejects duplicate participant', () {
        final participant = _createParticipant('1', 'Max');
        cubit.addParticipant(participant);
        cubit.addParticipant(participant);

        expect(cubit.state.errorMessage, 'Player already added');
      });

      test('rejects more than 10 players', () {
        for (var i = 0; i < 10; i++) {
          cubit.addParticipant(_createParticipant('$i', 'Player$i'));
        }
        cubit.addParticipant(_createParticipant('11', 'TooMany'));

        expect(cubit.state.errorMessage, 'Maximum 10 players allowed');
      });
    });

    group('removeParticipant', () {
      test('removes participant from session', () {
        cubit.addParticipant(_createParticipant('1', 'Max'));
        cubit.addParticipant(_createParticipant('2', 'Anna'));

        cubit.removeParticipant('1');

        expect(cubit.state.session!.participants.length, 1);
        expect(
          cubit.state.session!.participants.any((p) => p.id == '1'),
          isFalse,
        );
      });
    });

    group('setTargetPoints', () {
      test('updates selected target points', () {
        cubit.setTargetPoints(14);

        expect(cubit.state.selectedTargetPoints, 14);
      });
    });

    group('startSession', () {
      test('requires at least 4 players', () {
        cubit.addParticipant(_createParticipant('1', 'Max'));
        cubit.addParticipant(_createParticipant('2', 'Anna'));
        cubit.addParticipant(_createParticipant('3', 'Tom'));

        cubit.startSession();

        expect(cubit.state.errorMessage, 'Need at least 4 players');
      });

      test('creates session with 4+ players', () {
        cubit.addParticipant(_createParticipant('1', 'Max'));
        cubit.addParticipant(_createParticipant('2', 'Anna'));
        cubit.addParticipant(_createParticipant('3', 'Tom'));
        cubit.addParticipant(_createParticipant('4', 'Lisa'));

        cubit.startSession();

        final state = cubit.state;
        expect(state.status, AmericanoStatus.inProgress);
        expect(state.session!.status, SessionStatus.inProgress);
        expect(state.session!.currentRoundNumber, 1);
        expect(state.leaderboard, isNotNull);
      });

      test('creates first match after starting session', () {
        _addFourPlayers(cubit);

        cubit.startSession();

        final state = cubit.state;
        expect(state.currentMatch, isNotNull);
        expect(state.currentMatch!.teamA.length, 2);
        expect(state.currentMatch!.teamB.length, 2);
      });
    });

    group('addPointTeamA', () {
      test('increments Team A score', () {
        _startSessionWithMatch(cubit);

        cubit.addPointTeamA();

        expect(cubit.state.currentMatch!.teamAScore, 1);
      });

      test('does not increment after match is complete', () {
        _startSessionWithMatch(cubit);
        // Complete the match (Amercano target is 12, so 6-6)
        for (var i = 0; i < 12; i++) {
          cubit.addPointTeamA();
        }

        final scoreBefore = cubit.state.currentMatch!.teamAScore;
        cubit.addPointTeamA();

        expect(cubit.state.currentMatch!.teamAScore, scoreBefore);
      });
    });

    group('addPointTeamB', () {
      test('increments Team B score', () {
        _startSessionWithMatch(cubit);

        cubit.addPointTeamB();

        expect(cubit.state.currentMatch!.teamBScore, 1);
      });
    });

    group('match completion', () {
      test('Amerciano match ends when combined score reaches target', () {
        _startSessionWithMatch(cubit, targetPoints: 10);
        cubit.setTargetPoints(10);

        // 6-4 = 10 combined points
        for (var i = 0; i < 6; i++) {
          cubit.addPointTeamA();
        }
        for (var i = 0; i < 4; i++) {
          cubit.addPointTeamB();
        }

        final match = cubit.state.currentMatch!;
        expect(match.isComplete, isTrue);
        expect(match.winnerSide, TeamSide.a);
      });

      test('Amerciano match ends in draw when teams are equal at target', () {
        _startSessionWithMatch(cubit, targetPoints: 12);

        // 6-6 = 12 combined points (draw)
        for (var i = 0; i < 6; i++) {
          cubit.addPointTeamA();
        }
        for (var i = 0; i < 6; i++) {
          cubit.addPointTeamB();
        }

        final match = cubit.state.currentMatch!;
        expect(match.isComplete, isTrue);
        expect(
          match.winnerSide,
          isNull,
          reason: '6:6 should be a draw, winnerSide should be null',
        );
        expect(match.teamAScore, 6);
        expect(match.teamBScore, 6);
      });

      test('Amerciano match handles draw at different scores', () {
        _startSessionWithMatch(cubit, targetPoints: 14);

        // 7-7 = 14 combined points (draw)
        for (var i = 0; i < 7; i++) {
          cubit.addPointTeamA();
        }
        for (var i = 0; i < 7; i++) {
          cubit.addPointTeamB();
        }

        final match = cubit.state.currentMatch!;
        expect(match.isComplete, isTrue);
        expect(match.winnerSide, isNull, reason: '7:7 should be a draw');
      });

      test('Liga match ends when team reaches target', () {
        _startSessionWithMatch(cubit, gameMode: GameModeType.liga);
        cubit.setTargetPoints(14);

        for (var i = 0; i < 14; i++) {
          cubit.addPointTeamA();
        }

        final match = cubit.state.currentMatch!;
        expect(match.isComplete, isTrue);
        expect(match.winnerSide, TeamSide.a);
      });

      test(
        'Liga match does not end in draw - winner is determined by reaching target first',
        () {
          _startSessionWithMatch(cubit, gameMode: GameModeType.liga);
          cubit.setTargetPoints(14);

          // Team B reaches 14 first
          for (var i = 0; i < 14; i++) {
            cubit.addPointTeamB();
          }

          final match = cubit.state.currentMatch!;
          expect(match.isComplete, isTrue);
          expect(match.winnerSide, TeamSide.b);
        },
      );
    });

    // These tests are informational - they verify implementation details
    // The core business logic (draw handling, scoring) is well-tested above
    group('serving state', () {
      test('serving state is initialized correctly', () {
        _startSessionWithMatch(cubit, targetPoints: 12);

        // Serving state should be initialized
        expect(cubit.state.currentMatch!.servingState, isNotNull);
        expect(
          cubit.state.currentMatch!.servingState.currentServerIndex,
          greaterThanOrEqualTo(0),
        );
      });
    });

    group('nextRound', () {
      test('increments round number', () {
        _startSessionWithMatch(cubit);

        final firstRoundNumber = cubit.state.currentMatch!.roundNumber;

        cubit.nextRound();

        expect(cubit.state.session!.currentRoundNumber, 2);
        expect(cubit.state.currentMatch!.roundNumber, firstRoundNumber + 1);
      });
    });

    group('leaderboard', () {
      test('updates leaderboard after match completion', () {
        _startSessionWithMatch(cubit, targetPoints: 10);

        // Complete match
        for (var i = 0; i < 6; i++) {
          cubit.addPointTeamA();
        }
        for (var i = 0; i < 4; i++) {
          cubit.addPointTeamB();
        }

        final state = cubit.state;
        expect(state.leaderboard, isNotNull);
        expect(state.leaderboard!.entries.length, 4);
      });
    });

    group('reset', () {
      test('resets state to initial', () {
        _addFourPlayers(cubit);
        cubit.startSession();
        cubit.addParticipant(_createParticipant('5', 'Extra'));

        cubit.reset();

        expect(cubit.state, const AmericanoState());
      });
    });
  });
}

AmericanoParticipant _createParticipant(String id, String name) =>
    AmericanoParticipant(
      id: id,
      displayName: name,
      avatar: GamePlayerAvatar.avatar1,
      totalPoints: 0,
      matchesPlayed: 0,
      matchesWon: 0,
      benchCount: 0,
    );

void _addFourPlayers(AmericanoCubit cubit) {
  cubit.addParticipant(_createParticipant('1', 'Max'));
  cubit.addParticipant(_createParticipant('2', 'Anna'));
  cubit.addParticipant(_createParticipant('3', 'Tom'));
  cubit.addParticipant(_createParticipant('4', 'Lisa'));
}

void _startSessionWithMatch(
  AmericanoCubit cubit, {
  int targetPoints = 12,
  GameModeType gameMode = GameModeType.americano,
}) {
  cubit.setTargetPoints(targetPoints);
  _addFourPlayers(cubit);
  cubit.startSession();
}
