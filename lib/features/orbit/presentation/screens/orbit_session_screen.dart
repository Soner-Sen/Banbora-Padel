import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/entities.dart';
import '../cubit/orbit_session_cubit.dart';
import '../cubit/orbit_session_state.dart';
import '../widgets/widgets.dart';

class OrbitSessionScreen extends StatelessWidget {
  const OrbitSessionScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<OrbitSessionCubit, OrbitSessionState>(
        builder: (context, state) {
          if (state.currentRound == null) {
            return const Scaffold(
              backgroundColor: Color(0xFF1B5E20),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            backgroundColor: const Color(0xFF1B5E20),
            appBar: _buildAppBar(context, state),
            body: _buildBody(context, state),
          );
        },
      );

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    OrbitSessionState state,
  ) => AppBar(
    backgroundColor: Colors.black26,
    title: Column(
      children: [
        const Text('Orbit', style: TextStyle(color: Colors.white)),
        Text(
          'Runde ${state.currentRound!.roundNumber}',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    ),
    centerTitle: true,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => _showExitConfirmation(context),
    ),
    actions: [
      if (state.canUndo)
        IconButton(
          icon: const Icon(Icons.undo, color: Colors.amber),
          onPressed: () => context.read<OrbitSessionCubit>().undoLastPoint(),
        ),
      IconButton(
        icon: const Icon(Icons.people, color: Colors.white),
        onPressed: () => _showLeaderboard(context, state),
      ),
    ],
  );

  Widget _buildBody(BuildContext context, OrbitSessionState state) {
    final round = state.currentRound!;

    if (state.status == OrbitSessionStatus.roundComplete) {
      return _buildRoundCompleteView(context, state);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (state.lastPairingReason != null)
            _buildPairingReason(state.lastPairingReason!),
          const SizedBox(height: 16),
          CourtViewWidget(
            round: round,
            onTeamAScore: () {
              HapticFeedback.mediumImpact();
              final scorer = round.teamA.players[0];
              context.read<OrbitSessionCubit>().scorePointForTeamA(scorer);
            },
            onTeamBScore: () {
              HapticFeedback.mediumImpact();
              final scorer = round.teamB.players[0];
              context.read<OrbitSessionCubit>().scorePointForTeamB(scorer);
            },
          ),
          const SizedBox(height: 16),
          BenchWidget(
            benchPlayers: round.bench,
            nextUpReason: state.lastPairingReason,
          ),
          const SizedBox(height: 16),
          LeaderboardWidget(entries: state.leaderboard),
        ],
      ),
    );
  }

  Widget _buildPairingReason(String reason) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.amber.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.shuffle, color: Colors.amber, size: 16),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            reason,
            style: const TextStyle(color: Colors.amber, fontSize: 12),
          ),
        ),
      ],
    ),
  );

  Widget _buildRoundCompleteView(
    BuildContext context,
    OrbitSessionState state,
  ) {
    final round = state.currentRound!;
    final winningTeam = round.score.teamAPoints >= round.score.targetPoints
        ? round.teamA
        : round.teamB;
    final winningPoints = winningTeam == round.teamA
        ? round.score.teamAPoints
        : round.score.teamBPoints;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.celebration, color: Colors.amber, size: 64),
            const SizedBox(height: 24),
            const Text(
              'Runde beendet!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Team ${winningTeam.side == TeamSide.a ? 'A' : 'B'} gewinnt mit $winningPoints Punkten',
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () =>
                  context.read<OrbitSessionCubit>().startNextRound(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'Nächste Runde',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.read<OrbitSessionCubit>().endSession(),
              child: const Text(
                'Session beenden',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLeaderboard(BuildContext context, OrbitSessionState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2E7D32),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<OrbitSessionCubit>(),
        child: BlocBuilder<OrbitSessionCubit, OrbitSessionState>(
          builder: (context, currentState) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Rangliste',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                LeaderboardWidget(entries: currentState.leaderboard),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text(
          'Session verlassen?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Möchtest du diese Session wirklich beenden?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Abbrechen',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<OrbitSessionCubit>().resetSession();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Beenden', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
