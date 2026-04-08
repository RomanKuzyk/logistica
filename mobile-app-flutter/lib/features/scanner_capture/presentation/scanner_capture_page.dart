import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerCapturePage extends StatefulWidget {
  const ScannerCapturePage({super.key});

  @override
  State<ScannerCapturePage> createState() => _ScannerCapturePageState();
}

class _ScannerCapturePageState extends State<ScannerCapturePage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const <BarcodeFormat>[
      BarcodeFormat.qrCode,
      BarcodeFormat.code128,
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.code39,
    ],
  );

  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finishWithCode(String code) {
    if (_handled) {
      return;
    }
    _handled = true;
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сканування')),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          MobileScanner(
            controller: _controller,
            onDetect: (BarcodeCapture capture) {
              final String? code = capture.barcodes.isNotEmpty
                  ? capture.barcodes.first.rawValue
                  : null;
              if (code != null && code.isNotEmpty) {
                _finishWithCode(code);
              }
            },
          ),
          IgnorePointer(
            child: Center(
              child: Container(
                width: 260,
                height: 180,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: FilledButton.tonal(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Скасувати'),
            ),
          ),
        ],
      ),
    );
  }
}
