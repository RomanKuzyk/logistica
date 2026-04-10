class ScannerDocument {
  const ScannerDocument({
    required this.idRef,
    required this.number,
    required this.dateTime,
    required this.docType,
    required this.userIdRef,
    required this.scan,
  });

  final String idRef;
  final String number;
  final String dateTime;
  final String docType;
  final String userIdRef;
  final String scan;

  ScannerDocument copyWith({
    String? idRef,
    String? number,
    String? dateTime,
    String? docType,
    String? userIdRef,
    String? scan,
  }) {
    return ScannerDocument(
      idRef: idRef ?? this.idRef,
      number: number ?? this.number,
      dateTime: dateTime ?? this.dateTime,
      docType: docType ?? this.docType,
      userIdRef: userIdRef ?? this.userIdRef,
      scan: scan ?? this.scan,
    );
  }

  bool get isEmpty =>
      idRef.isEmpty && number.isEmpty && dateTime.isEmpty && docType.isEmpty;
}
