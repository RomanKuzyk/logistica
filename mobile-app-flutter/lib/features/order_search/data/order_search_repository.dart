import 'package:mobile_app_flutter/core/api/api_client.dart';
import 'package:mobile_app_flutter/features/order_search/domain/order_buy_search_item.dart';

class OrderSearchRepository {
  OrderSearchRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<OrderBuySearchItem>> searchReceiveOrders(String filter) async {
    final List<Map<String, dynamic>> items = await _apiClient.execute(
      function: 'ORDER_BUY_SEARCH',
      parameter: filter,
    );

    return items.map(OrderBuySearchItemMapper.fromApi).toList();
  }

  Future<List<OrderBuySearchItem>> searchUnpackingOrders(String filter) async {
    final List<Map<String, dynamic>> items = await _apiClient.execute(
      function: 'ORDER_BUY_SEARCH_UNPACKING',
      parameter: filter,
    );

    return items.map(OrderBuySearchItemMapper.fromApi).toList();
  }

  Future<List<OrderBuySearchItem>> searchAllOrders(String filter) async {
    final List<Map<String, dynamic>> items = await _apiClient.execute(
      function: 'ORDER_ALL_BUY_SEARCH',
      parameter: filter,
    );

    return items.map(OrderBuySearchItemMapper.fromApi).toList();
  }
}

class OrderBuySearchItemMapper {
  static OrderBuySearchItem fromApi(Map<String, dynamic> row) {
    return OrderBuySearchItem(
      idRef: _asString(row['IdRef']),
      isCod: _asBool(row['isCOD']),
      orderNumber: _asString(row['OrderNumber']),
      number: _asString(row['Number']),
      firstName: _asString(row['sellerAddress_firstName']),
      lastName: _asString(row['sellerAddress_lastName']),
      zipCode: _asString(row['sellerAddress_zipCode']),
      city: _asString(row['sellerAddress_city']),
      email: _asString(row['sellerAddress_email']),
      street: _asString(row['sellerAddress_street']),
      phoneNumber: _asString(row['sellerAddress_phoneNumber']),
      company: _asString(row['ssellerAddress_company']),
      summaCod: _asDouble(row['SummaCOD']),
      waybill: _asString(row['waybill']),
      orderDate: _asString(row['OrderDate']),
      processOfficePlAction: _asString(row['ProcessOfiicePLAction']),
      link: _asString(row['link']),
      nameOrders: _asString(row['NameOrders']),
      summaPayPl: _asDouble(row['SummaPayPL']),
      count: _asInt(row['Counts']),
    );
  }

  static String _asString(Object? value) => value?.toString() ?? '';

  static bool _asBool(Object? value) {
    if (value is bool) {
      return value;
    }
    final String normalized = value?.toString().toLowerCase() ?? '';
    return normalized == 'true' || normalized == '1';
  }

  static double _asDouble(Object? value) =>
      double.tryParse(value?.toString() ?? '') ?? 0;

  static int _asInt(Object? value) =>
      int.tryParse(value?.toString() ?? '') ?? 0;
}
