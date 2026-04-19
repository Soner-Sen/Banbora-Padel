import 'package:flutter_test/flutter_test.dart';
import 'package:sonrize_padel/core/game_engine/game_engine.dart';
import 'package:sonrize_padel/features/americano/domain/entities/court_position.dart';
import 'package:sonrize_padel/features/americano/domain/entities/serving_state.dart';
import 'package:sonrize_padel/features/americano/domain/entities/americano_participant.dart';

void main() {
  group('CourtPosition', () {
    late List<AmericanoParticipant> teamA;
    late List<AmericanoParticipant> teamB;
    late CourtPositionHelper helper;

    setUp(() {
      teamA = [
        const AmericanoParticipant(
          id: 'player0',
          displayName: 'Player 0',
          avatar: GamePlayerAvatar.avatar1,
          skillLevel: 3,
        ),
        const AmericanoParticipant(
          id: 'player1',
          displayName: 'Player 1',
          avatar: GamePlayerAvatar.avatar2,
          skillLevel: 3,
        ),
      ];
      teamB = [
        const AmericanoParticipant(
          id: 'player2',
          displayName: 'Player 2',
          avatar: GamePlayerAvatar.avatar3,
          skillLevel: 3,
        ),
        const AmericanoParticipant(
          id: 'player3',
          displayName: 'Player 3',
          avatar: GamePlayerAvatar.avatar4,
          skillLevel: 3,
        ),
      ];
      helper = const CourtPositionHelper();
    });

    test('initial position: server on right, partner on left', () {
      final serverRotationOrder = ['player0', 'player2', 'player1', 'player3'];
      final servingState = ServingState.initial(
        serverRotationOrder: serverRotationOrder,
        initialServingTeam: TeamSide.a,
      );

      final courtPosition = helper.compute(
        teamA: teamA,
        teamB: teamB,
        servingState: servingState,
        serverRotationOrder: serverRotationOrder,
      );

      // Server (player0) should be on right for Team A
      expect(courtPosition.teamARightPlayerId, equals('player0'));
      // Partner (player1) should be on left for Team A
      expect(courtPosition.teamALeftPlayerId, equals('player1'));
    });

    test('second point: server and partner swap sides', () {
      final serverRotationOrder = ['player0', 'player2', 'player1', 'player3'];
      // Point 1: server index 1 (player2), teamB serving
      const servingState = ServingState(
        currentServerIndex: 1,
        servingTeam: TeamSide.b,
        pointInServiceCycle: 1,
        serverSide: CourtSide.left,
      );

      final courtPosition = helper.compute(
        teamA: teamA,
        teamB: teamB,
        servingState: servingState,
        serverRotationOrder: serverRotationOrder,
      );

      // Server (player2) should now be on left for Team B
      expect(courtPosition.teamBLeftPlayerId, equals('player2'));
      // Partner (player3) should be on right for Team B
      expect(courtPosition.teamBRightPlayerId, equals('player3'));
    });

    test('getPlayerId returns correct player for team and side', () {
      const courtPosition = CourtPosition(
        teamALeftPlayerId: 'player0',
        teamARightPlayerId: 'player1',
        teamBLeftPlayerId: 'player2',
        teamBRightPlayerId: 'player3',
      );

      expect(
        courtPosition.getPlayerId(TeamSide.a, CourtSide.left),
        equals('player0'),
      );
      expect(
        courtPosition.getPlayerId(TeamSide.a, CourtSide.right),
        equals('player1'),
      );
      expect(
        courtPosition.getPlayerId(TeamSide.b, CourtSide.left),
        equals('player2'),
      );
      expect(
        courtPosition.getPlayerId(TeamSide.b, CourtSide.right),
        equals('player3'),
      );
    });

    test('equality works correctly', () {
      const position1 = CourtPosition(
        teamALeftPlayerId: 'player0',
        teamARightPlayerId: 'player1',
        teamBLeftPlayerId: 'player2',
        teamBRightPlayerId: 'player3',
      );

      const position2 = CourtPosition(
        teamALeftPlayerId: 'player0',
        teamARightPlayerId: 'player1',
        teamBLeftPlayerId: 'player2',
        teamBRightPlayerId: 'player3',
      );

      const position3 = CourtPosition(
        teamALeftPlayerId: 'player1', // Different
        teamARightPlayerId: 'player0', // Different
        teamBLeftPlayerId: 'player2',
        teamBRightPlayerId: 'player3',
      );

      expect(position1, equals(position2));
      expect(position1, isNot(equals(position3)));
    });

    test('copyWith creates new instance with updated values', () {
      const original = CourtPosition(
        teamALeftPlayerId: 'player0',
        teamARightPlayerId: 'player1',
        teamBLeftPlayerId: 'player2',
        teamBRightPlayerId: 'player3',
      );

      final updated = original.copyWith(teamALeftPlayerId: 'player1');

      expect(updated.teamALeftPlayerId, equals('player1'));
      expect(updated.teamARightPlayerId, equals('player1')); // Unchanged
      expect(updated.teamBLeftPlayerId, equals('player2')); // Unchanged
      expect(updated.teamBRightPlayerId, equals('player3')); // Unchanged
    });

    test('hashCode is consistent with equality', () {
      const position1 = CourtPosition(
        teamALeftPlayerId: 'player0',
        teamARightPlayerId: 'player1',
        teamBLeftPlayerId: 'player2',
        teamBRightPlayerId: 'player3',
      );

      const position2 = CourtPosition(
        teamALeftPlayerId: 'player0',
        teamARightPlayerId: 'player1',
        teamBLeftPlayerId: 'player2',
        teamBRightPlayerId: 'player3',
      );

      expect(position1.hashCode, equals(position2.hashCode));
    });

    test('court position changes when server changes (every 2 points)', () {
      final serverRotationOrder = ['player0', 'player2', 'player1', 'player3'];

      // Point 0: player0 serving on right
      final position0 = helper.compute(
        teamA: teamA,
        teamB: teamB,
        servingState: const ServingState(
          currentServerIndex: 0,
          servingTeam: TeamSide.a,
          pointInServiceCycle: 0,
          serverSide: CourtSide.right,
        ),
        serverRotationOrder: serverRotationOrder,
      );

      // Point 1: player0 serving on left (swapped with partner)
      final position1 = helper.compute(
        teamA: teamA,
        teamB: teamB,
        servingState: const ServingState(
          currentServerIndex: 0,
          servingTeam: TeamSide.a,
          pointInServiceCycle: 1,
          serverSide: CourtSide.left,
        ),
        serverRotationOrder: serverRotationOrder,
      );

      // Positions should be different
      expect(position0, isNot(equals(position1)));

      // Player0 should be on different sides
      expect(
        position0.teamARightPlayerId == 'player0' ||
            position0.teamALeftPlayerId == 'player0',
        isTrue,
      );
      expect(
        position1.teamARightPlayerId == 'player0' ||
            position1.teamALeftPlayerId == 'player0',
        isTrue,
      );
    });
  });

  group('CourtPositionHelper', () {
    late CourtPositionHelper helper;

    setUp(() {
      helper = const CourtPositionHelper();
    });

    test('getServer returns correct server participant', () {
      final teamA = [
        const AmericanoParticipant(
          id: 'player0',
          displayName: 'Player 0',
          avatar: GamePlayerAvatar.avatar1,
          skillLevel: 3,
        ),
        const AmericanoParticipant(
          id: 'player1',
          displayName: 'Player 1',
          avatar: GamePlayerAvatar.avatar2,
          skillLevel: 3,
        ),
      ];
      final teamB = [
        const AmericanoParticipant(
          id: 'player2',
          displayName: 'Player 2',
          avatar: GamePlayerAvatar.avatar3,
          skillLevel: 3,
        ),
        const AmericanoParticipant(
          id: 'player3',
          displayName: 'Player 3',
          avatar: GamePlayerAvatar.avatar4,
          skillLevel: 3,
        ),
      ];

      final serverRotationOrder = ['player0', 'player2', 'player1', 'player3'];
      final servingState = ServingState.initial(
        serverRotationOrder: serverRotationOrder,
        initialServingTeam: TeamSide.a,
      );

      final server = helper.getServer(
        teamA: teamA,
        teamB: teamB,
        servingState: servingState,
        serverRotationOrder: serverRotationOrder,
      );

      expect(server?.id, equals('player0'));
    });

    test('throws error for insufficient team members', () {
      final teamA = [
        const AmericanoParticipant(
          id: 'player0',
          displayName: 'Player 0',
          avatar: GamePlayerAvatar.avatar1,
          skillLevel: 3,
        ),
      ];
      final teamB = [
        const AmericanoParticipant(
          id: 'player2',
          displayName: 'Player 2',
          avatar: GamePlayerAvatar.avatar3,
          skillLevel: 3,
        ),
      ];

      final serverRotationOrder = ['player0', 'player2', 'player1', 'player3'];
      final servingState = ServingState.initial(
        serverRotationOrder: serverRotationOrder,
        initialServingTeam: TeamSide.a,
      );

      expect(
        () => helper.compute(
          teamA: teamA,
          teamB: teamB,
          servingState: servingState,
          serverRotationOrder: serverRotationOrder,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
