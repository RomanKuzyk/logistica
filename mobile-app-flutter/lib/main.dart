import 'package:flutter/widgets.dart';
import 'package:mobile_app_flutter/app/app_services.dart';
import 'package:mobile_app_flutter/app/global_cars_app.dart';
import 'package:mobile_app_flutter/core/api/api_client.dart';
import 'package:mobile_app_flutter/core/config/app_config.dart';
import 'package:mobile_app_flutter/core/logging/app_logger.dart';
import 'package:mobile_app_flutter/core/media/aws_media_storage_service.dart';
import 'package:mobile_app_flutter/core/media/legacy_media_service.dart';
import 'package:mobile_app_flutter/core/media/pending_media_upload_store.dart';
import 'package:mobile_app_flutter/core/printing/legacy_print_service.dart';
import 'package:mobile_app_flutter/core/storage/local_settings_store.dart';
import 'package:mobile_app_flutter/features/auth/data/auth_repository.dart';
import 'package:mobile_app_flutter/features/auth/data/device_identity_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AppConfig config = AppConfig.fromEnvironment();
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  final LocalSettingsStore settingsStore = LocalSettingsStore();
  await settingsStore.init();
  final PendingMediaUploadStore pendingMediaUploadStore =
      PendingMediaUploadStore();
  await pendingMediaUploadStore.init();

  final AppLogger logger = AppLogger();
  final DeviceIdentityService deviceIdentityService = DeviceIdentityService(
    settingsStore: settingsStore,
    logger: logger,
  );
  final ApiClient apiClient = ApiClient(config: config, logger: logger);
  final AwsMediaStorageService awsMediaStorageService = AwsMediaStorageService(
    config: config,
    logger: logger,
  );
  final LegacyMediaService mediaService = LegacyMediaService(
    storageService: awsMediaStorageService,
    uploadStore: pendingMediaUploadStore,
    apiClient: apiClient,
    logger: logger,
  );
  final LegacyPrintService printService = LegacyPrintService(
    config: config,
    logger: logger,
  );
  final AuthRepository authRepository = AuthRepository(
    apiClient: apiClient,
    deviceIdentityService: deviceIdentityService,
    logger: logger,
  );

  final AppServices services = AppServices(
    config: config,
    logger: logger,
    settingsStore: settingsStore,
    apiClient: apiClient,
    authRepository: authRepository,
    mediaService: mediaService,
    printService: printService,
    appVersionLabel:
        'Version ${packageInfo.version} (${packageInfo.buildNumber})',
  );

  runApp(GlobalCarsApp(services: services));
}
