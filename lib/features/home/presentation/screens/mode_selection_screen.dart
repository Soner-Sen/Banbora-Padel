import 'package:flutter/material.dart';
import 'package:sonrize_padel/core/design_system/design_system.dart';
import 'package:sonrize_padel/core/game_engine/game_engine.dart';
import 'package:sonrize_padel/features/americano/presentation/screens/americano_lobby_screen.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  static const List<_GameModeCardData> _modes = [
    _GameModeCardData(
      mode: GameModeType.americano,
      title: 'Americano',
      subtitle: 'Punkte sammeln, Teams rotieren',
      icon: Icons.stars,
      color: AppColors.primary,
      rules: [
        (Icons.group, '4-10 Spieler', 'Jeder spielt mit und gegen jeden'),
        (Icons.sync, 'Faire Rotation', 'Teams wechseln automatisch'),
        (Icons.stars, 'Punkte sammeln', 'Match-Ergebnis = Deine Punkte'),
        (Icons.emoji_events, 'Gewinner', 'Wer die meisten Punkte hat'),
      ],
    ),
    _GameModeCardData(
      mode: GameModeType.liga,
      title: 'Liga',
      subtitle: 'Gewinne zählen, fair rotieren',
      icon: Icons.emoji_events,
      color: AppColors.teamB,
      rules: [
        (Icons.group, '4-10 Spieler', 'Jeder spielt mit und gegen jeden'),
        (Icons.sync, 'Faire Rotation', 'Teams wechseln automatisch'),
        (Icons.emoji_events, 'Siege zählen', 'Meiste Siege gewinnt'),
        (Icons.balance, 'Unentschieden', 'Draws möglich'),
      ],
    ),
    _GameModeCardData(
      mode: GameModeType.normal,
      title: 'Normal',
      subtitle: 'Klassisches Padel Match',
      icon: Icons.sports_tennis,
      color: AppColors.courtBase,
      rules: [
        (Icons.group, '4 Spieler', '2 gegen 2'),
        (Icons.sports_tennis, 'Offizielle Regeln', 'Standard Padel'),
        (Icons.flag, 'Gewinnt', 'Wer zuerst den Score erreicht'),
      ],
    ),
    _GameModeCardData(
      mode: GameModeType.chaosRally,
      title: 'Chaos Rally',
      subtitle: 'Spaß mit Überraschungen',
      icon: Icons.casino,
      color: AppColors.secondary,
      rules: [
        (Icons.casino, 'Zufällige Challenges', 'Alle 2-4 Punkte'),
        (Icons.warning, 'Überraschungen', 'Schwache Hand, kein Racket...'),
        (Icons.emoji_events, 'Gewinner', 'Wer das Chaos überlebt'),
      ],
    ),
  ];

  void _showModeInfo(BuildContext context, _GameModeCardData data) {
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: data.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(data.icon, color: data.color, size: 28),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    data.title,
                    style: Theme.of(ctx).textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              data.subtitle,
              style: Theme.of(
                ctx,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            ...data.rules.map(
              (rule) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Icon(rule.$1, size: 20, color: data.color),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rule.$2,
                            style: Theme.of(ctx).textTheme.titleSmall,
                          ),
                          Text(
                            rule.$3,
                            style: Theme.of(ctx).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom + AppSpacing.md),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Text(
                  'Padel App',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Wähle deinen Spielmodus',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Mode list - vertical scroll
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: _modes.length,
              itemBuilder: (context, index) {
                final mode = _modes[index];
                return _ModeListTile(
                  data: mode,
                  onTap: () {
                    if (mode.mode == GameModeType.americano) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AmericanoLobbyScreen(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${mode.title} kommt bald!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  onInfoTap: () => _showModeInfo(context, mode),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class _ModeListTile extends StatelessWidget {
  const _ModeListTile({
    required this.data,
    required this.onTap,
    required this.onInfoTap,
  });

  final _GameModeCardData data;
  final VoidCallback onTap;
  final VoidCallback onInfoTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppElevation.low,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(data.icon, color: data.color, size: 32),
            ),
            const SizedBox(width: AppSpacing.md),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    data.subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Info button
            IconButton(
              icon: const Icon(Icons.info_outline, color: AppColors.textMuted),
              onPressed: onInfoTap,
            ),

            // Arrow
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    ),
  );
}

class _GameModeCardData {
  const _GameModeCardData({
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.rules = const [],
  });

  final GameModeType mode;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<(IconData, String, String)> rules;
}
