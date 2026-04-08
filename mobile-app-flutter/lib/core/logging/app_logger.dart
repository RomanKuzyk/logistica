import 'dart:developer' as developer;

class AppLogger {
  const AppLogger();

  void info(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(message,
        name: 'mobile-app-flutter', error: error, stackTrace: stackTrace);
  }

  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'mobile-app-flutter.warning',
      error: error,
      stackTrace: stackTrace,
      level: 900,
    );
  }

  void error(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'mobile-app-flutter.error',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }
}
