import 'package:mobile_app_flutter/core/config/app_config.dart';
import 'package:mobile_app_flutter/core/logging/app_logger.dart';
import 'package:mobile_app_flutter/core/storage/local_settings_store.dart';
import 'package:mobile_app_flutter/features/auth/data/auth_repository.dart';

class AppServices {
  const AppServices({
    required this.config,
    required this.logger,
    required this.settingsStore,
    required this.authRepository,
  });

  final AppConfig config;
  final AppLogger logger;
  final LocalSettingsStore settingsStore;
  final AuthRepository authRepository;
}
