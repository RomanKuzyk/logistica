class AuthUser {
  const AuthUser({
    required this.userId,
    required this.deviceId,
    required this.displayName,
    required this.typeUserId,
    this.isDemo = false,
  });

  final String userId;
  final String deviceId;
  final String displayName;
  final String typeUserId;
  final bool isDemo;
}
