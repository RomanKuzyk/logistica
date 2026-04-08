import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/app/app_services.dart';
import 'package:mobile_app_flutter/features/order_search/domain/order_buy_search_item.dart';
import 'package:mobile_app_flutter/features/order_search/presentation/order_search_detail_page.dart';

class OrderResultListPage extends StatelessWidget {
  const OrderResultListPage({
    super.key,
    required this.results,
    required this.services,
  });

  final List<OrderBuySearchItem> results;
  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Знайдені замовлення')),
      body: ListView.separated(
        itemCount: results.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (BuildContext context, int index) {
          final OrderBuySearchItem item = results[index];
          return InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => OrderSearchDetailPage(
                    order: item,
                    services: services,
                  ),
                ),
              );
            },
            child: Container(
              color: Colors.grey.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          item.displayNumber.isEmpty
                              ? 'Без номера'
                              : item.displayNumber,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(item.count.toString()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    [item.street, item.city]
                        .where((String value) => value.isNotEmpty)
                        .join(' '),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.customerName,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.waybill,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.white,
                    child: Text(
                      item.nameOrders,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ДО ОПЛАТИ PL : ${item.summaCod.toStringAsFixed(2)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'ОПЛАЧЕНО : ${item.summaPayPl.toStringAsFixed(2)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
