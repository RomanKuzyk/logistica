import 'package:flutter/widgets.dart';
import 'package:mobile_app_flutter/app/app_services.dart';
import 'package:mobile_app_flutter/app/global_cars_app.dart';
import 'package:mobile_app_flutter/core/api/api_client.dart';
import 'package:mobile_app_flutter/core/config/app_config.dart';
import 'package:mobile_app_flutter/core/logging/app_logger.dart';
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

  final AppLogger logger = AppLogger();
  final DeviceIdentityService deviceIdentityService = DeviceIdentityService(
    settingsStore: settingsStore,
    logger: logger,
  );
  final ApiClient apiClient = ApiClient(config: config, logger: logger);
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
    appVersionLabel:
        'Version ${packageInfo.version} (${packageInfo.buildNumber})',
  );

  runApp(GlobalCarsApp(services: services));
}
