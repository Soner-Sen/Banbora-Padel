import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonrize_padel/core/design_system/design_system.dart';
import 'package:sonrize_padel/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sonrize_padel/features/auth/presentation/cubit/auth_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Sonrize Padel'),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
      ],
    ),
    drawer: _buildDrawer(context),
    body: BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(DesignTokens.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Text(
                'Welcome back,',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: DesignTokens.textSecondary,
                ),
              ),
              const SizedBox(height: DesignTokens.spacing4),
              Text(
                user?.fullName ?? 'Player',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: DesignTokens.spacing24),

              // Quick actions
              Text(
                'Quick Actions',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: DesignTokens.spacing16),
              _buildQuickActionsGrid(context),
              const SizedBox(height: DesignTokens.spacing24),

              // Upcoming matches
              Text(
                'Upcoming Matches',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: DesignTokens.spacing16),
              _buildUpcomingMatchesSection(context),
              const SizedBox(height: DesignTokens.spacing24),

              // Recent activity
              Text(
                'Recent Activity',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: DesignTokens.spacing16),
              _buildRecentActivitySection(context),
            ],
          ),
        );
      },
    ),
  );

  Widget _buildDrawer(BuildContext context) => Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(color: DesignTokens.primary),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(
                Icons.sports_tennis,
                size: 48,
                color: DesignTokens.textOnPrimary,
              ),
              const SizedBox(height: DesignTokens.spacing8),
              Text(
                'Sonrize Padel',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: DesignTokens.textOnPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.home_outlined),
          title: const Text('Home'),
          onTap: () => Navigator.pop(context),
        ),
        ListTile(
          leading: const Icon(Icons.calendar_today_outlined),
          title: const Text('Book Court'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.group_outlined),
          title: const Text('Find Players'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.history_outlined),
          title: const Text('Match History'),
          onTap: () {},
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: const Text('Settings'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Logout'),
          onTap: () {
            Navigator.pop(context);
            context.read<AuthCubit>().logout();
            context.go('/login');
          },
        ),
      ],
    ),
  );

  Widget _buildQuickActionsGrid(BuildContext context) => GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 2,
    mainAxisSpacing: DesignTokens.spacing16,
    crossAxisSpacing: DesignTokens.spacing16,
    children: [
      _buildActionCard(
        context,
        icon: Icons.calendar_today,
        title: 'Book Court',
        subtitle: 'Reserve a padel court',
        color: DesignTokens.primary,
        onTap: () {},
      ),
      _buildActionCard(
        context,
        icon: Icons.group,
        title: 'Find Players',
        subtitle: 'Match with players',
        color: DesignTokens.secondary,
        onTap: () {},
      ),
      _buildActionCard(
        context,
        icon: Icons.sports_score,
        title: 'My Stats',
        subtitle: 'View your statistics',
        color: DesignTokens.info,
        onTap: () {},
      ),
      _buildActionCard(
        context,
        icon: Icons.leaderboard,
        title: 'Rankings',
        subtitle: 'See leaderboard',
        color: DesignTokens.warning,
        onTap: () {},
      ),
    ],
  );

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) => AppCard(
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(DesignTokens.spacing12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: DesignTokens.borderRadius8,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: DesignTokens.spacing12),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: DesignTokens.spacing4),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: DesignTokens.textSecondary),
        ),
      ],
    ),
  );

  Widget _buildUpcomingMatchesSection(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.calendar_today,
              size: 20,
              color: DesignTokens.primary,
            ),
            const SizedBox(width: DesignTokens.spacing8),
            Text(
              'Next match in 2 hours',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.spacing12),
        Row(
          children: [
            _buildPlayerAvatar('You', DesignTokens.primary),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacing8,
              ),
              child: Text(
                'vs',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: DesignTokens.textSecondary,
                ),
              ),
            ),
            _buildPlayerAvatar('Player B', DesignTokens.secondary),
          ],
        ),
        const SizedBox(height: DesignTokens.spacing12),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 16,
              color: DesignTokens.textTertiary,
            ),
            const SizedBox(width: DesignTokens.spacing4),
            Text(
              'Court 1 - Main Arena',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: DesignTokens.textSecondary,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildPlayerAvatar(String name, Color color) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    child: Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          color: DesignTokens.textOnPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );

  Widget _buildRecentActivitySection(BuildContext context) => Column(
    children: [
      _buildActivityItem(
        context,
        icon: Icons.sports_tennis,
        title: 'Match completed',
        subtitle: 'Won 6-4, 6-3',
        time: 'Today, 2:30 PM',
      ),
      const SizedBox(height: DesignTokens.spacing8),
      _buildActivityItem(
        context,
        icon: Icons.calendar_today,
        title: 'Court booked',
        subtitle: 'Tomorrow at 10:00 AM',
        time: 'Yesterday, 5:00 PM',
      ),
      const SizedBox(height: DesignTokens.spacing8),
      _buildActivityItem(
        context,
        icon: Icons.person_add,
        title: 'New connection',
        subtitle: 'Connected with Player C',
        time: '2 days ago',
      ),
    ],
  );

  Widget _buildActivityItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) => AppCard(
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(DesignTokens.spacing8),
          decoration: const BoxDecoration(
            color: DesignTokens.surfaceVariant,
            borderRadius: DesignTokens.borderRadius8,
          ),
          child: Icon(icon, size: 20, color: DesignTokens.textSecondary),
        ),
        const SizedBox(width: DesignTokens.spacing12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: DesignTokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: DesignTokens.textTertiary),
        ),
      ],
    ),
  );
}
