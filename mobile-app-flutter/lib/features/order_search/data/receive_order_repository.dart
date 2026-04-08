import 'dart:convert';

import 'package:mobile_app_flutter/core/api/api_client.dart';
import 'package:mobile_app_flutter/features/order_search/domain/legacy_rpc_result.dart';
import 'package:mobile_app_flutter/features/order_search/domain/order_item.dart';
import 'package:mobile_app_flutter/features/order_search/domain/trable.dart';

class ReceiveOrderRepository {
  ReceiveOrderRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  static const String rejectTrableIdRef = '0x828802CD7749C8A011EBC37E1568CB9A';

  final ApiClient _apiClient;

  Future<List<OrderItem>> fetchOrderItems(String orderBuyIdRef) async {
    final List<Map<String, dynamic>> items = await _apiClient.execute(
      function: 'ORDER_LIST',
      parameter: orderBuyIdRef,
    );

    return items.map(OrderItemMapper.fromApi).toList();
  }

  Future<List<Trable>> fetchTrables() async {
    final List<Map<String, dynamic>> items = await _apiClient.execute(
      function: 'TRABLES_LIST',
      parameter: '',
    );

    return items.map(TrableMapper.fromApi).toList();
  }

  Future<LegacyRpcResult> rejectOrder(String orderBuyIdRef) async {
    final String payload = jsonEncode(<String, Object?>{
      'IdRef': orderBuyIdRef,
      'TrableIdRef': rejectTrableIdRef,
    });

    final List<Map<String, dynamic>> items = await _apiClient.execute(
      function: 'REJECT_ORDER_BUY',
      parameter: payload,
    );

    return LegacyRpcResultMapper.fromItems(items);
  }

  Future<LegacyRpcResult> receiveOrder({
    required String orderBuyIdRef,
    required String trableIdRef,
    required String comments,
    required String photoFileName,
    required String facturePhotoFileName,
    required String summa,
  }) async {
    final String payload = jsonEncode(<String, Object?>{
      'IdRef': orderBuyIdRef,
      'TrableIdRef': trableIdRef,
      'Comments': comments,
      'PhotoFileName': photoFileName,
      'PhotoFileNameFacture': facturePhotoFileName,
      'Summa': summa,
    });

    final List<Map<String, dynamic>> items = await _apiClient.execute(
      function: 'RESIVE_ORDER_BUY',
      parameter: payload,
    );

    return LegacyRpcResultMapper.fromItems(items);
  }
}

class LegacyRpcResultMapper {
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
      idRef: row['IdRef']?.toString() ?? '',
    );
  }
}

class OrderItemMapper {
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

class TrableMapper {
  static Trable fromApi(Map<String, dynamic> row) {
    return Trable(
      idRef: row['IdRef']?.toString() ?? '',
      name: row['Name']?.toString() ?? '',
      typeTrables: row['TypeTrables']?.toString() ?? '',
    );
  }
}
