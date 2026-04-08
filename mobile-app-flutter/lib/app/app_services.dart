import 'package:mobile_app_flutter/core/config/app_config.dart';
import 'package:mobile_app_flutter/core/logging/app_logger.dart';
import 'package:mobile_app_flutter/core/media/legacy_media_service.dart';
import 'package:mobile_app_flutter/core/printing/legacy_print_service.dart';
import 'package:mobile_app_flutter/core/storage/local_settings_store.dart';
import 'package:mobile_app_flutter/core/api/api_client.dart';
import 'package:mobile_app_flutter/features/auth/data/auth_repository.dart';

class AppServices {
  const AppServices({
    required this.config,
    required this.logger,
    required this.settingsStore,
    required this.apiClient,
    required this.authRepository,
    required this.mediaService,
    required this.printService,
    required this.appVersionLabel,
  });

  final AppConfig config;
  final AppLogger logger;
  final LocalSettingsStore settingsStore;
  final ApiClient apiClient;
  final AuthRepository authRepository;
  final LegacyMediaService mediaService;
  final LegacyPrintService printService;
  final String appVersionLabel;
}
