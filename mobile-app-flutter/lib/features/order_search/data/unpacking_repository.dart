import 'dart:convert';

import 'package:mobile_app_flutter/core/api/api_client.dart';
import 'package:mobile_app_flutter/features/order_search/domain/legacy_rpc_result.dart';
import 'package:mobile_app_flutter/features/order_search/domain/order_item.dart';
import 'package:mobile_app_flutter/features/order_search/domain/trable.dart';
import 'package:mobile_app_flutter/features/order_search/domain/unpacking_order_item_state.dart';

class UnpackingRepository {
  UnpackingRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<OrderItem>> fetchOrderItems(String orderBuyIdRef) async {
    final List<Map<String, dynamic>> items = await _apiClient.execute(
      function: 'ORDER_LIST',
      parameter: orderBuyIdRef,
    );

    return items.map(UnpackingOrderItemMapper.fromApi).toList();
  }

  Future<List<Trable>> fetchTrables() async {
    final List<Map<String, dynamic>> items = await _apiClient.execute(
      function: 'TRABLES_LIST',
      parameter: '',
    );

    return items.map(UnpackingTrableMapper.fromApi).toList();
  }

  Future<LegacyRpcResult> submitUnpacking({
    required String orderBuyIdRef,
    required UnpackingOrderItemState item,
  }) async {
    final String payload = jsonEncode(<String, Object?>{
      'Count': item.count,
      'TypeDocument': item.typeDocuments,
      'PhotoDocuments': item.photoDocumentsFileName,
      'OrderBuyIdRef': orderBuyIdRef,
      'TrableIdRef': item.trableIdRef,
      'OrderIdRef': item.orderItem.idRef,
      'Photo': item.photoFileName,
      'TrableComments': item.trableComments,
    });

    final List<Map<String, dynamic>> items = await _apiClient.execute(
      function: 'UNPACKING_ORDER_BUY',
      parameter: payload,
    );

    return UnpackingLegacyRpcResultMapper.fromItems(items);
  }
}

class UnpackingLegacyRpcResultMapper {
  static LegacyRpcResult fromItems(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return const LegacyRpcResult(
        errorCode: 0,
        errorDetail: '',
        idRef: '',
      );
    }

    final Map<String, dynamic> row = items.first;
    return LegacyRpcResult(
      errorCode: int.tryParse(row['Error']?.toString() ?? '') ?? 0,
      errorDetail: row['ErrorsDetail']?.toString() ?? '',
      idRef: row['UnpackingIdRef']?.toString() ?? '',
    );
  }
}

class UnpackingOrderItemMapper {
  static OrderItem fromApi(Map<String, dynamic> row) {
    return OrderItem(
      idRef: _asString(row['IdRef']),
      orderNumber: _asString(row['OrderNumber']),
      orderDate: _asString(row['OrderDate']),
      number: _asString(row['Number']),
      title: _asString(row['Title']),
      linkPhoto: _asString(row['LinkPhoto']),
      link: _asString(row['Link']),
      customRoute: _asString(row['CustomRoute']),
      deliveryType: _asString(row['DeliveryType']),
      count: _asInt(row['Count']),
      manager: _asString(row['Manager']),
    );
  }

  static String _asString(Object? value) => value?.toString() ?? '';

  static int _asInt(Object? value) =>
      int.tryParse(value?.toString() ?? '') ?? 0;
}

class UnpackingTrableMapper {
  static Trable fromApi(Map<String, dynamic> row) {
    return Trable(
      idRef: row['IdRef']?.toString() ?? '',
      name: row['Name']?.toString() ?? '',
      typeTrables: row['TypeTrables']?.toString() ?? '',
    );
  }
}
