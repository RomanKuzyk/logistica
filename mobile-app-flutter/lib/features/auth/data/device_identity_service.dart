import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:mobile_app_flutter/core/logging/app_logger.dart';
import 'package:mobile_app_flutter/core/storage/local_settings_store.dart';

class DeviceIdentityService {
  DeviceIdentityService(
      {required LocalSettingsStore settingsStore, required AppLogger logger})
      : _settingsStore = settingsStore,
        _logger = logger;

  final LocalSettingsStore _settingsStore;
  final AppLogger _logger;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final AndroidId _androidId = const AndroidId();

  Future<String> getDeviceIdentity() async {
    try {
      if (Platform.isAndroid) {
        final String? androidId = await _androidId.getId();
        if (androidId != null && androidId.isNotEmpty) {
          return androidId;
        }
      }

      if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        final String? vendorId = iosInfo.identifierForVendor;
        if (vendorId != null && vendorId.isNotEmpty) {
          return vendorId;
        }
      }
    } catch (error, stackTrace) {
      _logger.warning('Falling back to installation ID',
          error: error, stackTrace: stackTrace);
    }

    return _settingsStore.getOrCreateInstallationId();
  }
}
