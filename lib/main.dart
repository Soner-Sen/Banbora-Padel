import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';
import 'app/di.dart';
import 'core/logging/logging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final bootstrap = AppBootstrap();

  final logger = LoggerFactory.create(module: 'main', isDevelopment: true);

  logger.info('Starting application...');

  try {
    final bootstrapResult = await bootstrap.initialize();
    logger.info('Bootstrap completed');

    await setupDependencies(
      sharedPreferences: bootstrapResult.sharedPreferences,
      networkInfo: bootstrapResult.networkInfo,
    );
    logger.info('Dependencies registered');

    runApp(const SonrizeApp());

    logger.info('Application started');
  } catch (e, stackTrace) {
    logger.error(
      'Application startup failed',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow;
  }
}
