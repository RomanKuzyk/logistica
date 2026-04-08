import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/app/app_services.dart';
import 'package:mobile_app_flutter/core/api/api_exceptions.dart';
import 'package:mobile_app_flutter/features/order_search/data/receive_order_repository.dart';
import 'package:mobile_app_flutter/features/order_search/domain/order_buy_search_item.dart';
import 'package:mobile_app_flutter/features/order_search/domain/order_item.dart';
import 'package:mobile_app_flutter/features/order_search/domain/trable.dart';
import 'package:mobile_app_flutter/features/order_search/presentation/order_item_list_page.dart';
import 'package:mobile_app_flutter/features/order_search/presentation/order_search_detail_controller.dart';
import 'package:mobile_app_flutter/features/order_search/presentation/trable_picker_page.dart';

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

      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Completed'),
          content: const Text('Замовлення повертаємо. Дякую !'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
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

      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Completed'),
          content: const Text('Заявка опрацьована. Дякую !'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
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

  void _showPhotoPlaceholder(String title) {
    _showMessage(
      '$title буде підключено окремим кроком разом із legacy S3 upload flow.',
      title: title,
    );
  }

  void _showMessage(String message, {String title = 'Errors'}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title: $message')),
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
          appBar: AppBar(title: const Text('Картка замовлення')),
          body: AbsorbPointer(
            absorbing: _controller.isBusy,
            child: Stack(
              children: <Widget>[
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: <Widget>[
                    Text(
                      widget.order.displayNumber,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
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
                      style: Theme.of(context).textTheme.titleMedium,
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
                      color: Colors.blue,
                      onPressed: _openOrderItems,
                    ),
                    _ActionButton(
                      label: 'Фото перевізного',
                      color: Colors.cyan.shade600,
                      onPressed: () =>
                          _showPhotoPlaceholder('Фото перевізного'),
                    ),
                    _ActionButton(
                      label: 'Друк стікера',
                      color: Colors.cyan.shade600,
                      onPressed: () => _showPhotoPlaceholder('Друк стікера'),
                    ),
                    _ActionButton(
                      label: 'Фото прийома',
                      color: Colors.cyan.shade600,
                      onPressed: () => _showPhotoPlaceholder('Фото прийома'),
                    ),
                    _ActionButton(
                      label: trableLabel,
                      color: _controller.selectedTrable.isSelected
                          ? Colors.red
                          : Colors.grey.shade600,
                      onPressed: _openTrables,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Коментар',
                      ),
                      onChanged: _controller.setComments,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        const Text('Без НП :'),
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
                              border: OutlineInputBorder(),
                              hintText: '0.00',
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
                              backgroundColor: Colors.red.shade700,
                            ),
                            child: const Text('ПОВЕРНУТИ'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: _acceptOrder,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.green,
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
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}
