import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/app/app_services.dart';
import 'package:mobile_app_flutter/core/api/api_exceptions.dart';
import 'package:mobile_app_flutter/core/media/media_exceptions.dart';
import 'package:mobile_app_flutter/features/order_search/data/receive_order_repository.dart';
import 'package:mobile_app_flutter/features/order_search/domain/order_buy_search_item.dart';
import 'package:mobile_app_flutter/features/order_search/domain/order_item.dart';
import 'package:mobile_app_flutter/features/order_search/domain/trable.dart';
import 'package:mobile_app_flutter/features/order_search/presentation/order_item_list_page.dart';
import 'package:mobile_app_flutter/features/order_search/presentation/order_search_detail_controller.dart';
import 'package:mobile_app_flutter/features/order_search/presentation/trable_picker_page.dart';
import 'package:mobile_app_flutter/shared/widgets/legacy_alert_dialog.dart';

class OrderSearchDetailPage extends StatefulWidget {
  const OrderSearchDetailPage({
    super.key,
    required this.order,
    required this.services,
  });

  final OrderBuySearchItem order;
  final AppServices services;

  @override
  State<OrderSearchDetailPage> createState() => _OrderSearchDetailPageState();
}

class _OrderSearchDetailPageState extends State<OrderSearchDetailPage> {
  late final TextEditingController _commentController;
  late final TextEditingController _sumController;
  late final OrderSearchDetailController _controller;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    _sumController = TextEditingController(text: '0.00');
    _controller = OrderSearchDetailController(
      repository: ReceiveOrderRepository(apiClient: widget.services.apiClient),
      logger: widget.services.logger,
      mediaService: widget.services.mediaService,
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _sumController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openOrderItems() async {
    try {
      final List<OrderItem> items =
          await _controller.loadOrderItems(widget.order.idRef);
      if (!mounted) {
        return;
      }
      if (items.isEmpty) {
        _showMessage('Ми нічого не знайшли по вказаним умовам пошуку! ');
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => OrderItemListPage(items: items),
        ),
      );
    } on ApiException catch (error) {
      _showMessage('Error : ${error.message}');
    }
  }

  Future<void> _openTrables() async {
    try {
      final List<Trable> items = await _controller.loadTrables();
      if (!mounted) {
        return;
      }
      final Trable? selected = await Navigator.of(context).push<Trable>(
        MaterialPageRoute<Trable>(
          builder: (_) => TrablePickerPage(items: items),
        ),
      );
      if (selected != null) {
        _controller.setSelectedTrable(selected);
      }
    } on ApiException catch (error) {
      _showMessage('Error : ${error.message}');
    }
  }

  Future<void> _rejectOrder() async {
    try {
      final result = await _controller.rejectOrder(widget.order.idRef);
      if (!mounted) {
        return;
      }
      if (!result.isSuccess) {
        _showMessage(result.errorDetail, title: 'REJECT_ORDER_BUY');
        return;
      }

      await showLegacyAlertDialog(
        context,
        title: 'Completed',
        message: 'Замовлення повертаємо. Дякую !',
      );

      if (!mounted) {
        return;
      }
      Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
    } on ApiException catch (error) {
      _showMessage(error.message, title: 'ERROR REJECT_ORDER_BUY');
    }
  }

  Future<void> _acceptOrder() async {
    _controller.setComments(_commentController.text);
    _controller.setSumma(_sumController.text);

    final String? validationError = _controller.validateReceive();
    if (validationError != null) {
      final String title = validationError.contains('фото')
          ? 'PHOTO'
          : validationError.contains('сума')
              ? 'SUMMA'
              : 'INCOMING_PARSEL_ORDER_BUY';
      _showMessage(validationError, title: title);
      return;
    }

    try {
      final result = await _controller.receiveOrder(widget.order.idRef);
      if (!mounted) {
        return;
      }
      if (!result.isSuccess) {
        _showMessage(result.errorDetail, title: 'INCOMING_PARSEL_ORDER_BUY');
        return;
      }

      await showLegacyAlertDialog(
        context,
        title: 'Completed',
        message: 'Заявка опрацьована. Дякую !',
      );

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } on ApiException catch (error) {
      _showMessage(error.message, title: 'ERROR REGISTERED');
    }
  }

  Future<void> _captureFacturePhoto() async {
    try {
      final String? fileName =
          await _controller.captureFacturePhoto(widget.order.idRef);
      if (fileName != null) {
        _controller.setFacturePhotoFileName(fileName);
      }
    } on MediaException catch (error) {
      if (error is MediaCancelledException) {
        return;
      }
      _showMessage(error.message, title: 'PHOTO');
    }
  }

  Future<void> _captureReceivePhoto() async {
    try {
      final String? fileName =
          await _controller.captureReceivePhoto(widget.order.idRef);
      if (fileName != null) {
        _controller.setReceivePhotoFileName(fileName);
      }
    } on MediaException catch (error) {
      if (error is MediaCancelledException) {
        return;
      }
      _showMessage(error.message, title: 'PHOTO');
    }
  }

  Future<void> _printLabel() async {
    _showMessage('Printing is not available yet.', title: 'Print');
  }

  void _showMessage(String message, {String title = 'Errors'}) {
    showLegacyAlertDialog(
      context,
      title: title,
      message: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) {
        final String trableLabel = _controller.selectedTrable.isSelected
            ? 'Проблема ${_controller.selectedTrable.name}'
            : 'Оберіть проблему';

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text(''),
          ),
          body: AbsorbPointer(
            absorbing: _controller.isBusy,
            child: Stack(
              children: <Widget>[
                ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: <Widget>[
                    Container(
                      height: 24,
                      color: const Color(0xFFF7F7F7),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.order.displayNumber,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      [
                        widget.order.street,
                        widget.order.zipCode,
                        widget.order.city
                      ].where((String value) => value.isNotEmpty).join(' '),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(widget.order.customerName,
                        textAlign: TextAlign.center),
                    if (widget.order.phoneNumber.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 4),
                      Text(widget.order.phoneNumber,
                          textAlign: TextAlign.center),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      widget.order.waybill,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ДО ОПЛАТИ PL : ${widget.order.summaCod.toStringAsFixed(2)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'СПЛАЧЕНО : ${widget.order.summaPayPl.toStringAsFixed(2)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ActionButton(
                      label: 'Перелік товарів',
                      color: const Color(0xFF1877F2),
                      onPressed: _openOrderItems,
                    ),
                    _ActionButton(
                      label: 'Фото перевізного',
                      color: const Color(0xFF38B6CC),
                      onPressed: _captureFacturePhoto,
                    ),
                    _ActionButton(
                      label: 'Друк стікера',
                      color: const Color(0xFF38B6CC),
                      onPressed: _printLabel,
                    ),
                    _ActionButton(
                      label: 'Фото прийома',
                      color: const Color(0xFF38B6CC),
                      onPressed: _captureReceivePhoto,
                    ),
                    _ActionButton(
                      label: trableLabel,
                      color: const Color(0xFFB08D5C),
                      onPressed: _openTrables,
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _commentController,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: Color(0xFF8E8E8E)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: Color(0xFF1877F2)),
                        ),
                        hintText: 'Кометар до проблеми',
                        hintStyle: TextStyle(color: Color(0xFFC8C8C8)),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onChanged: _controller.setComments,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        const Text(
                          'Без НП :',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 8),
                        Switch(
                          value: _controller.isSumDisabled,
                          onChanged: (bool value) {
                            _controller.setSumDisabled(value);
                            if (value) {
                              _sumController.text = '0.00';
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _sumController,
                            enabled: !_controller.isSumDisabled,
                            textAlign: TextAlign.right,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.zero,
                                borderSide:
                                    BorderSide(color: Color(0xFF8E8E8E)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.zero,
                                borderSide:
                                    BorderSide(color: Color(0xFF1877F2)),
                              ),
                              hintText: '0.00',
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                            onChanged: _controller.setSumma,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: FilledButton(
                            onPressed: _rejectOrder,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFD44242),
                              shape: const RoundedRectangleBorder(),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('ПОВЕРНУТИ'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: _acceptOrder,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF36C85A),
                              shape: const RoundedRectangleBorder(),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('ПРИЙНЯТИ'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (_controller.isBusy)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x33000000),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        child: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}
