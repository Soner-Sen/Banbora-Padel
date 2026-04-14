import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonrize_padel/core/design_system/design_system.dart';
import 'package:sonrize_padel/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sonrize_padel/features/auth/presentation/cubit/auth_state.dart';

/// Splash screen - initial loading screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for a short duration to show splash
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) {
      return;
    }

    // Initialize auth check
    await context.read<AuthCubit>().initialize();
  }

  @override
  Widget build(BuildContext context) => BlocListener<AuthCubit, AuthState>(
    listener: (context, state) {
      if (state is AuthAuthenticated) {
        context.go('/home');
      } else if (state is AuthUnauthenticated) {
        context.go('/login');
      }
    },
    child: Scaffold(
      backgroundColor: DesignTokens.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sports_tennis,
              size: 100,
              color: DesignTokens.textOnPrimary,
            ),
            const SizedBox(height: DesignTokens.spacing24),
            Text(
              'Sonrize Padel',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: DesignTokens.textOnPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: DesignTokens.spacing16),
            Text(
              'Loading...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: DesignTokens.textOnPrimary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: DesignTokens.spacing32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(DesignTokens.textOnPrimary),
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
