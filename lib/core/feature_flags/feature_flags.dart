import 'dart:async';

class FeatureFlag {
  const FeatureFlag({
    required this.key,
    required this.name,
    required this.description,
    required this.defaultValue,
    required this.owner,
    required this.createdAt,
    required this.updatedAt,
    this.rolloutPercentage = 100,
  });

  final String key;

  final String name;

  final String description;

  final bool defaultValue;

  final int rolloutPercentage;

  final String owner;

  final DateTime createdAt;

  final DateTime updatedAt;

  bool get isFullRollout => rolloutPercentage >= 100;

  bool get isDisabled => rolloutPercentage <= 0;
}

class FeatureFlagValue {
  FeatureFlagValue({
    required this.flag,
    required this.isEnabled,
    this.reason,
    DateTime? evaluatedAt,
  }) : evaluatedAt = evaluatedAt ?? DateTime.now();

  final FeatureFlag flag;

  final bool isEnabled;

  final String? reason;

  final DateTime evaluatedAt;
}

class FeatureFlagContext {
  const FeatureFlagContext({
    this.userId,
    this.email,
    this.attributes,
    this.platform,
    this.appVersion,
    this.buildType,
  });

  final String? userId;

  final String? email;

  final Map<String, dynamic>? attributes;

  final String? platform;

  final String? appVersion;

  final String? buildType;

  FeatureFlagContext copyWith({
    String? userId,
    String? email,
    Map<String, dynamic>? attributes,
    String? platform,
    String? appVersion,
    String? buildType,
  }) => FeatureFlagContext(
    userId: userId ?? this.userId,
    email: email ?? this.email,
    attributes: attributes ?? this.attributes,
    platform: platform ?? this.platform,
    appVersion: appVersion ?? this.appVersion,
    buildType: buildType ?? this.buildType,
  );
}

abstract class IFeatureFlagService {
  Future<FeatureFlag?> getFlag(String key);

  Future<List<FeatureFlag>> getAllFlags();

  Future<bool> isEnabled(String flagKey, [FeatureFlagContext? context]);

  Future<FeatureFlagValue?> evaluate(
    String flagKey, [
    FeatureFlagContext? context,
  ]);

  Future<void> updateFlag(FeatureFlag flag);

  void setContext(FeatureFlagContext context);

  void clearContext();

  Future<void> refresh();

  FeatureFlagContext? get currentContext;

  Stream<FeatureFlagValue> get onFlagChanged;
}

class LocalFeatureFlagService implements IFeatureFlagService {
  LocalFeatureFlagService({List<FeatureFlag>? initialFlags}) {
    if (initialFlags != null) {
      for (final flag in initialFlags) {
        _flags[flag.key] = flag;
      }
    }
  }
  final Map<String, FeatureFlag> _flags = {};
  final Map<String, bool> _overrides = {};
  FeatureFlagContext? _context;
  final _flagChangedController = StreamController<FeatureFlagValue>.broadcast();

  @override
  Future<FeatureFlag?> getFlag(String key) async => _flags[key];

  @override
  Future<List<FeatureFlag>> getAllFlags() async => _flags.values.toList();

  @override
  Future<bool> isEnabled(String flagKey, [FeatureFlagContext? context]) async {
    final value = await evaluate(flagKey, context);
    return value?.isEnabled ?? false;
  }

  @override
  Future<FeatureFlagValue?> evaluate(
    String flagKey, [
    FeatureFlagContext? context,
  ]) async {
    final flag = _flags[flagKey];
    if (flag == null) {
      return null;
    }

    if (_overrides.containsKey(flagKey)) {
      return FeatureFlagValue(
        flag: flag,
        isEnabled: _overrides[flagKey]!,
        reason: 'local_override',
      );
    }

    final evalContext = context ?? _context;
    final isEnabled = _evaluateRollout(flag, evalContext);

    return FeatureFlagValue(
      flag: flag,
      isEnabled: isEnabled,
      reason: isEnabled ? 'rollout_enabled' : 'rollout_disabled',
    );
  }

  bool _evaluateRollout(FeatureFlag flag, FeatureFlagContext? context) {
    if (flag.rolloutPercentage >= 100) {
      return true;
    }
    if (flag.rolloutPercentage <= 0) {
      return false;
    }

    if (context?.userId != null) {
      final hash = context!.userId.hashCode % 100;
      return hash < flag.rolloutPercentage;
    }

    return false;
  }

  @override
  Future<void> updateFlag(FeatureFlag flag) async {
    _flags[flag.key] = flag;
    final value = await evaluate(flag.key);
    if (value != null) {
      _flagChangedController.add(value);
    }
  }

  @override
  void setContext(FeatureFlagContext context) {
    _context = context;
  }

  @override
  void clearContext() {
    _context = null;
  }

  @override
  Future<void> refresh() async {}

  @override
  FeatureFlagContext? get currentContext => _context;

  @override
  Stream<FeatureFlagValue> get onFlagChanged => _flagChangedController.stream;

  void setOverride(String flagKey, bool value) {
    _overrides[flagKey] = value;
  }

  void clearOverride(String flagKey) {
    _overrides.remove(flagKey);
  }

  void dispose() {
    _flagChangedController.close();
  }
}

class FeatureFlagKeys {
  FeatureFlagKeys._();

  static const String authBiometric = 'auth_biometric';
  static const String authSocialLogin = 'auth_social_login';
  static const String authRememberMe = 'auth_remember_me';

  static const String bookingInstantConfirm = 'booking_instant_confirm';
  static const String bookingRecurring = 'booking_recurring';
  static const String bookingWaitlist = 'booking_waitlist';

  static const String uiDarkMode = 'ui_dark_mode';
  static const String uiNotifications = 'ui_notifications';
  static const String uiOnboarding = 'ui_onboarding';

  static const String featurePremium = 'feature_premium';
  static const String featureAnalytics = 'feature_analytics';
}

List<FeatureFlag> getDefaultFeatureFlags() {
  final now = DateTime.now();
  return [
    FeatureFlag(
      key: FeatureFlagKeys.authBiometric,
      name: 'Biometric Authentication',
      description: 'Enable Face ID / fingerprint authentication',
      defaultValue: true,
      rolloutPercentage: 100,
      owner: 'auth',
      createdAt: now,
      updatedAt: now,
    ),
    FeatureFlag(
      key: FeatureFlagKeys.authSocialLogin,
      name: 'Social Login',
      description: 'Enable login with Google, Apple, etc.',
      defaultValue: false,
      rolloutPercentage: 0,
      owner: 'auth',
      createdAt: now,
      updatedAt: now,
    ),

    FeatureFlag(
      key: FeatureFlagKeys.bookingInstantConfirm,
      name: 'Instant Booking Confirmation',
      description: 'Skip court owner approval for bookings',
      defaultValue: true,
      rolloutPercentage: 100,
      owner: 'booking',
      createdAt: now,
      updatedAt: now,
    ),
    FeatureFlag(
      key: FeatureFlagKeys.bookingRecurring,
      name: 'Recurring Bookings',
      description: 'Enable recurring/weekly bookings',
      defaultValue: true,
      rolloutPercentage: 100,
      owner: 'booking',
      createdAt: now,
      updatedAt: now,
    ),

    FeatureFlag(
      key: FeatureFlagKeys.uiDarkMode,
      name: 'Dark Mode',
      description: 'Enable dark mode theme',
      defaultValue: true,
      rolloutPercentage: 100,
      owner: 'ui',
      createdAt: now,
      updatedAt: now,
    ),
    FeatureFlag(
      key: FeatureFlagKeys.uiNotifications,
      name: 'Push Notifications',
      description: 'Enable push notifications',
      defaultValue: true,
      rolloutPercentage: 100,
      owner: 'ui',
      createdAt: now,
      updatedAt: now,
    ),
  ];
}
