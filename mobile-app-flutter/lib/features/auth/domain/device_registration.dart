class DeviceRegistration {
  const DeviceRegistration({
    required this.deviceId,
    this.userId,
    this.typeUserId,
    this.condigoId,
  });

  final String deviceId;
  final String? userId;
  final String? typeUserId;
  final String? condigoId;

  bool get isRegistered => userId != null && userId!.startsWith('0x');
}
