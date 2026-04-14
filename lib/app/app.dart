import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/design_system/design_system.dart';
import '../core/logging/logging.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import 'di.dart';
import 'router.dart';

class SonrizeApp extends StatefulWidget {
  const SonrizeApp({super.key});

  @override
  State<SonrizeApp> createState() => _SonrizeAppState();
}

class _SonrizeAppState extends State<SonrizeApp> {
  late final AppLogger _logger;
  late final AuthCubit _authCubit;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _logger = sl<AppLogger>();
    _logger.info('Initializing SonrizeApp');

    // Initialize Auth Cubit
    _authCubit = sl<AuthCubit>();
    _logger.info('AuthCubit initialized');

    // Initialize Router
    _appRouter = AppRouter(authCubit: _authCubit);
    _logger.info('Router initialized');
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [BlocProvider<AuthCubit>.value(value: _authCubit)],
    child: MaterialApp.router(
      title: 'Sonrize Padel',
      debugShowCheckedModeBanner: false,

      theme: createAppTheme(isDark: false),
      darkTheme: createAppTheme(isDark: true),
      themeMode: ThemeMode.system,

      routerConfig: _appRouter.router,

      // Builder for global configurations
      builder: (context, child) => MediaQuery(
        // Prevent text scaling from affecting the app
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: child ?? const SizedBox.shrink(),
      ),
    ),
  );

  @override
  void dispose() {
    _logger.info('Disposing SonrizeApp');
    _authCubit.close();
    super.dispose();
  }
}

/// Extension to provide easy access to cubits from context.
extension CubitProviderExtension on BuildContext {
  /// Gets the Auth Cubit.
  AuthCubit get authCubit => BlocProvider.of<AuthCubit>(this);
}

void showAppSnackBar(
  BuildContext context, {
  required String message,
  bool isError = false,
  Duration? duration,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? DesignTokens.error : DesignTokens.primary,
      behavior: SnackBarBehavior.floating,
      duration: duration ?? const Duration(seconds: 3),
    ),
  );
}

Future<void> showLoadingDialog(BuildContext context) => showDialog<void>(
  context: context,
  barrierDismissible: false,
  builder: (context) => const PopScope(
    canPop: false,
    child: Center(child: CircularProgressIndicator()),
  ),
);

void hideLoadingDialog(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop();
}
