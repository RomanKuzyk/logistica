import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/app/app_services.dart';
import 'package:mobile_app_flutter/features/manifest/data/manifest_repository.dart';
import 'package:mobile_app_flutter/features/manifest/domain/manifest.dart';
import 'package:mobile_app_flutter/features/manifest/domain/manifest_shipment.dart';
import 'package:mobile_app_flutter/features/scanner_capture/presentation/scanner_capture_page.dart';
import 'package:mobile_app_flutter/shared/widgets/legacy_alert_dialog.dart';

class ManifestScanPage extends StatefulWidget {
  const ManifestScanPage({
    super.key,
    required this.manifest,
    required this.services,
  });

  final Manifest manifest;
  final AppServices services;

  @override
  State<ManifestScanPage> createState() => _ManifestScanPageState();
}

class _ManifestScanPageState extends State<ManifestScanPage> {
  late final ManifestRepository _repository;
  bool _loading = true;
  bool _busyAction = false;
  List<ManifestShipment> _shipments = const <ManifestShipment>[];

  @override
  void initState() {
    super.initState();
    _repository = ManifestRepository(apiClient: widget.services.apiClient);
    _loadShipments();
  }

  Future<void> _loadShipments() async {
    setState(() => _loading = true);
    try {
      final List<ManifestShipment> shipments =
          await _repository.fetchManifestShipments(widget.manifest.idRef);
      if (!mounted) {
        return;
      }
      setState(() {
        _shipments = shipments;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _loading = false);
      await showLegacyAlertDialog(
        context,
        title: 'Atantion',
        message: 'Loading error : $error',
      );
    }
  }

  Future<void> _scanAndAdd() async {
    if (_busyAction) {
      return;
    }
    final String? scanned = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => const ScannerCapturePage(),
      ),
    );
    if (!mounted || scanned == null || scanned.isEmpty) {
      return;
    }

    setState(() => _busyAction = true);
    try {
      final result = await _repository.addShipment(
        manifestIdRef: widget.manifest.idRef,
        barcode: scanned,
      );
      if (!mounted) {
        return;
      }
      if (result.errorCode != 0) {
        await showLegacyAlertDialog(
          context,
          title: 'Error',
          message: result.errorDetail,
        );
      } else {
        await _loadShipments();
        if (!mounted) {
          return;
        }
        await showLegacyAlertDialog(
          context,
          title: 'Completed',
          message: 'Замовлення додано в маніфест . Дякуємо !',
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      await showLegacyAlertDialog(
        context,
        title: 'Error',
        message: error.toString(),
      );
    } finally {
      if (mounted) {
        setState(() => _busyAction = false);
      }
    }
  }

  Future<bool> _deleteShipment(ManifestShipment shipment, int index) async {
    if (_busyAction) {
      return false;
    }
    setState(() => _busyAction = true);
    try {
      final result = await _repository.deleteShipment(
        manifestIdRef: widget.manifest.idRef,
        shipment: shipment,
      );
      if (!mounted) {
        return false;
      }
      if (result.errorCode != 0) {
        await showLegacyAlertDialog(
          context,
          title: 'Error',
          message: result.errorDetail,
        );
        return false;
      }
      setState(() {
        _shipments = List<ManifestShipment>.from(_shipments)..removeAt(index);
      });
      await showLegacyAlertDialog(
        context,
        title: 'Completed',
        message: 'Замовлення  видалено з маніфесту . Дякуємо !',
      );
      return true;
    } catch (error) {
      if (!mounted) {
        return false;
      }
      await showLegacyAlertDialog(
        context,
        title: 'Error',
        message: error.toString(),
      );
      return false;
    } finally {
      if (mounted) {
        setState(() => _busyAction = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(widget.manifest.number),
        actions: <Widget>[
          TextButton(
            onPressed: _busyAction ? null : _scanAndAdd,
            child: Text(
              _busyAction ? 'Зачекайте' : 'Скануємо',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _shipments.length,
              itemBuilder: (BuildContext context, int index) {
                final ManifestShipment item = _shipments[index];
                return Dismissible(
                  key: ValueKey<String>(
                    '${item.orderIdRef}-${item.orderNumber}-$index',
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) => _deleteShipment(item, index),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Container(
                    color:
                        index.isEven ? const Color(0xFFEDEDF1) : Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          item.orderNumber,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.orderDateTime,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.name,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
