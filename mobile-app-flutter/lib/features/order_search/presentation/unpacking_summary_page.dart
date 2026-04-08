import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/features/order_search/domain/order_buy_search_item.dart';
import 'package:mobile_app_flutter/features/order_search/presentation/unpacking_item_page.dart';

class UnpackingSummaryPage extends StatelessWidget {
  const UnpackingSummaryPage({
    super.key,
    required this.order,
  });

  final OrderBuySearchItem order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(''),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: <Widget>[
          Container(
            height: 24,
            color: const Color(0xFFF7F7F7),
          ),
          const SizedBox(height: 12),
          Text(
            order.displayNumber,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          Text(
            [
              order.street,
              order.zipCode,
              order.city,
            ].where((String value) => value.isNotEmpty).join(' '),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
          if (order.customerName.isNotEmpty) ...<Widget>[
            const SizedBox(height: 2),
            Text(
              order.customerName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ],
          if (order.phoneNumber.isNotEmpty) ...<Widget>[
            const SizedBox(height: 22),
            Text(
              order.phoneNumber,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ],
          const SizedBox(height: 18),
          Text(
            '${order.summaCod.toStringAsFixed(2)} PL',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'СПЛАЧЕНО : ${order.summaPayPl.toStringAsFixed(2)}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2ED13E),
            ),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0xFFD0D0D0)),
          const SizedBox(height: 22),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => UnpackingItemPage(order: order),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1877F2),
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              child: const Text('Продовжити'),
            ),
          ),
        ],
      ),
    );
  }
}
