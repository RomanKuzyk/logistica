class AppConfig {
  const AppConfig({
    required this.apiUrl,
    required this.apiUser,
    required this.apiPassword,
    required this.apiSalt,
    required this.allowDemoMode,
  });

  factory AppConfig.fromEnvironment() {
    return AppConfig(
      apiUrl: const String.fromEnvironment(
        'GC_API_URL',
        defaultValue: 'https://api.globalcars.com.ua/api/v1',
      ),
      apiUser: const String.fromEnvironment('GC_API_USER', defaultValue: ''),
      apiPassword:
          const String.fromEnvironment('GC_API_PASSWORD', defaultValue: ''),
      apiSalt: const String.fromEnvironment('GC_API_SALT', defaultValue: ''),
      allowDemoMode:
          const bool.fromEnvironment('GC_ALLOW_DEMO_MODE', defaultValue: true),
    );
  }

  final String apiUrl;
  final String apiUser;
  final String apiPassword;
  final String apiSalt;
  final bool allowDemoMode;

  bool get hasApiCredentials =>
      apiUser.isNotEmpty && apiPassword.isNotEmpty && apiSalt.isNotEmpty;
}
