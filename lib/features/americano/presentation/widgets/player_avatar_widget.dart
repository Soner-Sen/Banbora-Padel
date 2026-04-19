import 'package:flutter/material.dart';
import 'package:sonrize_padel/core/design_system/design_system.dart';
import '../../domain/entities/entities.dart';

class PlayerAvatarWidget extends StatelessWidget {
  const PlayerAvatarWidget({
    required this.player,
    required this.color,
    this.isServing = false,
    super.key,
  });

  final AmericanoParticipant player;
  final Color color;
  final bool isServing;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _AnimatedAvatar(player: player, color: color, isServing: isServing),
      const SizedBox(height: 2),
      AnimatedSwitcher(
        duration: AppDurations.fast,
        child: Container(
          key: ValueKey(player.id),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            player.displayName.split(' ').first,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    ],
  );
}

class _AnimatedAvatar extends StatelessWidget {
  const _AnimatedAvatar({
    required this.player,
    required this.color,
    required this.isServing,
  });

  final AmericanoParticipant player;
  final Color color;
  final bool isServing;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: AppDurations.normal,
    curve: Curves.easeInOut,
    padding: const EdgeInsets.all(1),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: isServing ? AppColors.server : color,
        width: isServing ? 3 : 2,
      ),
      color: AppColors.surface,
      boxShadow: isServing
          ? [
              BoxShadow(
                color: AppColors.serverGlow.withValues(alpha: 0.8),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ]
          : null,
    ),
    child: Stack(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: color.withValues(alpha: 0.15), // lighter background
          child: Text(
            player.avatar.emoji,
            style: TextStyle(fontSize: 16, color: color), // emoji in team color
          ),
        ),
        AnimatedSwitcher(
          duration: AppDurations.fast,
          child: isServing
              ? Positioned(
                  right: -1,
                  bottom: -1,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: const BoxDecoration(
                      color: AppColors.elevated,
                      shape: BoxShape.circle,
                    ),
                    child: const Text('🎾', style: TextStyle(fontSize: 8)),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    ),
  );
}
