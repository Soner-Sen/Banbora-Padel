import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sonrize_padel/core/design_system/design_system.dart';
import 'package:sonrize_padel/core/design_system/app_widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.all(DesignTokens.spacing24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeader(context),
                const SizedBox(height: DesignTokens.spacing32),
                _buildModeCards(context),
                const SizedBox(height: DesignTokens.spacing32),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final headerHeight = screenWidth * 0.65;

    return Column(
      children: [
        Container(
          width: screenWidth,
          height: headerHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              BoxShadow(
                color: DesignTokens.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Stack(
              fit: StackFit.expand,
              children: [
                SvgPicture.asset(
                  'assets/images/padel_woman.svg',
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: headerHeight * 0.5,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          DesignTokens.textPrimary.withValues(alpha: 0.85),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: DesignTokens.spacing16,
                  left: DesignTokens.spacing16,
                  right: DesignTokens.spacing16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Sonrize Padel',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: DesignTokens.textOnPrimary,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spacing4),
                      Text(
                        'Spontane Sessions, keine Registrierung',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: DesignTokens.textOnPrimary.withValues(alpha: 0.9),
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

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
    padding: const EdgeInsets.all(DesignTokens.spacing16),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: DesignTokens.spacing16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: DesignTokens.spacing4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: DesignTokens.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded, color: DesignTokens.textMuted),
      ],
    ),
  );
}
