import 'package:mobile_app_flutter/core/api/api_client.dart';
import 'package:mobile_app_flutter/core/logging/app_logger.dart';
import 'package:mobile_app_flutter/features/auth/data/device_identity_service.dart';
import 'package:mobile_app_flutter/features/auth/domain/auth_user.dart';
import 'package:mobile_app_flutter/features/auth/domain/device_registration.dart';

class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required DeviceIdentityService deviceIdentityService,
    required AppLogger logger,
  })  : _apiClient = apiClient,
        _deviceIdentityService = deviceIdentityService,
        _logger = logger;

  final ApiClient _apiClient;
  final DeviceIdentityService _deviceIdentityService;
  final AppLogger _logger;

  Future<String> getDeviceIdentity() {
    return _deviceIdentityService.getDeviceIdentity();
  }

  Future<String?> fetchBackendVersion() async {
    final List<Map<String, dynamic>> items = await _apiClient.execute(
      function: 'VERSION',
      parameter: '',
    );
    if (items.isEmpty) {
      return null;
    }
    return items.first['VERSION']?.toString();
  }

  Future<DeviceRegistration> checkDeviceRegistration() async {
    final String deviceId = await getDeviceIdentity();
    final List<Map<String, dynamic>> items = await _apiClient.execute(
      function: 'MK_SELECT_EMPLOEEY',
      parameter: _quote(deviceId),
    );

    if (items.isEmpty) {
      return DeviceRegistration(deviceId: deviceId);
    }

    final Map<String, dynamic> first = items.first;
    return DeviceRegistration(
      deviceId: deviceId,
      userId: first['userId']?.toString(),
      typeUserId: first['TypeUserId']?.toString(),
      condigoId: first['condigoId']?.toString(),
    );
  }

  Future<AuthUser> loadRegisteredUser(DeviceRegistration registration) async {
    final String userId = registration.userId ?? '';
    final List<Map<String, dynamic>> items = await _apiClient.execute(
      function: 'SELECT_EMPLOEEY',
      parameter: userId,
    );

    final String name =
        items.isEmpty ? '' : (items.first['name']?.toString() ?? '');
    _logger.info('Loaded employee profile for $userId');

    return AuthUser(
      userId: userId,
      deviceId: registration.deviceId,
      displayName: name,
      typeUserId: registration.typeUserId ?? '',
    );
  }

  Future<AuthUser> registerDeviceToEmployee(String employeeId) async {
    final String deviceId = await getDeviceIdentity();

    await _apiClient.execute(
      function: 'MK_DELETE_EMPLOEEY',
      parameter: _quote(deviceId),
    );

    await _apiClient.execute(
      function: 'MK_INSERT_EMPLOEEY',
      parameter: '${_quote(employeeId)}, ${_quote(deviceId)}',
    );

    return loadRegisteredUser(
      DeviceRegistration(deviceId: deviceId, userId: employeeId),
    );
  }

  Future<void> disconnectDevice() async {
    final String deviceId = await getDeviceIdentity();
    await _apiClient.execute(
      function: 'MK_DELETE_EMPLOEEY',
      parameter: _quote(deviceId),
    );
  }

  static String _quote(String value) => '"$value"';
}
