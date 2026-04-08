import 'package:mobile_app_flutter/features/order_search/domain/order_item.dart';

class UnpackingOrderItemState {
  const UnpackingOrderItemState({
    required this.orderItem,
    required this.count,
    required this.trableIdRef,
    required this.trableName,
    required this.trableComments,
    required this.photoFileName,
    required this.photoDocumentsFileName,
    required this.photoExecute,
    required this.photoDocumentsExecute,
    required this.typeDocuments,
    required this.disabled,
  });

  factory UnpackingOrderItemState.fromOrderItem(OrderItem item) {
    return UnpackingOrderItemState(
      orderItem: item,
      count: item.count <= 0 ? 1 : item.count,
      trableIdRef: '',
      trableName: '',
      trableComments: '',
      photoFileName: '',
      photoDocumentsFileName: '',
      photoExecute: false,
      photoDocumentsExecute: false,
      typeDocuments: -1,
      disabled: false,
    );
  }

  final OrderItem orderItem;
  final int count;
  final String trableIdRef;
  final String trableName;
  final String trableComments;
  final String photoFileName;
  final String photoDocumentsFileName;
  final bool photoExecute;
  final bool photoDocumentsExecute;
  final int typeDocuments;
  final bool disabled;

  bool get hasTrable => trableIdRef.isNotEmpty;
  bool get requiresDocumentPhoto => typeDocuments > 0 && typeDocuments != 4;
  bool get documentPhotoButtonEnabled =>
      typeDocuments > 0 && typeDocuments != 4;
  String get trableButtonLabel =>
      hasTrable ? 'Проблема $trableName' : 'Оберіть проблему';

  UnpackingOrderItemState copyWith({
    OrderItem? orderItem,
    int? count,
    String? trableIdRef,
    String? trableName,
    String? trableComments,
    String? photoFileName,
    String? photoDocumentsFileName,
    bool? photoExecute,
    bool? photoDocumentsExecute,
    int? typeDocuments,
    bool? disabled,
  }) {
    return UnpackingOrderItemState(
      orderItem: orderItem ?? this.orderItem,
      count: count ?? this.count,
      trableIdRef: trableIdRef ?? this.trableIdRef,
      trableName: trableName ?? this.trableName,
      trableComments: trableComments ?? this.trableComments,
      photoFileName: photoFileName ?? this.photoFileName,
      photoDocumentsFileName:
          photoDocumentsFileName ?? this.photoDocumentsFileName,
      photoExecute: photoExecute ?? this.photoExecute,
      photoDocumentsExecute:
          photoDocumentsExecute ?? this.photoDocumentsExecute,
      typeDocuments: typeDocuments ?? this.typeDocuments,
      disabled: disabled ?? this.disabled,
    );
  }
}
