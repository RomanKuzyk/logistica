import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/features/order_search/domain/order_buy_search_item.dart';

class ReprintActionPage extends StatelessWidget {
  const ReprintActionPage({
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              color: const Color(0xFFF0F0F0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: const Column(
                children: <Widget>[
                  Text(
                    'ПЕРЕДРУКУВАТИ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Відскануйте номер замовлення\nобслуговування',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF7A7A7A)),
              ),
              child: Text(
                order.displayNumber,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Print'),
                      content: const Text('User push cancel button...'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Done'),
                        ),
                      ],
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
                child: const Text('Друк стікера'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
