import 'package:flutter/foundation.dart';
import 'package:mobile_app_flutter/app/app_services.dart';
import 'package:mobile_app_flutter/core/api/api_exceptions.dart';
import 'package:mobile_app_flutter/features/auth/domain/auth_user.dart';
import 'package:mobile_app_flutter/features/auth/domain/device_registration.dart';

const String _demoUserId = '0x9F160AFA66D752D711E680B67400E630';

enum AuthStatus {
  loading,
  registrationRequired,
  readyToStart,
  registering,
  startingWork,
  error,
}

class AuthController extends ChangeNotifier {
  AuthController({required AppServices services}) : _services = services;

  final AppServices _services;

  AuthStatus status = AuthStatus.loading;
  String? errorMessage;
  String? backendVersion;
  AuthUser? currentUser;
  String? deviceId;

  bool get canUseDemoMode => _services.config.allowDemoMode;

  Future<void> bootstrap() async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      backendVersion = await _services.authRepository.fetchBackendVersion();
    } catch (error, stackTrace) {
      _services.logger.warning('VERSION lookup failed', error: error, stackTrace: stackTrace);
    }

    try {
      final DeviceRegistration registration = await _services.authRepository.checkDeviceRegistration();
      deviceId = registration.deviceId;

      if (!registration.isRegistered) {
        status = AuthStatus.registrationRequired;
        notifyListeners();
        return;
      }

      currentUser = await _services.authRepository.loadRegisteredUser(registration);
      status = AuthStatus.readyToStart;
      notifyListeners();
    } on ApiException catch (error, stackTrace) {
      _services.logger.error('Auth bootstrap failed', error: error, stackTrace: stackTrace);
      status = AuthStatus.error;
      errorMessage = error.message;
      notifyListeners();
    } catch (error, stackTrace) {
      _services.logger.error('Unexpected auth bootstrap failure', error: error, stackTrace: stackTrace);
      status = AuthStatus.error;
      errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> registerEmployee(String employeeCode) async {
    status = AuthStatus.registering;
    errorMessage = null;
    notifyListeners();

    try {
      currentUser = await _services.authRepository.registerDeviceToEmployee(employeeCode.trim());
      status = AuthStatus.readyToStart;
      notifyListeners();
    } on ApiException catch (error, stackTrace) {
      _services.logger.error('Employee registration failed', error: error, stackTrace: stackTrace);
      status = AuthStatus.error;
      errorMessage = 'Registered error: ${error.message}';
      notifyListeners();
    } catch (error, stackTrace) {
      _services.logger.error('Unexpected registration failure', error: error, stackTrace: stackTrace);
      status = AuthStatus.error;
      errorMessage = 'Registered error: $error';
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      await _services.authRepository.disconnectDevice();
      currentUser = null;
      await bootstrap();
    } on ApiException catch (error, stackTrace) {
      _services.logger.error('Disconnect failed', error: error, stackTrace: stackTrace);
      status = AuthStatus.error;
      errorMessage = 'Unregistered error: ${error.message}';
      notifyListeners();
    }
  }

  void useDemoMode() {
    currentUser = const AuthUser(
      userId: _demoUserId,
      deviceId: 'DEMO',
      displayName: 'DEMO USER',
      typeUserId: '',
      isDemo: true,
    );
    status = AuthStatus.readyToStart;
    notifyListeners();
  }
}
