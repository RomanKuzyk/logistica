import 'package:flutter/foundation.dart';
import 'package:mobile_app_flutter/core/api/api_exceptions.dart';
import 'package:mobile_app_flutter/core/logging/app_logger.dart';
import 'package:mobile_app_flutter/core/media/legacy_media_service.dart';
import 'package:mobile_app_flutter/core/media/legacy_photo_type.dart';
import 'package:mobile_app_flutter/features/order_search/data/receive_order_repository.dart';
import 'package:mobile_app_flutter/features/order_search/domain/legacy_rpc_result.dart';
import 'package:mobile_app_flutter/features/order_search/domain/order_item.dart';
import 'package:mobile_app_flutter/features/order_search/domain/trable.dart';

class OrderSearchDetailController extends ChangeNotifier {
  OrderSearchDetailController({
    required ReceiveOrderRepository repository,
    required AppLogger logger,
    required LegacyMediaService mediaService,
  })  : _repository = repository,
        _logger = logger,
        _mediaService = mediaService;

  final ReceiveOrderRepository _repository;
  final AppLogger _logger;
  final LegacyMediaService _mediaService;

  bool isBusy = false;
  bool isSumDisabled = false;
  String comments = '';
  String summa = '0.00';
  String facturePhotoFileName = '';
  String receivePhotoFileName = '';
  Trable selectedTrable = const Trable(idRef: '', name: '', typeTrables: '');

  Future<List<OrderItem>> loadOrderItems(String orderBuyIdRef) async {
    try {
      return await _repository.fetchOrderItems(orderBuyIdRef);
    } on ApiException {
      rethrow;
    } catch (error, stackTrace) {
      _logger.error(
        'ORDER_LIST unexpected error',
        error: error,
        stackTrace: stackTrace,
      );
      throw ApiParsingException(error.toString());
    }
  }

  Future<List<Trable>> loadTrables() async {
    try {
      return await _repository.fetchTrables();
    } on ApiException {
      rethrow;
    } catch (error, stackTrace) {
      _logger.error(
        'TRABLES_LIST unexpected error',
        error: error,
        stackTrace: stackTrace,
      );
      throw ApiParsingException(error.toString());
    }
  }

  void setComments(String value) {
    comments = value;
  }

  void setSumma(String value) {
    summa = value;
  }

  void setSelectedTrable(Trable value) {
    selectedTrable = value;
    notifyListeners();
  }

  void setFacturePhotoFileName(String value) {
    facturePhotoFileName = value;
    notifyListeners();
  }

  void setReceivePhotoFileName(String value) {
    receivePhotoFileName = value;
    notifyListeners();
  }

  void setSumDisabled(bool value) {
    isSumDisabled = value;
    if (value) {
      summa = '0.00';
    }
    notifyListeners();
  }

  String? validateReceive() {
    if (facturePhotoFileName.isEmpty) {
      return 'Зробіть фото перевізного документу !';
    }

    if (!isSumDisabled && _isZero(summa)) {
      return "Обов'язково повинна бути вказана сума...";
    }

    return null;
  }

  Future<LegacyRpcResult> rejectOrder(String orderBuyIdRef) async {
    return _runBusy(() => _repository.rejectOrder(orderBuyIdRef));
  }

  Future<LegacyRpcResult> receiveOrder(String orderBuyIdRef) async {
    return _runBusy(
      () => _repository.receiveOrder(
        orderBuyIdRef: orderBuyIdRef,
        trableIdRef: selectedTrable.idRef,
        comments: comments,
        photoFileName: receivePhotoFileName,
        facturePhotoFileName: facturePhotoFileName,
        summa: _normalizedSumma(),
      ),
    );
  }

  Future<String?> captureFacturePhoto(String orderBuyIdRef) async {
    return _runBusy(
      () => _mediaService.captureAndSavePhoto(
        idRef: orderBuyIdRef,
        typeIdRef: LegacyPhotoType.photoFacture,
      ),
    );
  }

  Future<String?> captureReceivePhoto(String orderBuyIdRef) async {
    return _runBusy(
      () => _mediaService.captureAndSavePhoto(
        idRef: orderBuyIdRef,
        typeIdRef: LegacyPhotoType.photoReceiveFromCourier,
      ),
    );
  }

  Future<T> _runBusy<T>(Future<T> Function() operation) async {
    isBusy = true;
    notifyListeners();
    try {
      return await operation();
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  String _normalizedSumma() {
    if (isSumDisabled) {
      return '0.00';
    }
    final String normalized = summa.trim().replaceAll(',', '.');
    final double value = double.tryParse(normalized) ?? 0;
    return value.toStringAsFixed(2);
  }

  bool _isZero(String value) {
    final double parsed =
        double.tryParse(value.trim().replaceAll(',', '.')) ?? 0;
    return parsed == 0;
  }
}
