import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonrize_padel/core/design_system/design_system.dart';
import 'package:sonrize_padel/core/game_engine/game_engine.dart';

import '../../domain/entities/entities.dart';
import '../cubit/cubit.dart';
import '../widgets/widgets.dart';
import 'americano_leaderboard_screen.dart';

class AmericanoSessionScreen extends StatelessWidget {
  const AmericanoSessionScreen({super.key});

  void _showInfoSheet(BuildContext context, AmericanoState state) {
    final isAmericano = state.gameMode == GameModeType.americano;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.bottomSheet),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.elevated,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              isAmericano ? 'Americano Regeln' : 'Liga Regeln',
              style: Theme.of(ctx).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            if (isAmericano) ...[
              _buildRuleItem(
                ctx,
                Icons.stars,
                'Kombinierte Punkte',
                'Gespielt wird bis ${state.selectedTargetPoints} kombinierte Punkte',
              ),
              _buildRuleItem(
                ctx,
                Icons.sync,
                'Beispiel',
                'Bei Ziel 12: 6:6, 11:1, 4:8',
              ),
              _buildRuleItem(
                ctx,
                Icons.person,
                'Punkte sammeln',
                'Deine Punkte = Dein Match-Ergebnis',
              ),
              _buildRuleItem(
                ctx,
                Icons.emoji_events,
                'Gewinner',
                'Wer die meisten Punkte hat',
              ),
            ] else ...[
              _buildRuleItem(
                ctx,
                Icons.flag,
                'First to',
                'Spiel endet wenn ein Team ${state.selectedTargetPoints} Punkte erreicht',
              ),
              _buildRuleItem(
                ctx,
                Icons.sync,
                'Beispiel',
                'Bei Ziel 14: 14:0, 14:9',
              ),
              _buildRuleItem(
                ctx,
                Icons.emoji_events,
                'Siege zählen',
                'Meiste Siege = besser',
              ),
              _buildRuleItem(
                ctx,
                Icons.balance,
                'Unentschieden',
                'Draws möglich',
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.accentMint.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  const Icon(Icons.touch_app, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Tippe auf das Team, das den Punkt gemacht hat',
                      style: Theme.of(ctx).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom + AppSpacing.md),
          ],
        ),
      ),
    );
  }

  static Widget _buildRuleItem(
    BuildContext ctx,
    IconData icon,
    String title,
    String description,
  ) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(ctx).textTheme.titleMedium),
              Text(
                description,
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<AmericanoCubit, AmericanoState>(
        builder: (context, state) {
          final match = state.currentMatch;
          if (match == null) {
            return Scaffold(
              appBar: AppBar(title: Text(state.gameMode.displayName)),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: Text('Runde ${match.roundNumber}'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => _showInfoSheet(context, state),
                ),
                IconButton(
                  icon: const Icon(Icons.leaderboard),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<AmericanoCubit>(),
                          child: const AmericanoLeaderboardScreen(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Score header
                    _ScoreHeader(match: match, state: state),

                    // Court view
                    SizedBox(
                      height: 400,
                      child: _CourtWithPlayers(match: match, state: state),
                    ),

                    // Bench (waiting players)
                    if (match.benchPlayers.isNotEmpty)
                      BenchSectionWidget(players: match.benchPlayers),

                    // Match complete actions
                    if (match.isComplete) _MatchCompleteActions(state: state),
                  ],
                ),
              ),
            ),
          );
        },
      );
}

class _ScoreHeader extends StatelessWidget {
  const _ScoreHeader({required this.match, required this.state});

  final AmericanoMatch match;
  final AmericanoState state;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    color: AppColors.elevated,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Team A score
        ScoreBoxWidget(
          score: match.teamAScore,
          teamSide: TeamSide.a,
          isWinner: match.winnerSide == TeamSide.a,
        ),
        const SizedBox(width: AppSpacing.lg),
        // VS
        Column(
          children: [
            Text(
              'VS',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.textMuted),
            ),
            if (state.gameMode == GameModeType.americano)
              Text(
                '${match.teamAScore + match.teamBScore}/${state.selectedTargetPoints}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.lg),
        // Team B score
        ScoreBoxWidget(
          score: match.teamBScore,
          teamSide: TeamSide.b,
          isWinner: match.winnerSide == TeamSide.b,
        ),
      ],
    ),
  );
}

class _CourtWithPlayers extends StatelessWidget {
  const _CourtWithPlayers({required this.match, required this.state});

  final AmericanoMatch match;
  final AmericanoState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AmericanoCubit>();
    final isMatchComplete = match.isComplete;

    return LayoutBuilder(
      builder: (context, constraints) => Column(
        children: [
          // Team A players (positioned ABOVE tap zone)
          _TeamPlayersRow(
            players: match.teamA,
            isTeamA: true,
            courtPosition: match.courtPosition,
            servingPlayerId: match.currentServer?.id,
          ),

          // Team A tap zone (top half)
          Expanded(
            child: GestureDetector(
              onTap: isMatchComplete ? null : () => cubit.addPointTeamA(),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.teamA.withValues(
                    alpha: isMatchComplete ? 0.05 : 0.1,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.teamA, width: 2),
                ),
                child: Stack(
                  children: [
                    // Court lines
                    CustomPaint(
                      size: Size(constraints.maxWidth - 16, double.infinity),
                      painter: const HalfCourtPainter(isTopHalf: true),
                    ),
                    // Tap hint (moved to center, below players)
                    if (!isMatchComplete)
                      Positioned(
                        bottom: AppSpacing.md,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.teamA.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                            ),
                            child: const Text(
                              '+ Punkt Team A',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (isMatchComplete)
                      const Center(
                        child: Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: 48,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Net indicator
          Container(
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                const Expanded(
                  child: Divider(color: AppColors.courtNet, thickness: 3),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.courtNet,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.network_check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const Expanded(
                  child: Divider(color: AppColors.courtNet, thickness: 3),
                ),
              ],
            ),
          ),

          // Team B tap zone (bottom half)
          Expanded(
            child: GestureDetector(
              onTap: isMatchComplete ? null : () => cubit.addPointTeamB(),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.teamB.withValues(
                    alpha: isMatchComplete ? 0.05 : 0.1,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.teamB, width: 2),
                ),
                child: Stack(
                  children: [
                    // Court lines
                    CustomPaint(
                      size: Size(constraints.maxWidth - 16, double.infinity),
                      painter: const HalfCourtPainter(isTopHalf: false),
                    ),
                    // Tap hint (moved to center, above players)
                    if (!isMatchComplete)
                      Positioned(
                        top: AppSpacing.md,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.teamB.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                            ),
                            child: const Text(
                              '+ Punkt Team B',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (isMatchComplete)
                      const Center(
                        child: Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: 48,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Team B players (positioned BELOW tap zone)
          _TeamPlayersRow(
            players: match.teamB,
            isTeamA: false,
            courtPosition: match.courtPosition,
            servingPlayerId: match.currentServer?.id,
          ),
        ],
      ),
    );
  }
}

class _TeamPlayersRow extends StatelessWidget {
  const _TeamPlayersRow({
    required this.players,
    required this.isTeamA,
    required this.courtPosition,
    this.servingPlayerId,
  });

  final List<AmericanoParticipant> players;
  final bool isTeamA;
  final CourtPosition courtPosition;
  final String? servingPlayerId;

  AmericanoParticipant? _getParticipantById(String id) => players
      .cast<AmericanoParticipant?>()
      .firstWhere((p) => p?.id == id, orElse: () => null);

  @override
  Widget build(BuildContext context) {
    if (players.length < 2) {
      return const SizedBox(height: 60);
    }

    final teamColor = isTeamA ? AppColors.teamA : AppColors.teamB;

    // Get left and right player IDs from courtPosition
    final leftPlayerId = isTeamA
        ? courtPosition.teamALeftPlayerId
        : courtPosition.teamBLeftPlayerId;
    final rightPlayerId = isTeamA
        ? courtPosition.teamARightPlayerId
        : courtPosition.teamBRightPlayerId;

    // Look up participant objects
    final leftPlayer = _getParticipantById(leftPlayerId);
    final rightPlayer = _getParticipantById(rightPlayerId);

    if (leftPlayer == null || rightPlayer == null) {
      return const SizedBox(height: 60);
    }

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: IgnorePointer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            PlayerAvatarWidget(
              player: leftPlayer,
              color: teamColor,
              isServing: servingPlayerId == leftPlayerId,
            ),
            const SizedBox(width: AppSpacing.lg),
            PlayerAvatarWidget(
              player: rightPlayer,
              color: teamColor,
              isServing: servingPlayerId == rightPlayerId,
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchCompleteActions extends StatelessWidget {
  const _MatchCompleteActions({required this.state});

  final AmericanoState state;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(
      AppSpacing.md,
      AppSpacing.md,
      AppSpacing.md,
      MediaQuery.of(context).padding.bottom + AppSpacing.md,
    ),
    decoration: BoxDecoration(
      color: AppColors.surface,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, -4),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: state.currentMatch?.winnerSide == null
                  ? [
                      AppColors.textMuted,
                      AppColors.textMuted.withValues(alpha: 0.8),
                    ]
                  : [AppColors.winner, AppColors.winner.withValues(alpha: 0.8)],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                state.currentMatch?.winnerSide == null
                    ? Icons.balance
                    : Icons.emoji_events,
                color: AppColors.onPrimary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  state.currentMatch?.winnerSide == null
                      ? 'Unentschieden!'
                      : state.currentMatch?.winnerSide == TeamSide.a
                      ? 'Team A gewinnt!'
                      : 'Team B gewinnt!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<AmericanoCubit>(),
                        child: const AmericanoLeaderboardScreen(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.leaderboard, size: 18),
                label: const Text('Leaderboard'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.read<AmericanoCubit>().nextRound(),
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Nächste Runde'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<AmericanoCubit>(),
                  child: const AmericanoLeaderboardScreen(),
                ),
              ),
            );
          },
          icon: const Icon(Icons.emoji_events, size: 18),
          label: const Text('Fertig'),
        ),
      ],
    ),
  );
}
