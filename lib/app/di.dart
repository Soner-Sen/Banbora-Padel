import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/analytics/analytics.dart';
import '../core/config/config.dart';
import '../core/feature_flags/feature_flags.dart';
import '../core/local_storage/local_storage.dart';
import '../core/logging/logging.dart';
import '../core/monitoring/monitoring.dart';
import '../core/network/network.dart';
import '../features/auth/data/datasources/auth_local_datasource.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/logout_usecase.dart';
import '../features/auth/domain/usecases/register_usecase.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
// The orbit feature is not yet fully implemented - orbit_cubit import deferred

final GetIt sl = GetIt.instance;

/// Dependency injection setup.
/// Call this after bootstrap to register all dependencies.
Future<void> setupDependencies({
  required SharedPreferences sharedPreferences,
  required INetworkInfo networkInfo,
}) async {
  // -------------------------------------------------------------------------
  // Core - External
  // -------------------------------------------------------------------------

  // Shared Preferences
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Network Info
  sl.registerLazySingleton<INetworkInfo>(() => networkInfo);

  // -------------------------------------------------------------------------
  // Core - Storage
  // -------------------------------------------------------------------------

  // Secure Storage
  sl.registerLazySingleton<ISecureStorage>(
    () => SecureStorageImpl(
      androidOptions: const AndroidOptions(encryptedSharedPreferences: true),
      iosOptions: const IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    ),
  );

  // Local Storage (using SharedPreferences)
  sl.registerLazySingleton<ILocalStorage>(
    () => SharedPreferencesStorage(sl<SharedPreferences>()),
  );

  // Token Storage
  sl.registerLazySingleton<TokenStorage>(
    () => TokenStorage(sl<ISecureStorage>()),
  );

  // -------------------------------------------------------------------------
  // Core - Network
  // -------------------------------------------------------------------------

  // API Client
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      baseUrl: AppConfig.instance.apiBaseUrl,
      networkInfo: sl<INetworkInfo>(),
      connectTimeout: Duration(seconds: AppConfig.instance.apiTimeoutSeconds),
      receiveTimeout: Duration(seconds: AppConfig.instance.apiTimeoutSeconds),
    ),
  );

  // -------------------------------------------------------------------------
  // Core - Services
  // -------------------------------------------------------------------------

  // Logger
  sl.registerLazySingleton<AppLogger>(
    () => LoggerFactory.create(
      module: 'app',
      isDevelopment: AppConfig.instance.isDevelopment,
    ),
  );

  // Analytics
  sl.registerLazySingleton<IAnalyticsService>(
    () => AnalyticsService(isEnabled: AppConfig.instance.enableAnalytics),
  );

  // Feature Flags
  sl.registerLazySingleton<IFeatureFlagService>(
    () => LocalFeatureFlagService(initialFlags: getDefaultFeatureFlags()),
  );

  // -------------------------------------------------------------------------
  // Feature - Auth
  // -------------------------------------------------------------------------

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      tokenStorage: sl<TokenStorage>(),
      localStorage: sl<ILocalStorage>(),
    ),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
      networkInfo: sl<INetworkInfo>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(sl<AuthRepository>()),
  );

  // Cubit
  sl.registerFactory<AuthCubit>(
    () => AuthCubit(
      loginUseCase: sl<LoginUseCase>(),
      registerUseCase: sl<RegisterUseCase>(),
      getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
      analyticsService: sl<IAnalyticsService>(),
    ),
  );

  // -------------------------------------------------------------------------
  // App-wide Services
  // -------------------------------------------------------------------------

  // Register analytics service with monitoring
  if (sl.isRegistered<IMonitoringService>()) {
    final monitoringService = sl<IMonitoringService>();
    monitoringService.setEnabled(AppConfig.instance.enableCrashReporting);
  }
}

/// Resets all registered dependencies.
///
/// Useful for testing or logout flows.
Future<void> resetDependencies() async {
  await sl.reset();
}

/// Checks if a dependency is registered.
bool isRegistered<T extends Object>() => sl.isRegistered<T>();

/// Gets a registered dependency.
T get<T extends Object>() => sl<T>();

/// Async version of get.
Future<T> getAsync<T extends Object>() async => sl<T>();
