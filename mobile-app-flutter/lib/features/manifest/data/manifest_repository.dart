import 'dart:convert';

import 'package:mobile_app_flutter/core/api/api_client.dart';
import 'package:mobile_app_flutter/features/manifest/domain/manifest.dart';
import 'package:mobile_app_flutter/features/manifest/domain/manifest_shipment.dart';
import 'package:mobile_app_flutter/features/order_search/domain/legacy_rpc_result.dart';

class ManifestRepository {
  ManifestRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Manifest>> fetchOpenManifests() async {
    final List<Map<String, dynamic>> items = await _apiClient.execute(
      function: 'LIST_OPEN_MANIFEST',
      parameter: '',
    );

    return items.map(_mapManifest).toList();
  }

  Future<List<ManifestShipment>> fetchManifestShipments(
      String manifestIdRef) async {
    final List<Map<String, dynamic>> items = await _apiClient.execute(
      function: 'LIST_MANIFEST_SHIPMENTS',
      parameter: manifestIdRef,
    );

    return items.map(_mapManifestShipment).toList();
  }

  Future<LegacyRpcResult> addShipment({
    required String manifestIdRef,
    required String barcode,
  }) async {
    final String payload = jsonEncode(<String, Object?>{
      'ManifestIdRef': manifestIdRef,
      'OrderIdRef': '',
      'Barcode': barcode,
      'Mode': '0',
    });

    final List<Map<String, dynamic>> items = await _apiClient.execute(
      function: 'MANIFEST_ADD_DELETE',
      parameter: payload,
    );

    return _mapLegacyResult(items);
  }

  Future<LegacyRpcResult> deleteShipment({
    required String manifestIdRef,
    required ManifestShipment shipment,
  }) async {
    final String payload = jsonEncode(<String, Object?>{
      'ManifestIdRef': manifestIdRef,
      'OrderIdRef': shipment.orderIdRef,
      'Barcode': shipment.orderNumber,
      'Mode': '1',
    });

    final List<Map<String, dynamic>> items = await _apiClient.execute(
      function: 'MANIFEST_ADD_DELETE',
      parameter: payload,
    );

    return _mapLegacyResult(items);
  }

  Manifest _mapManifest(Map<String, dynamic> row) {
    return Manifest(
      idRef: row['IdRef']?.toString() ?? '',
      number: row['Number']?.toString() ?? '',
      dateTime: row['DateTime']?.toString() ?? '',
      customMethod: row['CustomMethod']?.toString() ?? '',
    );
  }

  ManifestShipment _mapManifestShipment(Map<String, dynamic> row) {
    return ManifestShipment(
      shipmentsIdRef: row['ShipmentsIdRef']?.toString() ?? '',
      orderIdRef: row['OrderIdRef']?.toString() ?? '',
      numberManifest: row['NumberManifest']?.toString() ?? '',
      name: row['Name']?.toString() ?? '',
      orderNumber: row['OrderNumber']?.toString() ?? '',
      orderDateTime: row['OrderDateTime']?.toString() ?? '',
    );
  }

  LegacyRpcResult _mapLegacyResult(List<Map<String, dynamic>> items) {
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
}
