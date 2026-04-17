import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/logging/logging.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/home/presentation/screens/welcome_screen.dart';
import '../features/session/presentation/screens/session_create_screen.dart';
import '../features/session/presentation/screens/session_join_screen.dart';

class AppRouter {
  AppRouter({required AuthCubit authCubit, AppLogger? logger})
    : _logger = logger ?? LoggerFactory.noOp(),
      _authCubit = authCubit;
  final AppLogger _logger;
  final AuthCubit _authCubit;

  GoRouter get router => _router;

  late final GoRouter _router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(_authCubit.stream),
    redirect: _handleRedirect,
    routes: _routes,
    errorBuilder: _handleError,
  );

  String? _handleRedirect(BuildContext context, GoRouterState state) {
    final authState = _authCubit.state;

    if (state.matchedLocation == '/splash') {
      return null;
    }

    // Account routes (login/register) - only for unauthenticated users
    if (authState.isAuthenticated &&
        (state.matchedLocation == '/login' ||
            state.matchedLocation == '/register')) {
      _logger.debug(
        'Already authenticated, redirecting from auth route to welcome',
      );
      return '/welcome';
    }

    return null;
  }

  List<GoRoute> get _routes => [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // Welcome screen - new entry point without login
    GoRoute(
      path: '/welcome',
      name: 'welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),

    // Session routes
    GoRoute(
      path: '/session/create',
      name: 'sessionCreate',
      builder: (context, state) => const SessionCreateScreen(),
    ),
    GoRoute(
      path: '/session/join',
      name: 'sessionJoin',
      builder: (context, state) => const SessionJoinScreen(),
    ),

    // Classic rules
    GoRoute(
      path: '/classic-rules',
      name: 'classicRules',
      builder: (context, state) => const ClassicRulesScreen(),
    ),

    // Auth routes
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // Home screen - still available for logged-in users
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
  ];

  Widget _handleError(BuildContext context, GoRouterState state) {
    _logger.error('Route error: ${state.matchedLocation}', error: state.error);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.matchedLocation,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/welcome'),
              child: const Text('Go Welcome'),
            ),
          ],
        ),
      ),
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String sessionCreate = '/session/create';
  static const String sessionJoin = '/session/join';
}

extension NavigationExtension on BuildContext {
  void goTo(String routeName, {Map<String, dynamic>? params}) {
    go(routeName);
  }

  Future<T?> pushTo<T>(String routeName, {Map<String, dynamic>? params}) =>
      push<T>(routeName);

  void pop<T>([T? result]) {
    pop(result);
  }

  void replaceWith(String routeName, {Map<String, dynamic>? params}) {
    replace(routeName);
  }
}
