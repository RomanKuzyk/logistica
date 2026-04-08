import 'package:flutter/foundation.dart';
import 'package:mobile_app_flutter/core/api/api_exceptions.dart';
import 'package:mobile_app_flutter/core/logging/app_logger.dart';
import 'package:mobile_app_flutter/core/media/legacy_media_service.dart';
import 'package:mobile_app_flutter/core/media/legacy_photo_type.dart';
import 'package:mobile_app_flutter/core/printing/legacy_print_service.dart';
import 'package:mobile_app_flutter/features/order_search/data/unpacking_repository.dart';
import 'package:mobile_app_flutter/features/order_search/domain/legacy_rpc_result.dart';
import 'package:mobile_app_flutter/features/order_search/domain/trable.dart';
import 'package:mobile_app_flutter/features/order_search/domain/unpacking_order_item_state.dart';

class UnpackingController extends ChangeNotifier {
  UnpackingController({
    required UnpackingRepository repository,
    required LegacyMediaService mediaService,
    required LegacyPrintService printService,
    required AppLogger logger,
  })  : _repository = repository,
        _mediaService = mediaService,
        _printService = printService,
        _logger = logger;

  final UnpackingRepository _repository;
  final LegacyMediaService _mediaService;
  final LegacyPrintService _printService;
  final AppLogger _logger;

  bool isLoading = false;
  bool isBusy = false;
  String? errorMessage;
  List<UnpackingOrderItemState> items = const <UnpackingOrderItemState>[];
  List<Trable> _trables = const <Trable>[];

  int get itemCount => items.length;

  Future<void> load(String orderBuyIdRef) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final loaded = await _repository.fetchOrderItems(orderBuyIdRef);
      items = loaded.map(UnpackingOrderItemState.fromOrderItem).toList();
    } on ApiException catch (error) {
      errorMessage = error.message;
    } catch (error, stackTrace) {
      _logger.error(
        'UNPACKING ORDER_LIST unexpected error',
        error: error,
        stackTrace: stackTrace,
      );
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Trable>> loadTrables() async {
    if (_trables.isNotEmpty) {
      return _trables;
    }

    try {
      _trables = await _repository.fetchTrables();
      return _trables;
    } on ApiException {
      rethrow;
    } catch (error, stackTrace) {
      _logger.error(
        'UNPACKING TRABLES_LIST unexpected error',
        error: error,
        stackTrace: stackTrace,
      );
      throw ApiParsingException(error.toString());
    }
  }

  void updateCount(int index, String value) {
    final int parsed = int.tryParse(value.trim()) ?? items[index].count;
    _replace(index, items[index].copyWith(count: parsed <= 0 ? 1 : parsed));
  }

  void updateComments(int index, String value) {
    _replace(index, items[index].copyWith(trableComments: value));
  }

  void updateTypeDocuments(int index, int typeDocuments) {
    final UnpackingOrderItemState current = items[index];
    _replace(
      index,
      current.copyWith(
        typeDocuments: typeDocuments,
        photoDocumentsExecute:
            typeDocuments == 4 ? false : current.photoDocumentsExecute,
        photoDocumentsFileName:
            typeDocuments == 4 ? '' : current.photoDocumentsFileName,
      ),
    );
  }

  void updateTrable(int index, Trable trable) {
    _replace(
      index,
      items[index].copyWith(
        trableIdRef: trable.idRef,
        trableName: trable.name,
      ),
    );
  }

  Future<String?> captureOrderPhoto(int index) async {
    final UnpackingOrderItemState current = items[index];
    final String? fileName = await _runBusy(
      () => _mediaService.captureAndSavePhoto(
        idRef: current.orderItem.idRef,
        typeIdRef: LegacyPhotoType.photoOpenOrder,
      ),
    );
    if (fileName != null) {
      _replace(
        index,
        current.copyWith(
          photoFileName: fileName,
          photoExecute: true,
        ),
      );
    }
    return fileName;
  }

  Future<String?> captureDocumentPhoto(int index) async {
    final UnpackingOrderItemState current = items[index];
    final String? fileName = await _runBusy(
      () => _mediaService.captureAndSavePhoto(
        idRef: current.orderItem.idRef,
        typeIdRef: LegacyPhotoType.photoDocument,
      ),
    );
    if (fileName != null) {
      _replace(
        index,
        current.copyWith(
          photoDocumentsFileName: fileName,
          photoDocumentsExecute: true,
        ),
      );
    }
    return fileName;
  }

  String? validate(int index) {
    final UnpackingOrderItemState item = items[index];
    if (!item.photoExecute) {
      return 'Немає фото товару !';
    }
    if (item.typeDocuments <= 0) {
      return 'Оберіть тип  документів (Чек або Умова або Фактура) ! ';
    }
    if (!item.photoDocumentsExecute && item.typeDocuments != 4) {
      return 'Немає фото документів ! ';
    }
    return null;
  }

  Future<UnpackingSubmitOutcome> submit(
    int index, {
    required String orderBuyIdRef,
  }) async {
    final LegacyRpcResult result = await _runBusy(
      () => _repository.submitUnpacking(
        orderBuyIdRef: orderBuyIdRef,
        item: items[index],
      ),
    );

    if (result.isSuccess) {
      _replace(index, items[index].copyWith(disabled: true));
      final LegacyPrintResult printResult =
          await _printService.printParcelBarcode(result.idRef);
      return UnpackingSubmitOutcome(result: result, printResult: printResult);
    }

    return UnpackingSubmitOutcome(
      result: result,
      printResult: const LegacyPrintResult(
        status: LegacyPrintStatus.completed,
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

  void _replace(int index, UnpackingOrderItemState item) {
    final List<UnpackingOrderItemState> next =
        List<UnpackingOrderItemState>.from(items);
    next[index] = item;
    items = next;
    notifyListeners();
  }
}

class UnpackingSubmitOutcome {
  const UnpackingSubmitOutcome({
    required this.result,
    required this.printResult,
  });

  final LegacyRpcResult result;
  final LegacyPrintResult printResult;
}
