class LegacyRpcResult {
  const LegacyRpcResult({
    required this.errorCode,
    required this.errorDetail,
    required this.idRef,
  });

  final int errorCode;
  final String errorDetail;
  final String idRef;

  bool get isSuccess => errorCode == 0;
}
