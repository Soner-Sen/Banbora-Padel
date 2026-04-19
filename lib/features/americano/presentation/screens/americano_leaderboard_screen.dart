import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonrize_padel/core/design_system/design_system.dart';

import '../cubit/cubit.dart';

class AmericanoLeaderboardScreen extends StatelessWidget {
  const AmericanoLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<AmericanoCubit, AmericanoState>(
        builder: (context, state) {
          final leaderboard = state.leaderboard;
          final session = state.session;

          if (leaderboard == null || session == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Leaderboard')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          final sortedEntries = leaderboard.sortedByPoints;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Leaderboard'),
              actions: [
                IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
              ],
            ),
            body: Column(
              children: [
                // Header stats
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  color: AppColors.elevated,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        label: 'Runden',
                        value: '${session.totalRoundsPlayed}',
                      ),
                      _StatItem(
                        label: 'Spieler',
                        value: '${session.participants.length}',
                      ),
                      _StatItem(
                        label: 'Ziel',
                        value: '${session.targetPoints}',
                      ),
                    ],
                  ),
                ),

                // Leaderboard list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: sortedEntries.length,
                    itemBuilder: (context, index) {
                      final entry = sortedEntries[index];
                      final rank = index + 1;

                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          boxShadow: AppElevation.low,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          leading: _RankBadge(rank: rank),
                          title: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.primary.withValues(
                                  alpha: 0.1,
                                ),
                                child: Text(
                                  entry.participant.avatar.emoji,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  entry.participant.displayName,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${entry.totalPoints}',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'Punkte',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Stats summary
                Container(
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
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Fertig'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData? icon;

    switch (rank) {
      case 1:
        backgroundColor = const Color(0xFFFFD700); // Gold
        textColor = const Color(0xFF5D4E00);
        icon = Icons.emoji_events;
        break;
      case 2:
        backgroundColor = const Color(0xFFC0C0C0); // Silver
        textColor = const Color(0xFF4A4A4A);
        icon = Icons.emoji_events;
        break;
      case 3:
        backgroundColor = const Color(0xFFCD7F32); // Bronze
        textColor = Colors.white;
        icon = Icons.emoji_events;
        break;
      default:
        backgroundColor = AppColors.elevated;
        textColor = AppColors.textMuted;
        icon = null;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Center(
        child: icon != null
            ? Icon(icon, size: 20, color: textColor)
            : Text(
                '$rank',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}
