import 'package:flutter/foundation.dart';
import 'package:mobile_app_flutter/core/api/api_exceptions.dart';
import 'package:mobile_app_flutter/core/logging/app_logger.dart';
import 'package:mobile_app_flutter/features/order_search/data/order_search_repository.dart';
import 'package:mobile_app_flutter/features/order_search/data/tracking_normalizer.dart';
import 'package:mobile_app_flutter/features/order_search/domain/order_buy_search_item.dart';
import 'package:mobile_app_flutter/features/order_search/domain/work_mode.dart';

enum OrderSearchStatus {
  idle,
  loading,
  loaded,
  empty,
  error,
}

class OrderSearchController extends ChangeNotifier {
  OrderSearchController({
    required OrderSearchRepository repository,
    required AppLogger logger,
    required this.mode,
  })  : _repository = repository,
        _logger = logger;

  final OrderSearchRepository _repository;
  final AppLogger _logger;
  final WorkMode mode;

  OrderSearchStatus status = OrderSearchStatus.idle;
  String searchInput = '';
  String normalizedQuery = '';
  String? errorMessage;
  List<OrderBuySearchItem> results = const <OrderBuySearchItem>[];
  int terminalEventId = 0;
  double totalCod = 0;

  bool get isBusy => status == OrderSearchStatus.loading;

  String get screenDescription => switch (mode) {
        WorkMode.receive =>
          'Будь ласка, внесіть текст для пошуку замовлення (викуп).',
        WorkMode.unpack =>
          'Відскануйте номер викупу для початку обслуговування',
        WorkMode.reprint => 'Будь ласка, внесіть текст для пошуку.',
        WorkMode.details => 'Будь ласка, внесіть текст для пошуку.',
        WorkMode.manifest => 'Режим ще не реалізований.',
      };

  void setSearchInput(String value) {
    searchInput = value;
    notifyListeners();
  }

  Future<void> applyScanResult(String rawValue) async {
    searchInput = rawValue;
    notifyListeners();
    await search();
  }

  Future<void> search() async {
    final String query = normalizeReceiveSearchInput(searchInput);
    normalizedQuery = query;

    if (query.isEmpty) {
      status = OrderSearchStatus.error;
      errorMessage = 'Не заповнено поле для пошуку.';
      results = const <OrderBuySearchItem>[];
      terminalEventId++;
      notifyListeners();
      return;
    }

    status = OrderSearchStatus.loading;
    errorMessage = null;
    results = const <OrderBuySearchItem>[];
    notifyListeners();

    try {
      final List<OrderBuySearchItem> items = switch (mode) {
        WorkMode.receive => await _repository.searchReceiveOrders(query),
        WorkMode.unpack => await _repository.searchUnpackingOrders(query),
        WorkMode.reprint => await _repository.searchReceiveOrders(query),
        WorkMode.details => await _repository.searchAllOrders(query),
        WorkMode.manifest =>
          throw const ApiParsingException('Цей режим ще не реалізований.'),
      };
      results = items;
      totalCod = items.fold<double>(
          0, (double sum, OrderBuySearchItem item) => sum + item.summaCod);
      status =
          items.isEmpty ? OrderSearchStatus.empty : OrderSearchStatus.loaded;
      terminalEventId++;
      notifyListeners();
    } on ApiBusinessException catch (error, stackTrace) {
      _logger.warning('ORDER_BUY_SEARCH business error',
          error: error, stackTrace: stackTrace);
      status = OrderSearchStatus.error;
      errorMessage = error.message;
      terminalEventId++;
      notifyListeners();
    } on ApiException catch (error, stackTrace) {
      _logger.error('ORDER_BUY_SEARCH API error',
          error: error, stackTrace: stackTrace);
      status = OrderSearchStatus.error;
      errorMessage = error.message;
      terminalEventId++;
      notifyListeners();
    } catch (error, stackTrace) {
      _logger.error('ORDER_BUY_SEARCH unexpected error',
          error: error, stackTrace: stackTrace);
      status = OrderSearchStatus.error;
      errorMessage = error.toString();
      terminalEventId++;
      notifyListeners();
    }
  }

  void clearTotal() {
    totalCod = 0;
    notifyListeners();
  }
}
