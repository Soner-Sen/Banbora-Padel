import 'package:logger/logger.dart' as logger_pkg;

enum LogLevel { verbose, debug, info, warning, error, fatal }

class LogEntry {
  LogEntry({
    required this.level,
    required this.message,
    this.module,
    this.error,
    this.stackTrace,
    this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  final LogLevel level;

  final String message;

  final String? module;

  final Object? error;

  final StackTrace? stackTrace;

  final Map<String, dynamic>? data;

  final DateTime timestamp;

  LogEntry copyWith({
    LogLevel? level,
    String? message,
    String? module,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
    DateTime? timestamp,
  }) => LogEntry(
    level: level ?? this.level,
    message: message ?? this.message,
    module: module ?? this.module,
    error: error ?? this.error,
    stackTrace: stackTrace ?? this.stackTrace,
    data: data ?? this.data,
    timestamp: timestamp ?? this.timestamp,
  );

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('[${timestamp.toIso8601String()}]');
    buffer.write('[${level.name.toUpperCase()}]');
    if (module != null) {
      buffer.write('[$module]');
    }
    buffer.write(' $message');
    if (error != null) {
      buffer.write('\nError: $error');
    }
    if (stackTrace != null) {
      buffer.write('\nStackTrace: $stackTrace');
    }
    if (data != null && data!.isNotEmpty) {
      buffer.write('\nData: $data');
    }
    return buffer.toString();
  }
}

abstract class AppLogger {
  void verbose(String message, {String? module, Map<String, dynamic>? data});

  void debug(String message, {String? module, Map<String, dynamic>? data});

  void info(String message, {String? module, Map<String, dynamic>? data});

  void warn(String message, {String? module, Map<String, dynamic>? data});

  void error(
    String message, {
    String? module,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  });

  void fatal(
    String message, {
    String? module,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  });

  void log(LogEntry entry);

  AppLogger child(String module);
}

class AppLoggerImpl implements AppLogger {
  AppLoggerImpl({
    required bool isDevelopment,
    String? module,
    logger_pkg.Logger? logger,
  }) : _logger =
           logger ??
           logger_pkg.Logger(
             level: isDevelopment
                 ? logger_pkg.Level.trace
                 : logger_pkg.Level.warning,
             printer: logger_pkg.PrettyPrinter(
               methodCount: isDevelopment ? 3 : 0,
               errorMethodCount: 8,
               lineLength: 120,
               colors: isDevelopment,
               printEmojis: isDevelopment,
               dateTimeFormat: logger_pkg.DateTimeFormat.onlyTimeAndSinceStart,
             ),
           ),
       _module = module,
       _isDevelopment = isDevelopment;
  final logger_pkg.Logger _logger;
  final String? _module;
  final bool _isDevelopment;

  @override
  void verbose(String message, {String? module, Map<String, dynamic>? data}) {
    _log(LogLevel.verbose, message, module: module, data: data);
  }

  @override
  void debug(String message, {String? module, Map<String, dynamic>? data}) {
    _log(LogLevel.debug, message, module: module, data: data);
  }

  @override
  void info(String message, {String? module, Map<String, dynamic>? data}) {
    _log(LogLevel.info, message, module: module, data: data);
  }

  @override
  void warn(String message, {String? module, Map<String, dynamic>? data}) {
    _log(LogLevel.warning, message, module: module, data: data);
  }

  @override
  void error(
    String message, {
    String? module,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _log(
      LogLevel.error,
      message,
      module: module,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  @override
  void fatal(
    String message, {
    String? module,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _log(
      LogLevel.fatal,
      message,
      module: module,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  @override
  void log(LogEntry entry) {
    _log(
      entry.level,
      entry.message,
      module: entry.module,
      error: entry.error,
      stackTrace: entry.stackTrace,
      data: entry.data,
    );
  }

  @override
  AppLogger child(String module) {
    final fullModule = _module != null ? '$_module.$module' : module;
    return AppLoggerImpl(
      isDevelopment: _isDevelopment,
      module: fullModule,
      logger: _logger,
    );
  }

  void _log(
    LogLevel level,
    String message, {
    String? module,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    final logModule = module ?? _module ?? 'app';
    final formattedMessage = '[$logModule] $message';

    final pkgLevel = switch (level) {
      LogLevel.verbose => logger_pkg.Level.trace,
      LogLevel.debug => logger_pkg.Level.debug,
      LogLevel.info => logger_pkg.Level.info,
      LogLevel.warning => logger_pkg.Level.warning,
      LogLevel.error => logger_pkg.Level.error,
      LogLevel.fatal => logger_pkg.Level.fatal,
    };

    if (error != null || stackTrace != null) {
      _logger.log(
        pkgLevel,
        formattedMessage,
        error: error,
        stackTrace: stackTrace,
      );
    } else if (data != null && data.isNotEmpty) {
      _logger.log(pkgLevel, '$formattedMessage | Data: $data');
    } else {
      _logger.log(pkgLevel, formattedMessage);
    }
  }
}

class NoOpLogger implements AppLogger {
  const NoOpLogger();

  @override
  void verbose(String message, {String? module, Map<String, dynamic>? data}) {}

  @override
  void debug(String message, {String? module, Map<String, dynamic>? data}) {}

  @override
  void info(String message, {String? module, Map<String, dynamic>? data}) {}

  @override
  void warn(String message, {String? module, Map<String, dynamic>? data}) {}

  @override
  void error(
    String message, {
    String? module,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {}

  @override
  void fatal(
    String message, {
    String? module,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {}

  @override
  void log(LogEntry entry) {}

  @override
  AppLogger child(String module) => this;
}

class LoggerFactory {
  static AppLogger create({
    required String module,
    required bool isDevelopment,
  }) => AppLoggerImpl(isDevelopment: isDevelopment, module: module);

  static AppLogger noOp() => const NoOpLogger();
}
