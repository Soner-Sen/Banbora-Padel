import 'package:flutter/material.dart';
import '../../domain/entities/entities.dart';

class PlayerAvatarWidget extends StatelessWidget {
  const PlayerAvatarWidget({
    required this.player,
    super.key,
    this.isServing = false,
    this.isReturner = false,
    this.onTap,
    this.size = 60,
  });
  final Player player;
  final bool isServing;
  final bool isReturner;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _getAvatarColor(player.avatar),
            shape: BoxShape.circle,
            border: Border.all(
              color: isServing
                  ? Colors.yellow
                  : isReturner
                  ? Colors.green
                  : Colors.white24,
              width: isServing || isReturner ? 3 : 1,
            ),
            boxShadow: isServing
                ? [
                    BoxShadow(
                      color: Colors.yellow.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              _getInitials(player.displayName),
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.35,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          player.displayName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (isServing)
          const Text(
            'SERVE',
            style: TextStyle(
              color: Colors.yellow,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (isReturner)
          const Text(
            'RETURN',
            style: TextStyle(
              color: Colors.green,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    ),
  );

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  Color _getAvatarColor(PlayerAvatar avatar) {
    final colors = {
      PlayerAvatar.avatar1: const Color(0xFF1E88E5),
      PlayerAvatar.avatar2: const Color(0xFF43A047),
      PlayerAvatar.avatar3: const Color(0xFFE53935),
      PlayerAvatar.avatar4: const Color(0xFF8E24AA),
      PlayerAvatar.avatar5: const Color(0xFFFF6F00),
      PlayerAvatar.avatar6: const Color(0xFF00ACC1),
      PlayerAvatar.avatar7: const Color(0xFFD81B60),
      PlayerAvatar.avatar8: const Color(0xFF3949AB),
      PlayerAvatar.avatar9: const Color(0xFF00897B),
      PlayerAvatar.avatar10: const Color(0xFF6D4C41),
    };
    return colors[avatar] ?? const Color(0xFF546E7A);
  }
}

class BenchPlayerAvatarWidget extends StatelessWidget {
  const BenchPlayerAvatarWidget({
    required this.player,
    required this.index,
    super.key,
    this.onTap,
  });
  final Player player;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getAvatarColor(player.avatar).withValues(alpha: 0.7),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: Center(
            child: Text(
              _getInitials(player.displayName),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          player.displayName.length > 8
              ? '${player.displayName.substring(0, 8)}...'
              : player.displayName,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    ),
  );

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  Color _getAvatarColor(PlayerAvatar avatar) {
    final colors = {
      PlayerAvatar.avatar1: const Color(0xFF1E88E5),
      PlayerAvatar.avatar2: const Color(0xFF43A047),
      PlayerAvatar.avatar3: const Color(0xFFE53935),
      PlayerAvatar.avatar4: const Color(0xFF8E24AA),
      PlayerAvatar.avatar5: const Color(0xFFFF6F00),
      PlayerAvatar.avatar6: const Color(0xFF00ACC1),
      PlayerAvatar.avatar7: const Color(0xFFD81B60),
      PlayerAvatar.avatar8: const Color(0xFF3949AB),
      PlayerAvatar.avatar9: const Color(0xFF00897B),
      PlayerAvatar.avatar10: const Color(0xFF6D4C41),
    };
    return colors[avatar] ?? const Color(0xFF546E7A);
  }
}
