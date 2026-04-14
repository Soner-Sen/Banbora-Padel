import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/config.dart';
import '../core/local_storage/local_storage.dart';
import '../core/logging/logging.dart';
import '../core/monitoring/monitoring.dart';
import '../core/network/network.dart';

class AppBootstrap {
  AppBootstrap({AppLogger? logger}) : _logger = logger ?? LoggerFactory.noOp();
  final AppLogger _logger;

  /// This should be called once before runApp().
  /// Returns the initialized services that can be used for DI setup.
  Future<BootstrapResult> initialize() async {
    _logger.info('Starting app bootstrap...');

    _initializeConfig();
    _logger.info('Configuration initialized');

    _setupSystemUI();

    final prefs = await _initLocalStorage();
    _logger.info('Local storage initialized');

    await _initHive();
    _logger.info('Hive initialized');

    final networkInfo = NetworkInfoImpl();
    _logger.info('Network monitoring initialized');

    _initMonitoring();
    _logger.info('Monitoring service initialized');

    _logger.info('Bootstrap completed successfully');

    return BootstrapResult(sharedPreferences: prefs, networkInfo: networkInfo);
  }

  void _initializeConfig() {
    final environment = EnvironmentVariables.parseEnvironment(
      EnvironmentVariables.flutterEnv,
    );
    final flavor = EnvironmentVariables.parseFlavor(
      EnvironmentVariables.buildFlavor,
    );

    AppConfig.initialize(
      environment: environment,
      flavor: flavor,
      isDebug: EnvironmentVariables.isDebug,
      isRelease: EnvironmentVariables.isRelease,
      isProfile: EnvironmentVariables.isProfile,
    );
  }

  void _setupSystemUI() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Future<SharedPreferences> _initLocalStorage() async =>
      SharedPreferences.getInstance();

  Future<void> _initHive() async {
    await Hive.initFlutter();
  }

  void _initMonitoring() {
    final monitoringService = MonitoringService(
      isEnabled: AppConfig.instance.enableCrashReporting,
    );
    setMonitoringService(monitoringService);
  }

  Future<void> dispose() async {
    _logger.info('Disposing app resources...');

    await Hive.close();
    _logger.info('Hive closed');
  }
}

class BootstrapResult {
  const BootstrapResult({
    required this.sharedPreferences,
    required this.networkInfo,
  });

  final SharedPreferences sharedPreferences;

  final INetworkInfo networkInfo;
}

extension BootstrapResultX on BootstrapResult {
  ILocalStorage get localStorage => SharedPreferencesStorage(sharedPreferences);
}
