import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/features/order_search/domain/order_buy_search_item.dart';
import 'package:mobile_app_flutter/shared/widgets/legacy_alert_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailsPreviewPage extends StatelessWidget {
  const OrderDetailsPreviewPage({
    super.key,
    required this.order,
  });

  final OrderBuySearchItem order;

  void _showPlaceholder(BuildContext context, String label) {
    showLegacyAlertDialog(
      context,
      title: 'Information',
      message: '$label буде підключено наступним кроком.',
    );
  }

  Future<void> _openSellerSite(BuildContext context) async {
    final Uri? uri = Uri.tryParse(order.link);
    if (uri == null) {
      _showPlaceholder(context, 'Некоректне посилання продавця');
      return;
    }

    final bool launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      _showPlaceholder(context, 'Не вдалося відкрити сайт продавця');
    }
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: <Widget>[
          Text(
            order.displayNumber,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            order.nameOrders.isEmpty ? '—' : order.nameOrders,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 180,
            child: order.link.isEmpty
                ? _buildImagePlaceholder()
                : Image.network(
                    order.link,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                  ),
          ),
          TextButton(
            onPressed:
                order.link.isEmpty ? null : () => _openSellerSite(context),
            child: const Text(
              'Перехід на сайт продавця',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      alignment: Alignment.center,
      child: const Text(
        'Sorry\nIMAGE\nNOT AVAILABLE',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 26,
          height: 1,
          color: Color(0xFFCFCFCF),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
