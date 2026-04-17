import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonrize_padel/core/design_system/design_system.dart';
import 'package:sonrize_padel/core/design_system/app_widgets.dart';
import 'package:sonrize_padel/core/design_system/widgets/padel_court_widget.dart';
import 'package:sonrize_padel/core/design_system/widgets/score_buttons.dart';
import 'package:sonrize_padel/features/orbit/presentation/cubit/orbit_cubit.dart';
import 'package:sonrize_padel/features/orbit/presentation/cubit/orbit_state.dart';

class OrbitLobbyScreen extends StatefulWidget {
  const OrbitLobbyScreen({
    required this.mode,
    required this.targetPoints,
    required this.players,
    super.key,

    this.joinCode,
  });

  final String mode;
  final int targetPoints;
  final List<String> players;
  final String? joinCode;

  @override
  State<OrbitLobbyScreen> createState() => _OrbitLobbyScreenState();
}

class _OrbitLobbyScreenState extends State<OrbitLobbyScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize orbit session
    context.read<OrbitCubit>().initializeSession(
      mode: widget.mode,
      targetPoints: widget.targetPoints,
      players: widget.players,
    );
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<OrbitCubit, OrbitState>(
    listener: (context, state) {
      if (state.status == OrbitStatus.roundComplete) {
        _showRoundCompleteDialog(state);
      }
    },
    builder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Orbit'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _shareSession,
            tooltip: 'Session teilen',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildScoreSection(state),
            _buildCourtSection(state),
            _buildQueueSection(state),
            _buildScoreButtons(state),
          ],
        ),
      ),
    ),
  );

  Widget _buildScoreSection(OrbitState state) => Container(
    padding: const EdgeInsets.all(DesignTokens.spacing16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ScoreIndicator(
          teamName: 'Team A',
          score: state.teamAScore,
          color: DesignTokens.teamA,
        ),
        Column(
          children: [
            Text(
              'Ziel: ${widget.targetPoints}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: DesignTokens.textSecondary,
              ),
            ),
            Text(
              'Runde ${state.currentRound}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        _ScoreIndicator(
          teamName: 'Team B',
          score: state.teamBScore,
          color: DesignTokens.teamB,
        ),
      ],
    ),
  );

  Widget _buildCourtSection(OrbitState state) {
    final teamAPositions = [
      PlayerPosition(
        name: state.teamAPlayer1,
        x: 30,
        y: 30,
        initials: state.teamAPlayer1.isNotEmpty
            ? state.teamAPlayer1[0].toUpperCase()
            : '?',
      ),
      PlayerPosition(
        name: state.teamAPlayer2,
        x: 30,
        y: 100,
        initials: state.teamAPlayer2.isNotEmpty
            ? state.teamAPlayer2[0].toUpperCase()
            : '?',
      ),
    ];

    final teamBPositions = [
      PlayerPosition(
        name: state.teamBPlayer1,
        x: 180,
        y: 30,
        initials: state.teamBPlayer1.isNotEmpty
            ? state.teamBPlayer1[0].toUpperCase()
            : '?',
      ),
      PlayerPosition(
        name: state.teamBPlayer2,
        x: 180,
        y: 100,
        initials: state.teamBPlayer2.isNotEmpty
            ? state.teamBPlayer2[0].toUpperCase()
            : '?',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacing16),
      child: PadelCourtWidget(
        teamAPositions: teamAPositions,
        teamBPositions: teamBPositions,
        serverIndex: state.serverIndex,
        width: 280,
        height: 180,
      ),
    );
  }

  Widget _buildQueueSection(OrbitState state) => Container(
    padding: const EdgeInsets.all(DesignTokens.spacing16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.people_outline,
              size: 20,
              color: DesignTokens.textSecondary,
            ),
            const SizedBox(width: DesignTokens.spacing8),
            Text(
              'Warteschlange',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              '${state.waitingPlayers.length} warten',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: DesignTokens.textMuted),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.spacing12),
        if (state.waitingPlayers.isEmpty)
          Container(
            padding: const EdgeInsets.all(DesignTokens.spacing16),
            decoration: BoxDecoration(
              color: DesignTokens.elevated,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: DesignTokens.success,
                  size: 20,
                ),
                const SizedBox(width: DesignTokens.spacing8),
                Text(
                  'Alle Spieler sind auf dem Court!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: DesignTokens.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: state.waitingPlayers
                  .map(
                    (player) => Padding(
                      padding: const EdgeInsets.only(
                        right: DesignTokens.spacing8,
                      ),
                      child: _WaitingPlayerChip(name: player),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    ),
  );

  Widget _buildScoreButtons(OrbitState state) => Padding(
    padding: const EdgeInsets.all(DesignTokens.spacing16),
    child: ScoreButtons(
      onTeamAScore: () {
        HapticFeedback.mediumImpact();
        context.read<OrbitCubit>().scorePoint(isTeamA: true);
      },
      onTeamBScore: () {
        HapticFeedback.mediumImpact();
        context.read<OrbitCubit>().scorePoint(isTeamA: false);
      },
      onUndo: state.canUndo
          ? () => context.read<OrbitCubit>().undoLastPoint()
          : null,
    ),
  );

  void _shareSession() {
    const code = 'ABC123'; // TODO: Generate real code
    Clipboard.setData(const ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code $code in Zwischenablage kopiert'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session verlassen?'),
        content: const Text('Deine Session wird beendet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/welcome');
            },
            child: const Text(
              'Verlassen',
              style: TextStyle(color: DesignTokens.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showRoundCompleteDialog(OrbitState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Runde beendet!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Team A: ${state.teamAScore}'),
            Text('Team B: ${state.teamBScore}'),
            const SizedBox(height: DesignTokens.spacing16),
            const Text('Nächste Runde wird berechnet...'),
          ],
        ),
        actions: [
          AppButton(
            label: 'Weiter',
            onPressed: () {
              Navigator.pop(context);
              context.read<OrbitCubit>().startNextRound();
            },
          ),
        ],
      ),
    );
  }
}

class _ScoreIndicator extends StatelessWidget {
  const _ScoreIndicator({
    required this.teamName,
    required this.score,
    required this.color,
  });

  final String teamName;
  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        score.toString(),
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      Text(
        teamName,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: DesignTokens.textSecondary),
      ),
    ],
  );
}

class _WaitingPlayerChip extends StatelessWidget {
  const _WaitingPlayerChip({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: DesignTokens.spacing12,
      vertical: DesignTokens.spacing8,
    ),
    decoration: BoxDecoration(
      color: DesignTokens.elevated,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      border: Border.all(color: DesignTokens.surfaceVariant),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: DesignTokens.textMuted.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: DesignTokens.textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: DesignTokens.spacing8),
        Text(
          name,
          style: const TextStyle(color: DesignTokens.textPrimary, fontSize: 14),
        ),
      ],
    ),
  );
}
