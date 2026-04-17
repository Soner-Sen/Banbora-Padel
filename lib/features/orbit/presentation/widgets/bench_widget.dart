import 'package:flutter/material.dart';
import '../../domain/entities/entities.dart';
import 'player_avatar_widget.dart';

class BenchWidget extends StatelessWidget {
  const BenchWidget({required this.benchPlayers, super.key, this.nextUpReason});
  final List<Player> benchPlayers;
  final String? nextUpReason;

  @override
  Widget build(BuildContext context) {
    if (benchPlayers.isEmpty) {
      return const SizedBox.shrink();
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
          Row(
            children: [
              const Icon(Icons.people_outline, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Warteliste',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '${benchPlayers.length} Spieler',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          if (nextUpReason != null) ...[
            const SizedBox(height: 4),
            Text(
              nextUpReason!,
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: benchPlayers.length,
              separatorBuilder: (_, _) => const SizedBox(width: 16),
              itemBuilder: (context, index) => BenchPlayerAvatarWidget(
                player: benchPlayers[index],
                index: index,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
