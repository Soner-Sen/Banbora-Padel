import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonrize_padel/core/design_system/design_system.dart';

class ScoreButtons extends StatelessWidget {
  const ScoreButtons({
    required this.onTeamAScore,
    required this.onTeamBScore,
    this.onUndo,
    super.key,
  });

  final VoidCallback onTeamAScore;
  final VoidCallback onTeamBScore;
  final VoidCallback? onUndo;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _ScoreButton(
          label: '+1',
          color: DesignTokens.teamA,
          onPressed: onTeamAScore,
        ),
      ),
      if (onUndo != null) ...[
        const SizedBox(width: DesignTokens.spacing12),
        _UndoButton(onPressed: onUndo!),
        const SizedBox(width: DesignTokens.spacing12),
      ],
      Expanded(
        child: _ScoreButton(
          label: '+1',
          color: DesignTokens.teamB,
          onPressed: onTeamBScore,
        ),
      ),
    ],
  );
}

class _ScoreButton extends StatelessWidget {
  const _ScoreButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () {
        HapticFeedback.mediumImpact();
        onPressed();
      },
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  );
}

class _UndoButton extends StatelessWidget {
  const _UndoButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        width: 56,
        height: 100,
        decoration: BoxDecoration(
          color: DesignTokens.elevated,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: DesignTokens.surfaceVariant, width: 1),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.undo_rounded, color: DesignTokens.textMuted, size: 24),
            SizedBox(height: 4),
            Text(
              'Undo',
              style: TextStyle(color: DesignTokens.textMuted, fontSize: 10),
            ),
          ],
        ),
      ),
    ),
  );
}

class ScoreDisplay extends StatelessWidget {
  const ScoreDisplay({
    required this.teamAScore,
    required this.teamBScore,
    this.labelA = 'Team A',
    this.labelB = 'Team B',
    super.key,
  });

  final int teamAScore;
  final int teamBScore;
  final String labelA;
  final String labelB;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: DesignTokens.spacing24,
      vertical: DesignTokens.spacing16,
    ),
    decoration: BoxDecoration(
      color: DesignTokens.elevated,
      borderRadius: BorderRadius.circular(AppRadius.lg),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _TeamScoreColumn(
          score: teamAScore,
          label: labelA,
          color: DesignTokens.teamA,
        ),
        Container(width: 2, height: 40, color: DesignTokens.surfaceVariant),
        _TeamScoreColumn(
          score: teamBScore,
          label: labelB,
          color: DesignTokens.teamB,
        ),
      ],
    ),
  );
}

class _TeamScoreColumn extends StatelessWidget {
  const _TeamScoreColumn({
    required this.score,
    required this.label,
    required this.color,
  });

  final int score;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: DesignTokens.textSecondary),
      ),
      const SizedBox(height: 4),
      Text(
        score.toString(),
        style: TextStyle(
          color: color,
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}
