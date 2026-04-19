import 'package:flutter/material.dart';
import 'package:sonrize_padel/core/design_system/design_system.dart';
import '../../domain/entities/entities.dart';

class BenchSectionWidget extends StatelessWidget {
  const BenchSectionWidget({required this.players, super.key});

  final List<AmericanoParticipant> players;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xxs,
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: AppColors.elevated,
      borderRadius: BorderRadius.circular(AppRadius.md),
      border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.3)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.people_outline,
              size: 14,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              'Bank',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxs),
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: players.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
            itemBuilder: (context, index) =>
                _BenchPlayerItem(player: players[index]),
          ),
        ),
      ],
    ),
  );
}

class _BenchPlayerItem extends StatelessWidget {
  const _BenchPlayerItem({required this.player});

  final AmericanoParticipant player;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      CircleAvatar(
        radius: 16,
        backgroundColor: AppColors.textMuted.withValues(alpha: 0.2),
        child: Text(player.avatar.emoji, style: const TextStyle(fontSize: 16)),
      ),
      const SizedBox(height: 2),
      Text(
        player.displayName.split(' ').first,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}
