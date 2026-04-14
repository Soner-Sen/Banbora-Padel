class AnalyticsEvent {
  AnalyticsEvent({
    required this.name,
    this.parameters,
    this.userId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  final String name;

  final Map<String, dynamic>? parameters;

  final String? userId;

  final DateTime timestamp;

  AnalyticsEvent copyWith({
    String? name,
    Map<String, dynamic>? parameters,
    String? userId,
    DateTime? timestamp,
  }) => AnalyticsEvent(
    name: name ?? this.name,
    parameters: parameters ?? this.parameters,
    userId: userId ?? this.userId,
    timestamp: timestamp ?? this.timestamp,
  );
}

class ScreenViewEvent {
  ScreenViewEvent({
    required this.screenName,
    this.screenClass,
    this.parameters,
  });

  final String screenName;

  final String? screenClass;

  final Map<String, dynamic>? parameters;
}

class UserProperty {
  UserProperty({required this.name, required this.value});

  final String name;

  final dynamic value;
}

abstract class IAnalyticsService {
  void logEvent(AnalyticsEvent event);

  void logScreenView(ScreenViewEvent event);

  void setUserProperty(UserProperty property);

  void setUserId(String? userId);

  void setEnabled(bool enabled);

  bool get isEnabled;

  Future<void> clearUserData();

  void setUserProperties(List<UserProperty> properties);

  void resetAnalyticsData();
}

class AnalyticsService implements IAnalyticsService {
  AnalyticsService({bool isEnabled = true}) : _isEnabled = isEnabled;
  final bool _isEnabled;
  String? _userId;

  @override
  void logEvent(AnalyticsEvent event) {
    if (!_isEnabled) {
      return;
    }

    // TODO: Integrate with actual analytics SDK
    // Example: FirebaseAnalytics.instance.logEvent(
    //   name: event.name,
    //   parameters: event.parameters,
    // );

    _logToConsole(event);
  }

  @override
  void logScreenView(ScreenViewEvent event) {
    if (!_isEnabled) {
      return;
    }

    // TODO: Integrate with actual analytics SDK
    // Example: FirebaseAnalytics.instance.logScreenView(
    //   screenName: event.screenName,
    //   screenClass: event.screenClass,
    // );

    _logScreenViewToConsole(event);
  }

  @override
  void setUserProperty(UserProperty property) {
    if (!_isEnabled) {
      return;
    }

    // TODO: Integrate with actual analytics SDK
  }

  @override
  void setUserId(String? userId) {
    _userId = userId;

    // TODO: Integrate with actual analytics SDK
    // Example: FirebaseAnalytics.instance.setUserId(userId);
  }

  @override
  void setEnabled(bool enabled) {
    // TODO: Integrate with actual analytics SDK
  }

  @override
  bool get isEnabled => _isEnabled;

  @override
  Future<void> clearUserData() async {
    _userId = null;

    // TODO: Integrate with actual analytics SDK
  }

  @override
  void setUserProperties(List<UserProperty> properties) {
    if (!_isEnabled) {
      return;
    }

    // TODO: Integrate with actual analytics SDK
  }

  @override
  void resetAnalyticsData() {
    _userId = null;

    // TODO: Integrate with actual analytics SDK
  }

  void _logToConsole(AnalyticsEvent event) {
    assert(() {
      print('[Analytics] Event: ${event.name}');
      if (event.parameters != null) {
        print('[Analytics] Parameters: ${event.parameters}');
      }
      return true;
    }());
  }

  void _logScreenViewToConsole(ScreenViewEvent event) {
    assert(() {
      print('[Analytics] Screen: ${event.screenName}');
      if (event.screenClass != null) {
        print('[Analytics] Class: ${event.screenClass}');
      }
      return true;
    }());
  }
}

class AnalyticsEvents {
  AnalyticsEvents._();

  // Auth events
  static const String authLoginAttempt = 'auth_login_attempt';
  static const String authLoginSuccess = 'auth_login_success';
  static const String authLoginFailed = 'auth_login_failed';
  static const String authLogout = 'auth_logout';
  static const String authRegisterAttempt = 'auth_register_attempt';
  static const String authRegisterSuccess = 'auth_register_success';
  static const String authRegisterFailed = 'auth_register_failed';
  static const String authPasswordReset = 'auth_password_reset';

  static const String appOpened = 'app_opened';
  static const String appClosed = 'app_closed';
  static const String appBackgrounded = 'app_backgrounded';
  static const String appForegrounded = 'app_foregrounded';

  static const String bookingCreated = 'booking_created';
  static const String bookingCancelled = 'booking_cancelled';
  static const String bookingViewed = 'booking_viewed';

  static const String errorOccurred = 'error_occurred';
  static const String networkError = 'network_error';
}

class AnalyticsParams {
  AnalyticsParams._();

  static const String userId = 'user_id';
  static const String timestamp = 'timestamp';
  static const String screenName = 'screen_name';
  static const String errorCode = 'error_code';
  static const String errorMessage = 'error_message';

  static const String authMethod = 'auth_method';
  static const String loginDuration = 'login_duration';

  static const String bookingId = 'booking_id';
  static const String courtId = 'court_id';
  static const String bookingDate = 'booking_date';
  static const String bookingDuration = 'booking_duration';
}
