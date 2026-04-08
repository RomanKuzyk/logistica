import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:mobile_app_flutter/core/config/app_config.dart';
import 'package:mobile_app_flutter/core/logging/app_logger.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

enum LegacyPrintStatus {
  completed,
  cancelled,
  dataUnavailable,
  failed,
}

class LegacyPrintResult {
  const LegacyPrintResult({
    required this.status,
    this.errorMessage = '',
  });

  final LegacyPrintStatus status;
  final String errorMessage;

  bool get isCompleted => status == LegacyPrintStatus.completed;
}

class LegacyPrintService {
  LegacyPrintService({
    required AppConfig config,
    required AppLogger logger,
    http.Client? httpClient,
  })  : _config = config,
        _logger = logger,
        _httpClient = httpClient ?? http.Client();

  final AppConfig _config;
  final AppLogger _logger;
  final http.Client _httpClient;

  Future<LegacyPrintResult> printParcelBarcode(String unpackingIdRef) async {
    return _printByRelativePath(
      'print/PRINT_PARCELS_BARCODE/$unpackingIdRef',
    );
  }

  Future<LegacyPrintResult> printOrderLabel(String orderIdRef) {
    return _printByRelativePath('print/LABEL_ORDER/$orderIdRef');
  }

  Future<LegacyPrintResult> printOrderBuyLabel(String orderBuyIdRef) {
    return _printByRelativePath('print/LABEL_ORDER_BUY/$orderBuyIdRef');
  }

  Future<LegacyPrintResult> _printByRelativePath(String relativePath) async {
    if (relativePath.isEmpty || relativePath.endsWith('/')) {
      return const LegacyPrintResult(
        status: LegacyPrintStatus.dataUnavailable,
      );
    }

    final Uri uri = Uri.parse('${_config.normalizedApiExtUrl}$relativePath');
    try {
      final http.Response response = await _httpClient.get(uri);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return LegacyPrintResult(
          status: LegacyPrintStatus.failed,
          errorMessage: 'HTTP ${response.statusCode}',
        );
      }

      final Uint8List bodyBytes = response.bodyBytes;
      if (bodyBytes.isEmpty) {
        return const LegacyPrintResult(
          status: LegacyPrintStatus.dataUnavailable,
        );
      }

      final String contentType =
          response.headers['content-type']?.toLowerCase() ?? '';
      final Uint8List pdfBytes = await _ensurePdfBytes(bodyBytes, contentType);
      final bool completed = await Printing.layoutPdf(
        name: 'GlobalCars Logistica',
        onLayout: (_) async => pdfBytes,
      );

      return LegacyPrintResult(
        status: completed
            ? LegacyPrintStatus.completed
            : LegacyPrintStatus.cancelled,
      );
    } catch (error, stackTrace) {
      _logger.error(
        'Print failed for $relativePath',
        error: error,
        stackTrace: stackTrace,
      );
      return LegacyPrintResult(
        status: LegacyPrintStatus.failed,
        errorMessage: error.toString(),
      );
    }
  }

  Future<Uint8List> _ensurePdfBytes(
    Uint8List inputBytes,
    String contentType,
  ) async {
    final bool looksLikePdf = inputBytes.length >= 4 &&
        inputBytes[0] == 0x25 &&
        inputBytes[1] == 0x50 &&
        inputBytes[2] == 0x44 &&
        inputBytes[3] == 0x46;

    if (contentType.contains('pdf') || looksLikePdf) {
      return inputBytes;
    }

    final pw.Document document = pw.Document();
    final pw.MemoryImage image = pw.MemoryImage(inputBytes);
    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Center(
          child: pw.Image(image, fit: pw.BoxFit.contain),
        ),
      ),
    );
    return document.save();
  }
}
