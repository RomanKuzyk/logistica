import 'dart:convert';

class PendingMediaUpload {
  const PendingMediaUpload({
    required this.fileName,
    required this.localPath,
    required this.idRef,
    required this.typeIdRef,
    this.contentType = 'image/png',
  });

  final String fileName;
  final String localPath;
  final String idRef;
  final String typeIdRef;
  final String contentType;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'fileName': fileName,
      'localPath': localPath,
      'idRef': idRef,
      'typeIdRef': typeIdRef,
      'contentType': contentType,
    };
  }

  String encode() => jsonEncode(toJson());

  factory PendingMediaUpload.fromJson(Map<String, dynamic> json) {
    return PendingMediaUpload(
      fileName: json['fileName']?.toString() ?? '',
      localPath: json['localPath']?.toString() ?? '',
      idRef: json['idRef']?.toString() ?? '',
      typeIdRef: json['typeIdRef']?.toString() ?? '',
      contentType: json['contentType']?.toString() ?? 'image/png',
    );
  }

  factory PendingMediaUpload.decode(String raw) {
    return PendingMediaUpload.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }
}

class MediaSyncSummary {
  const MediaSyncSummary({
    required this.succeeded,
    required this.failed,
    required this.remaining,
  });

  final int succeeded;
  final int failed;
  final int remaining;
}
