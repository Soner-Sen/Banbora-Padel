import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonrize_padel/core/analytics/analytics.dart';
import 'package:sonrize_padel/features/auth/domain/entities/guest_user.dart';
import 'package:sonrize_padel/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:sonrize_padel/features/auth/domain/usecases/login_usecase.dart';
import 'package:sonrize_padel/features/auth/domain/usecases/logout_usecase.dart';
import 'package:sonrize_padel/features/auth/domain/usecases/register_usecase.dart';
import 'package:sonrize_padel/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required LogoutUseCase logoutUseCase,
    required IAnalyticsService analyticsService,
  }) : _loginUseCase = loginUseCase,
       _registerUseCase = registerUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       _logoutUseCase = logoutUseCase,
       _analyticsService = analyticsService,
       super(const AuthInitial());
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final LogoutUseCase _logoutUseCase;
  final IAnalyticsService _analyticsService;

  Future<void> initialize() async {
    emit(const AuthLoading(message: 'Checking authentication...'));

    final result = await _getCurrentUserUseCase();

    await result.fold((failure) => _checkForGuestSession(), (user) {
      emit(AuthAuthenticated(user: user));
      _logAuthEvent(AnalyticsEvents.authLoginSuccess, success: true);
    });
  }

  Future<void> _checkForGuestSession() async {
    // TODO: Check local storage for existing guest session
    // For now, emit unauthenticated (allows guest flow)
    emit(const AuthUnauthenticated());
  }

  void loginAsGuest({required String displayName, int? avatarColor}) {
    final guestUser = GuestUser(
      id: _generateGuestId(),
      displayName: displayName,
      avatarColor: avatarColor,
    );
    emit(AuthGuest(guestUser: guestUser));
    _logAuthEvent('guest_login', success: true);
  }

  void updateGuestName({required String displayName}) {
    final currentState = state;
    if (currentState is AuthGuest) {
      final updatedGuest = currentState.guestUser.copyWith(
        displayName: displayName,
      );
      emit(AuthGuest(guestUser: updatedGuest));
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading(message: 'Signing in...'));

    _analyticsService.logEvent(
      AnalyticsEvent(
        name: AnalyticsEvents.authLoginAttempt,
        parameters: {AnalyticsParams.authMethod: 'email'},
      ),
    );

    final result = await _loginUseCase(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) {
        emit(AuthError(message: failure.message, failure: failure));
        _logAuthEvent(AnalyticsEvents.authLoginFailed, success: false);
      },
      (authResult) {
        emit(AuthAuthenticated(user: authResult.user));
        _logAuthEvent(AnalyticsEvents.authLoginSuccess, success: true);
      },
    );
  }

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    emit(const AuthLoading(message: 'Creating account...'));

    _analyticsService.logEvent(
      AnalyticsEvent(name: AnalyticsEvents.authRegisterAttempt),
    );

    final result = await _registerUseCase(
      RegisterParams(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      ),
    );

    result.fold(
      (failure) {
        emit(AuthError(message: failure.message, failure: failure));
        _logAuthEvent(AnalyticsEvents.authRegisterFailed, success: false);
      },
      (authResult) {
        emit(AuthAuthenticated(user: authResult.user));
        _logAuthEvent(AnalyticsEvents.authRegisterSuccess, success: true);
      },
    );
  }

  Future<void> logout() async {
    emit(const AuthLoading(message: 'Signing out...'));

    final result = await _logoutUseCase();

    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (_) => emit(const AuthUnauthenticated()),
    );

    _logAuthEvent(AnalyticsEvents.authLogout, success: true);
  }

  void clearError() {
    if (state is AuthError) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> refreshUser() async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) {
      return;
    }

    final result = await _getCurrentUserUseCase();

    result.fold((_) {}, (user) => emit(AuthAuthenticated(user: user)));
  }

  String _generateGuestId() => 'guest_${DateTime.now().millisecondsSinceEpoch}';

  void _logAuthEvent(String eventName, {required bool success}) {
    _analyticsService.logEvent(
      AnalyticsEvent(name: eventName, parameters: {'success': success}),
    );
  }
}
