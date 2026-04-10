import 'dart:convert';

import 'package:mobile_app_flutter/core/api/api_client.dart';
import 'package:mobile_app_flutter/features/order_search/domain/legacy_rpc_result.dart';
import 'package:mobile_app_flutter/features/scanner_documents/domain/scanned_shipment_number.dart';
import 'package:mobile_app_flutter/features/scanner_documents/domain/scanner_document.dart';

class ScannerDocumentsRepository {
  ScannerDocumentsRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<ScannerDocument>> readDocumentByScan({
    required String scan,
    required String userIdRef,
  }) async {
    final List<String> parts = scan.split('-');
    if (parts.length != 4) {
      throw const FormatException('DOCUMENTS NOT FOUND !!!');
    }

    final String docType = parts[1];
    final String year = parts[2];
    final String number = parts[3];
    final List<Map<String, dynamic>> items = await _apiClient.execute(
      function: 'SCANNER_READDOCUMENT_$docType',
      parameter: "'$number', $year",
    );

    return items
        .map(
          (Map<String, dynamic> row) => ScannerDocument(
            idRef: row['IdRef']?.toString() ?? '',
            number: row['Number']?.toString() ?? '',
            dateTime: row['DateTime']?.toString() ?? '',
            docType: docType,
            userIdRef: userIdRef,
            scan: scan,
          ),
        )
        .toList();
  }

  Future<List<ScannedShipmentNumber>> readDocumentResult(
    ScannerDocument document,
  ) async {
    final List<Map<String, dynamic>> items = await _apiClient.execute(
      function: 'SCANNER_READDOCUMENT_RESULT',
      parameter:
          '${document.userIdRef} , ${document.idRef}, ${_quote(document.number)}',
    );

    return items
        .map(
          (Map<String, dynamic> row) =>
              ScannedShipmentNumber(number: row['scan']?.toString() ?? ''),
        )
        .toList();
  }

  Future<LegacyRpcResult> pushDocument(ScannerDocument document) async {
    final String payload = jsonEncode(<String, Object?>{
      'DateTime': _convertTo1cDate(document.dateTime),
      'IdRef': document.idRef,
      'Number': document.number,
      'Scan': document.scan,
      'UserIdRef': document.userIdRef,
      'docType': document.docType,
    });

    final List<Map<String, dynamic>> items = await _apiClient.execute(
      function: 'SCANNER_PUSHDOCUMENT',
      parameter: payload,
    );

    if (items.isEmpty) {
      return const LegacyRpcResult(errorCode: 0, errorDetail: '', idRef: '');
    }

    final Map<String, dynamic> row = items.first;
    return LegacyRpcResult(
      errorCode: int.tryParse(row['Error']?.toString() ?? '') ?? 0,
      errorDetail: row['ErrorsDetail']?.toString() ?? '',
      idRef: row['IdRef']?.toString() ?? '',
    );
  }

  String _convertTo1cDate(String value) {
    return value
        .replaceAll('-', '')
        .replaceAll(':', '')
        .replaceAll(' ', '')
        .replaceAll('T', '')
        .substring(
            0,
            value
                        .replaceAll('-', '')
                        .replaceAll(':', '')
                        .replaceAll(' ', '')
                        .replaceAll('T', '')
                        .length <
                    14
                ? value
                    .replaceAll('-', '')
                    .replaceAll(':', '')
                    .replaceAll(' ', '')
                    .replaceAll('T', '')
                    .length
                : 14);
  }

  String _quote(String value) => "'$value'";
}
