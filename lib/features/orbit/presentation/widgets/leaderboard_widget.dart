import 'package:flutter/material.dart';
import '../../domain/entities/entities.dart';

class LeaderboardWidget extends StatelessWidget {
  const LeaderboardWidget({
    required this.entries,
    super.key,
    this.currentPlayerRank,
  });
  final List<LeaderboardEntry> entries;
  final int? currentPlayerRank;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Noch keine Rangliste verfügbar',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.leaderboard, color: Colors.amber, size: 18),
              SizedBox(width: 8),
              Text(
                'Rangliste',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...entries.asMap().entries.map((mapEntry) {
            final index = mapEntry.key;
            final entry = mapEntry.value;
            return _LeaderboardRow(
              rank: index + 1,
              entry: entry,
              isCurrentPlayer: currentPlayerRank == index + 1,
            );
          }),
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({
    required this.rank,
    required this.entry,
    this.isCurrentPlayer = false,
  });
  final int rank;
  final LeaderboardEntry entry;
  final bool isCurrentPlayer;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: isCurrentPlayer
          ? Colors.amber.withValues(alpha: 0.2)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      border: isCurrentPlayer
          ? Border.all(color: Colors.amber, width: 1)
          : null,
    ),
    child: Row(
      children: [
        _buildRankBadge(),
        const SizedBox(width: 12),
        _buildAvatar(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.displayName,
                style: TextStyle(
                  color: isCurrentPlayer ? Colors.amber : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${entry.matchesPlayed} Runden • ${entry.benchCount} Wartezeiten',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${entry.totalPoints}',
              style: TextStyle(
                color: isCurrentPlayer ? Colors.amber : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Punkte',
              style: TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildRankBadge() {
    Color badgeColor;
    String rankText = '#$rank';

    if (rank == 1) {
      badgeColor = const Color(0xFFFFD700);
      rankText = '🥇';
    } else if (rank == 2) {
      badgeColor = const Color(0xFFC0C0C0);
      rankText = '🥈';
    } else if (rank == 3) {
      badgeColor = const Color(0xFFCD7F32);
      rankText = '🥉';
    } else {
      badgeColor = Colors.white24;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          rankText,
          style: TextStyle(
            fontSize: rank <= 3 ? 16 : 12,
            fontWeight: FontWeight.bold,
            color: rank <= 3 ? null : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
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

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: colors[entry.avatar] ?? const Color(0xFF546E7A),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _getInitials(entry.displayName),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}
