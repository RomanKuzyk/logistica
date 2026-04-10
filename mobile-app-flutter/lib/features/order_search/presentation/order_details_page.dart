import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/app/app_services.dart';
import 'package:mobile_app_flutter/core/api/api_exceptions.dart';
import 'package:mobile_app_flutter/features/order_search/data/receive_order_repository.dart';
import 'package:mobile_app_flutter/features/order_search/domain/order_buy_search_item.dart';
import 'package:mobile_app_flutter/features/order_search/domain/order_item.dart';
import 'package:mobile_app_flutter/shared/widgets/legacy_alert_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailsPage extends StatefulWidget {
  const OrderDetailsPage({
    super.key,
    required this.order,
    required this.services,
  });

  final OrderBuySearchItem order;
  final AppServices services;

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late final ReceiveOrderRepository _repository;
  bool _loading = true;
  List<OrderItem> _items = const <OrderItem>[];

  @override
  void initState() {
    super.initState();
    _repository = ReceiveOrderRepository(apiClient: widget.services.apiClient);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final List<OrderItem> items =
          await _repository.fetchOrderItems(widget.order.idRef);
      if (!mounted) {
        return;
      }
      setState(() {
        _items = items;
        _loading = false;
      });
      if (items.isEmpty) {
        await showLegacyAlertDialog(
          context,
          title: 'Errors',
          message: 'Ми нічого не знайшли по вказаним умовам пошуку! ',
        );
      }
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _loading = false);
      await showLegacyAlertDialog(
        context,
        title: 'Errors',
        message: 'Error : ${error.message}',
      );
    }
  }

  Future<void> _openSellerSite() async {
    final Uri? uri = Uri.tryParse(widget.order.link);
    if (uri == null) {
      return;
    }

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(''),
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                'Обрати',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: <Widget>[
                Container(
                  color: const Color(0xFFEDEDF1),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        widget.order.number.isEmpty
                            ? widget.order.displayNumber
                            : widget.order.number,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(widget.order.orderDate),
                      const SizedBox(height: 4),
                      Text(widget.order.waybill),
                      const SizedBox(height: 8),
                      Text(
                        widget.order.nameOrders.replaceAll('[¶]', '\n'),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.order.firstName} ${widget.order.lastName}\n${widget.order.phoneNumber}'
                            .trim(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.order.street} ${widget.order.zipCode} ${widget.order.city}\n${widget.order.company}'
                            .replaceAll('¶', '')
                            .trim(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ' ДО ОПЛАТИ PL : ${widget.order.summaCod.toStringAsFixed(2)} ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: widget.order.summaCod > 0
                              ? Colors.red
                              : Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'ОПЛАЧЕНО : ${widget.order.summaPayPl.toStringAsFixed(2)} ',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (widget.order.link.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _openSellerSite,
                          child: const Text('Перехід на сайт продавця'),
                        ),
                      ],
                    ],
                  ),
                ),
                ..._items.map(_buildItemCard),
              ],
            ),
    );
  }

  Widget _buildItemCard(OrderItem item) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDBDBDB)),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (item.linkPhoto.isNotEmpty)
            SizedBox(
              height: 220,
              child: Image.network(
                item.linkPhoto,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
              ),
            )
          else
            SizedBox(height: 220, child: _buildImagePlaceholder()),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (item.customRoute.isNotEmpty)
                  Text(
                    item.customRoute,
                    style: const TextStyle(fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                if (item.manager.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    item.manager,
                    style: const TextStyle(fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  item.number,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(item.orderDate),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  '${item.count}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFFF7F7F7),
    );
  }
}
