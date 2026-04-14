class ErrorReport {
  ErrorReport({
    required this.id,
    required this.type,
    required this.message,
    this.stackTrace,
    this.deviceInfo,
    this.appVersion,
    this.buildNumber,
    DateTime? timestamp,
    this.userId,
    this.context,
  }) : timestamp = timestamp ?? DateTime.now();

  final String id;

  final String type;

  final String message;

  final String? stackTrace;

  final Map<String, dynamic>? deviceInfo;

  final String? appVersion;

  final String? buildNumber;

  final DateTime timestamp;

  final String? userId;

  final Map<String, dynamic>? context;
}

class PerformanceMetric {
  PerformanceMetric({
    required this.name,
    required this.value,
    this.unit,
    DateTime? timestamp,
    this.tags,
  }) : timestamp = timestamp ?? DateTime.now();

  final String name;

  final double value;

  final String? unit;

  final DateTime timestamp;

  final Map<String, String>? tags;
}

abstract class IMonitoringService {
  void recordError(
    Object error, {
    StackTrace? stackTrace,
    String? reason,
    Map<String, dynamic>? context,
  });

  void recordFatalError(
    Object error, {
    StackTrace? stackTrace,
    String? reason,
    Map<String, dynamic>? context,
  });

  void recordMetric(PerformanceMetric metric);

  PerformanceSpan startSpan(String name, {Map<String, String>? tags});

  void setUserId(String? userId);

  void addBreadcrumb(String message, {Map<String, dynamic>? data});

  void clearBreadcrumbs();

  void setEnabled(bool enabled);

  bool get isEnabled;
}

class PerformanceSpan {
  PerformanceSpan({
    required this.name,
    DateTime? startTime,
    Map<String, String>? tags,
  }) : startTime = startTime ?? DateTime.now(),
       tags = tags ?? {};

  final String name;

  final DateTime startTime;

  DateTime? endTime;

  Duration? get duration => endTime?.difference(startTime);

  bool get isStopped => endTime != null;

  final Map<String, String> tags;

  void stop() {
    endTime = DateTime.now();
  }

  void addTag(String key, String value) {
    tags[key] = value;
  }
}

/// Monitoring service implementation placeholder.
/// TODO: Firebase Crashlytics implementation
class MonitoringService implements IMonitoringService {
  MonitoringService({bool isEnabled = true}) : _isEnabled = isEnabled;
  final bool _isEnabled;
  final List<String> _breadcrumbs = [];

  @override
  void recordError(
    Object error, {
    StackTrace? stackTrace,
    String? reason,
    Map<String, dynamic>? context,
  }) {
    if (!_isEnabled) {
      return;
    }

    _logToConsole('ERROR', error, stackTrace, reason, context);
  }

  @override
  void recordFatalError(
    Object error, {
    StackTrace? stackTrace,
    String? reason,
    Map<String, dynamic>? context,
  }) {
    if (!_isEnabled) {
      return;
    }

    // TODO: Integrate with actual monitoring SDK
    _logToConsole('FATAL', error, stackTrace, reason, context);
  }

  @override
  void recordMetric(PerformanceMetric metric) {
    if (!_isEnabled) {
      return;
    }

    // TODO: Integrate with actual monitoring SDK
    // Example: FirebasePerformance.instance.logMetric(
    //   name: metric.name,
    //   value: metric.value,
    //   unit: metric.unit,
    // );
  }

  @override
  PerformanceSpan startSpan(String name, {Map<String, String>? tags}) =>
      PerformanceSpan(name: name, tags: tags);

  @override
  void setUserId(String? userId) {
    // TODO: Integrate with actual monitoring SDK
  }

  @override
  void addBreadcrumb(String message, {Map<String, dynamic>? data}) {
    if (!_isEnabled) {
      return;
    }

    _breadcrumbs.add(message);

    // TODO: Integrate with actual monitoring SDK
  }

  @override
  void clearBreadcrumbs() {
    _breadcrumbs.clear();

    // TODO: Integrate with actual monitoring SDK
  }

  @override
  void setEnabled(bool enabled) {
    // TODO: Integrate with actual monitoring SDK
  }

  @override
  bool get isEnabled => _isEnabled;

  void _logToConsole(
    String level,
    Object error,
    StackTrace? stackTrace,
    String? reason,
    Map<String, dynamic>? context,
  ) {
    // Development logging - remove in production
    assert(() {
      print('[$level] $error');
      if (reason != null) {
        print('Reason: $reason');
      }
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
      if (context != null) {
        print('Context: $context');
      }
      return true;
    }());
  }
}

IMonitoringService? _globalMonitoringService;

void setMonitoringService(IMonitoringService service) {
  _globalMonitoringService = service;
}

IMonitoringService get monitoringService =>
    _globalMonitoringService ?? MonitoringService();
