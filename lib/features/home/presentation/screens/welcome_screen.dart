import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sonrize_padel/core/design_system/design_system.dart';
import 'package:sonrize_padel/core/design_system/app_widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacing24),
        child: Column(
          children: [
            const Spacer(flex: 1),
            _buildHeader(context),
            const SizedBox(height: DesignTokens.spacing48),
            _buildModeCards(context),
            const Spacer(flex: 2),
            _buildFooter(context),
          ],
        ),
      ),
    ),
  );

  Widget _buildHeader(BuildContext context) => Column(
    children: [
      Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: DesignTokens.primary,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: const Icon(
          Icons.sports_tennis,
          size: 56,
          color: DesignTokens.textOnPrimary,
        ),
      ),
      const SizedBox(height: DesignTokens.spacing24),
      Text(
        'Sonrize Padel',
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: DesignTokens.textPrimary,
        ),
      ),
      const SizedBox(height: DesignTokens.spacing8),
      Text(
        'Spontane Sessions, keine Registrierung',
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: DesignTokens.textSecondary),
        textAlign: TextAlign.center,
      ),
    ],
  );

  Widget _buildModeCards(BuildContext context) => Column(
    children: [
      _ModeCard(
        title: 'Session starten',
        subtitle: 'Orbit-Modus für faire Rotation',
        icon: Icons.play_arrow_rounded,
        color: DesignTokens.orbitPrimary,
        onTap: () => context.push('/session/create'),
      ),
      const SizedBox(height: DesignTokens.spacing16),
      _ModeCard(
        title: 'Session beitreten',
        subtitle: 'QR-Code scannen oder Code eingeben',
        icon: Icons.qr_code_scanner_rounded,
        color: DesignTokens.secondary,
        onTap: () => context.push('/session/join'),
      ),
      const SizedBox(height: DesignTokens.spacing16),
      _ModeCard(
        title: 'Classic Regeln',
        subtitle: 'Offizielle Padel-Regeln ansehen',
        icon: Icons.menu_book_rounded,
        color: DesignTokens.info,
        onTap: () => context.push('/classic-rules'),
      ),
    ],
  );

  Widget _buildFooter(BuildContext context) => Column(
    children: [
      const Divider(color: DesignTokens.surfaceVariant),
      const SizedBox(height: DesignTokens.spacing16),
      AppTextButton(
        label: 'Bereits ein Konto? Anmelden',
        onPressed: () => context.push('/login'),
      ),
    ],
  );
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppCard(
    onTap: onTap,
    child: Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(width: DesignTokens.spacing16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.textPrimary,
                ),
              ),
              const SizedBox(height: DesignTokens.spacing4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: DesignTokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded, color: DesignTokens.textMuted),
      ],
    ),
  );
}
