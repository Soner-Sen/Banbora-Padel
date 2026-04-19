import 'package:flutter/material.dart';
import 'package:sonrize_padel/core/design_system/design_system.dart';
import 'package:sonrize_padel/core/game_engine/domain/entities/game_team.dart';

class ScoreBoxWidget extends StatelessWidget {
  const ScoreBoxWidget({
    required this.score,
    required this.teamSide,
    required this.isWinner,
    super.key,
  });

  final int score;
  final TeamSide teamSide;
  final bool isWinner;

  @override
  Widget build(BuildContext context) => Container(
    width: 80,
    height: 80,
    decoration: BoxDecoration(
      color: isWinner ? AppColors.winner : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      boxShadow: AppElevation.low,
      border: isWinner ? Border.all(color: AppColors.winner, width: 2) : null,
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$score',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: isWinner ? Colors.white : AppColors.textPrimary,
          ),
        ),
        Text(
          teamSide == TeamSide.a ? 'Team A' : 'Team B',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isWinner ? Colors.white70 : AppColors.textMuted,
          ),
        ),
      ],
    ),
  );
}
