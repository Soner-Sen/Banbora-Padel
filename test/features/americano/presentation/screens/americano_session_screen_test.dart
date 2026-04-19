import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonrize_padel/core/game_engine/game_engine.dart';
import 'package:sonrize_padel/core/design_system/design_system.dart';
import 'package:sonrize_padel/features/americano/domain/entities/entities.dart';
import 'package:sonrize_padel/features/americano/presentation/cubit/cubit.dart';
import 'package:sonrize_padel/features/americano/presentation/screens/americano_session_screen.dart';

void main() {
  group('AmericanoSessionScreen', () {
    late AmericanoCubit cubit;

    setUp(() {
      cubit = AmericanoCubit();
    });

    tearDown(() {
      cubit.close();
    });

    Widget buildTestWidget() => MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      ),
      home: BlocProvider.value(
        value: cubit,
        child: const AmericanoSessionScreen(),
      ),
    );

    group('rendering', () {
      testWidgets('shows loading when no match exists', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('renders score header with team scores', (tester) async {
        _startSessionWithMatch(cubit);
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Team A'), findsOneWidget);
        expect(find.text('Team B'), findsOneWidget);
        expect(find.text('VS'), findsOneWidget);
      });

      testWidgets('renders tap zones for both teams', (tester) async {
        _startSessionWithMatch(cubit);
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('+ Punkt Team A'), findsOneWidget);
        expect(find.text('+ Punkt Team B'), findsOneWidget);
      });

      testWidgets('shows player avatars with serving indicator', (
        tester,
      ) async {
        _startSessionWithMatch(cubit);
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Should find CircleAvatars for players
        expect(find.byType(CircleAvatar), findsWidgets);
      });

      testWidgets('shows bench section when bench players exist', (
        tester,
      ) async {
        _startSessionWithMatch(cubit);
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Bench section appears when there are bench players
        expect(find.text('Bank'), findsOneWidget);
      });
    });

    group('interaction', () {
      testWidgets('tapping Team A zone adds point to Team A', (tester) async {
        _startSessionWithMatch(cubit);
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('+ Punkt Team A'));
        await tester.pumpAndSettle();

        final state = cubit.state;
        expect(state.currentMatch!.teamAScore, 1);
      });

      testWidgets('tapping Team B zone adds point to Team B', (tester) async {
        _startSessionWithMatch(cubit);
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('+ Punkt Team B'));
        await tester.pumpAndSettle();

        final state = cubit.state;
        expect(state.currentMatch!.teamBScore, 1);
      });
    });

    group('match completion', () {
      testWidgets('shows winner banner when match is complete', (tester) async {
        _startSessionWithMatch(cubit, targetPoints: 4);

        // Complete match: 2-2 = 4 combined points
        cubit.addPointTeamA();
        cubit.addPointTeamA();
        cubit.addPointTeamB();
        cubit.addPointTeamB();

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Winner banner should appear
        expect(
          find.byWidgetPredicate(
            (w) =>
                w is Container &&
                w.decoration is BoxDecoration &&
                (w.decoration as BoxDecoration).gradient != null,
          ),
          findsWidgets,
        );
      });

      testWidgets('shows action buttons when match is complete', (
        tester,
      ) async {
        _startSessionWithMatch(cubit, targetPoints: 4);

        // Complete match
        for (var i = 0; i < 4; i++) {
          cubit.addPointTeamA();
        }

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Nächste Runde'), findsOneWidget);
        expect(find.text('Leaderboard'), findsWidgets);
      });

      testWidgets('shows Leaderboard & Beenden button when match is complete', (
        tester,
      ) async {
        _startSessionWithMatch(cubit, targetPoints: 4);

        // Complete match
        for (var i = 0; i < 4; i++) {
          cubit.addPointTeamA();
        }

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Leaderboard & Beenden'), findsOneWidget);
      });

      testWidgets('hides tap zones when match is complete', (tester) async {
        _startSessionWithMatch(cubit, targetPoints: 4);

        // Complete match
        for (var i = 0; i < 4; i++) {
          cubit.addPointTeamA();
        }

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('+ Punkt Team A'), findsNothing);
        expect(find.text('+ Punkt Team B'), findsNothing);
      });
    });

    group('app bar', () {
      testWidgets('shows round number in title', (tester) async {
        _startSessionWithMatch(cubit);
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Runde 1'), findsOneWidget);
      });

      testWidgets('has info button to show rules', (tester) async {
        _startSessionWithMatch(cubit);
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.info_outline), findsOneWidget);
      });

      testWidgets('has leaderboard button', (tester) async {
        _startSessionWithMatch(cubit);
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.leaderboard), findsOneWidget);
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

void _startSessionWithMatch(AmericanoCubit cubit, {int targetPoints = 12}) {
  cubit.setTargetPoints(targetPoints);
  _addFourPlayers(cubit);
  cubit.startSession();
}
