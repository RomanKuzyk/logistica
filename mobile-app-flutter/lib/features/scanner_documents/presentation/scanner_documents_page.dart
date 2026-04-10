import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/app/app_services.dart';
import 'package:mobile_app_flutter/core/api/api_exceptions.dart';
import 'package:mobile_app_flutter/features/scanner_capture/presentation/scanner_capture_page.dart';
import 'package:mobile_app_flutter/features/scanner_documents/data/scanner_documents_repository.dart';
import 'package:mobile_app_flutter/features/scanner_documents/domain/scanned_shipment_number.dart';
import 'package:mobile_app_flutter/features/scanner_documents/domain/scanner_document.dart';
import 'package:mobile_app_flutter/shared/widgets/legacy_alert_dialog.dart';

class ScannerDocumentsPage extends StatefulWidget {
  const ScannerDocumentsPage({
    super.key,
    required this.services,
    required this.userIdRef,
  });

  final AppServices services;
  final String userIdRef;

  @override
  State<ScannerDocumentsPage> createState() => _ScannerDocumentsPageState();
}

class _ScannerDocumentsPageState extends State<ScannerDocumentsPage> {
  late final ScannerDocumentsRepository _repository;
  late final TextEditingController _scanController;
  ScannerDocument _currentDocument = const ScannerDocument(
    idRef: '',
    number: '',
    dateTime: '',
    docType: '',
    userIdRef: '',
    scan: '',
  );
  List<ScannedShipmentNumber> _shipments = const <ScannedShipmentNumber>[];
  String _officeLabel = '';
  String _infoLabel = '';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _repository =
        ScannerDocumentsRepository(apiClient: widget.services.apiClient);
    _scanController = TextEditingController();
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _openScanner() async {
    final String? scanned = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (_) => const ScannerCapturePage()),
    );
    if (scanned != null && scanned.isNotEmpty) {
      await _processScan(scanned);
    }
  }

  Future<void> _processEnteredText(String value) async {
    final String normalized = _normalizeSubmittedText(value);
    if (normalized.isEmpty) {
      return;
    }
    _scanController.clear();
    await _processScan(normalized);
  }

  String _normalizeSubmittedText(String value) {
    final String finishChars = _decodeHexScannerFinish(
      widget.services.settingsStore.scannerFinishCharacters,
    );
    String normalized = value.toUpperCase();
    if (finishChars.isNotEmpty) {
      normalized = normalized.replaceAll(finishChars, '');
    }
    normalized = normalized.replaceAll('\n', '').replaceAll('\r', '').trim();
    return normalized;
  }

  String _decodeHexScannerFinish(String hexPattern) {
    final RegExp regex = RegExp(r'(0x)?([0-9A-Fa-f]{2})');
    final Iterable<RegExpMatch> matches = regex.allMatches(hexPattern);
    return matches
        .map((RegExpMatch match) =>
            String.fromCharCode(int.parse(match.group(2)!, radix: 16)))
        .join();
  }

  Future<void> _processScan(String scan) async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      if (scan.startsWith('-')) {
        final List<ScannerDocument> docs = await _repository.readDocumentByScan(
          scan: scan,
          userIdRef: widget.userIdRef,
        );
        if (!mounted) {
          return;
        }
        if (docs.isEmpty) {
          _resetDocumentState();
          await _showError(
              'Errors', 'Cell $scan not found. Please scan CELL !!!');
        } else {
          final ScannerDocument selected = docs.first.copyWith(number: '');
          _currentDocument = selected;
          _officeLabel = scan.split('-').length >= 4 ? scan.split('-')[3] : '';
          _infoLabel = '';
          await _reloadCurrentDocumentResult();
        }
      } else if (scan.startsWith('+')) {
        if (_currentDocument.isEmpty) {
          await _showError(
            'Errors',
            'Documents not scaning. Please first scan DOCUMENTS !!!',
          );
        } else {
          _currentDocument = _currentDocument.copyWith(number: scan);
          _infoLabel = scan.replaceAll('+', '  ');
          await _reloadCurrentDocumentResult();
        }
      } else {
        if (_currentDocument.isEmpty) {
          await _showError(
            'Errors',
            'Documents not scaning. Please first scan DOCUMENTS !!!',
          );
        } else if (_shipments.any((ScannedShipmentNumber item) =>
            item.number.toUpperCase() == scan.toUpperCase())) {
          await _showError(
            'Warning',
            'The barcode has already been scanned : $scan',
          );
        } else {
          final ScannerDocument payload = _currentDocument.copyWith(scan: scan);
          final result = await _repository.pushDocument(payload);
          if (!mounted) {
            return;
          }
          if (result.errorCode != 0) {
            await _showError(
                'Atantion', 'Loading error : ${result.errorDetail}');
          } else {
            setState(() {
              _shipments = <ScannedShipmentNumber>[
                ScannedShipmentNumber(number: scan),
                ..._shipments,
              ];
            });
          }
        }
      }
    } on FormatException catch (error) {
      await _showError('Atantion', error.message);
    } on ApiException catch (error) {
      await _showError('Atantion', 'Loading error : ${error.message}');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _reloadCurrentDocumentResult() async {
    final List<ScannedShipmentNumber> shipments =
        await _repository.readDocumentResult(_currentDocument);
    if (!mounted) {
      return;
    }
    setState(() {
      _shipments = shipments;
    });
  }

  void _resetDocumentState() {
    setState(() {
      _currentDocument = const ScannerDocument(
        idRef: '',
        number: '',
        dateTime: '',
        docType: '',
        userIdRef: '',
        scan: '',
      );
      _officeLabel = '';
      _infoLabel = '';
      _shipments = const <ScannedShipmentNumber>[];
    });
  }

  Future<void> _showError(String title, String message) {
    return showLegacyAlertDialog(
      context,
      title: title,
      message: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('OFFICE'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: <Widget>[
          Text(
            _officeLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _infoLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 25,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _scanController,
                  enabled: !_busy,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    hintText: 'Please scan text',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    filled: true,
                    fillColor: Color(0xFFF2F2F7),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                  ),
                  onSubmitted: _processEnteredText,
                  onChanged: (String value) {
                    final String finish = _decodeHexScannerFinish(
                      widget.services.settingsStore.scannerFinishCharacters,
                    );
                    if ((finish.isNotEmpty && value.contains(finish)) ||
                        value.contains('\n')) {
                      _processEnteredText(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _busy ? null : _openScanner,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1877F2),
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: const Text('SCAN'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._shipments.map(
            (ScannedShipmentNumber item) => Dismissible(
              key: ValueKey<String>('shipment-${item.number}'),
              direction: DismissDirection.endToStart,
              onDismissed: (_) {
                setState(() {
                  _shipments = _shipments
                      .where((ScannedShipmentNumber row) =>
                          row.number != item.number)
                      .toList();
                });
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE6E6E6)),
                  ),
                ),
                child: Text(
                  item.number,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
