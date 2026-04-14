enum AppEnvironment { development, staging, production }

enum BuildFlavor { dev, qa, prod }

class AppConfig {
  AppConfig._();

  static AppConfig? _instance;

  static AppConfig get instance => _instance ??= AppConfig._();

  late final AppEnvironment environment;

  late final BuildFlavor flavor;

  late final bool isDebug;

  late final bool isRelease;

  late final bool isProfile;

  late final String apiBaseUrl;

  late final String wsUrl;

  late final int apiTimeoutSeconds;

  // -------------------------------------------------------------------------
  // Feature Flags (defaults - can be overridden by remote config)
  // -------------------------------------------------------------------------

  late final bool enableDebugLogging;

  late final bool enableAnalytics;

  late final bool enableCrashReporting;

  late final String minAppVersion;

  // -------------------------------------------------------------------------
  // Storage Keys
  // -------------------------------------------------------------------------

  late final String authTokenKey;

  late final String refreshTokenKey;

  late final String userDataKey;

  late final String onboardingCompletedKey;

  // -------------------------------------------------------------------------
  // Cache Configuration
  // -------------------------------------------------------------------------

  late final int cacheExpiryHours;

  late final int maxCacheSizeMB;

  // -------------------------------------------------------------------------
  // Branding
  // -------------------------------------------------------------------------

  late final String appName;

  late final String companyName;

  late final String supportEmail;

  late final String privacyPolicyUrl;

  late final String termsOfServiceUrl;

  // -------------------------------------------------------------------------
  // Initialization
  // -------------------------------------------------------------------------

  static void initialize({
    required AppEnvironment environment,
    required BuildFlavor flavor,
    required bool isDebug,
    required bool isRelease,
    required bool isProfile,
  }) {
    final config = AppConfig._();

    config.environment = environment;
    config.flavor = flavor;
    config.isDebug = isDebug;
    config.isRelease = isRelease;
    config.isProfile = isProfile;

    config._loadEnvironmentConfig();

    _instance = config;
  }

  void _loadEnvironmentConfig() {
    switch (environment) {
      case AppEnvironment.development:
        _loadDevConfig();
      case AppEnvironment.staging:
        _loadStagingConfig();
      case AppEnvironment.production:
        _loadProdConfig();
    }
  }

  void _loadDevConfig() {
    apiBaseUrl = 'https://dev-api.sonrize-padel.com';
    wsUrl = 'wss://dev-ws.sonrize-padel.com';
    apiTimeoutSeconds = 60;

    enableDebugLogging = true;
    enableAnalytics = false;
    enableCrashReporting = false;
    minAppVersion = '1.0.0';

    authTokenKey = 'dev_auth_token';
    refreshTokenKey = 'dev_refresh_token';
    userDataKey = 'dev_user_data';
    onboardingCompletedKey = 'dev_onboarding_completed';

    cacheExpiryHours = 1;
    maxCacheSizeMB = 100;

    appName = 'Sonrize Padel (Dev)';
    companyName = 'Sonrize GmbH';
    supportEmail = 'dev-support@sonrize-padel.com';
    privacyPolicyUrl = 'https://dev.sonrize-padel.com/privacy';
    termsOfServiceUrl = 'https://dev.sonrize-padel.com/terms';
  }

  void _loadStagingConfig() {
    apiBaseUrl = 'https://staging-api.sonrize-padel.com';
    wsUrl = 'wss://staging-ws.sonrize-padel.com';
    apiTimeoutSeconds = 30;

    enableDebugLogging = true;
    enableAnalytics = true;
    enableCrashReporting = true;
    minAppVersion = '1.0.0';

    authTokenKey = 'staging_auth_token';
    refreshTokenKey = 'staging_refresh_token';
    userDataKey = 'staging_user_data';
    onboardingCompletedKey = 'staging_onboarding_completed';

    cacheExpiryHours = 6;
    maxCacheSizeMB = 200;

    appName = 'Sonrize Padel (Staging)';
    companyName = 'Sonrize GmbH';
    supportEmail = 'staging-support@sonrize-padel.com';
    privacyPolicyUrl = 'https://staging.sonrize-padel.com/privacy';
    termsOfServiceUrl = 'https://staging.sonrize-padel.com/terms';
  }

  void _loadProdConfig() {
    apiBaseUrl = 'https://api.sonrize-padel.com';
    wsUrl = 'wss://ws.sonrize-padel.com';
    apiTimeoutSeconds = 30;

    enableDebugLogging = false;
    enableAnalytics = true;
    enableCrashReporting = true;
    minAppVersion = '1.0.0';

    authTokenKey = 'auth_token';
    refreshTokenKey = 'refresh_token';
    userDataKey = 'user_data';
    onboardingCompletedKey = 'onboarding_completed';

    cacheExpiryHours = 24;
    maxCacheSizeMB = 500;

    appName = 'Sonrize Padel';
    companyName = 'Sonrize GmbH';
    supportEmail = 'support@sonrize-padel.com';
    privacyPolicyUrl = 'https://sonrize-padel.com/privacy';
    termsOfServiceUrl = 'https://sonrize-padel.com/terms';
  }

  /// Gets a human-readable environment name.
  String get environmentName => switch (environment) {
    AppEnvironment.development => 'Development',
    AppEnvironment.staging => 'Staging',
    AppEnvironment.production => 'Production',
  };

  /// Gets a human-readable flavor name.
  String get flavorName => switch (flavor) {
    BuildFlavor.dev => 'Development',
    BuildFlavor.qa => 'QA',
    BuildFlavor.prod => 'Production',
  };

  /// Checks if this is the production environment.
  bool get isProduction => environment == AppEnvironment.production;

  /// Checks if this is a development environment.
  bool get isDevelopment => environment == AppEnvironment.development;

  /// Checks if this is a staging environment.
  bool get isStaging => environment == AppEnvironment.staging;
}

/// Environment variables passed from build runner or system.
class EnvironmentVariables {
  /// FLUTTER_ENV value (development, staging, production).
  static const String flutterEnv = String.fromEnvironment(
    'FLUTTER_ENV',
    defaultValue: 'development',
  );

  /// Build flavor.
  static const String buildFlavor = String.fromEnvironment(
    'BUILD_FLAVOR',
    defaultValue: 'dev',
  );

  /// Whether this is a debug build.
  static const bool isDebug = bool.fromEnvironment('DEBUG', defaultValue: true);

  /// Whether this is a release build.
  static const bool isRelease = bool.fromEnvironment(
    'RELEASE',
    defaultValue: false,
  );

  /// Whether this is a profile build.
  static const bool isProfile = bool.fromEnvironment(
    'PROFILE',
    defaultValue: false,
  );

  /// Parses environment from string.
  static AppEnvironment parseEnvironment(String value) =>
      switch (value.toLowerCase()) {
        'production' || 'prod' => AppEnvironment.production,
        'staging' => AppEnvironment.staging,
        _ => AppEnvironment.development,
      };

  /// Parses flavor from string.
  static BuildFlavor parseFlavor(String value) => switch (value.toLowerCase()) {
    'prod' || 'production' => BuildFlavor.prod,
    'qa' || 'test' => BuildFlavor.qa,
    _ => BuildFlavor.dev,
  };
}
