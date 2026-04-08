import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/features/order_search/domain/order_item.dart';

class OrderItemListPage extends StatelessWidget {
  const OrderItemListPage({
    super.key,
    required this.items,
  });

  final List<OrderItem> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Перелік товарів')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (BuildContext context, int index) {
          final OrderItem item = items[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (item.linkPhoto.isNotEmpty)
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Image.network(
                        item.linkPhoto,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    ),
                  if (item.linkPhoto.isNotEmpty) const SizedBox(height: 12),
                  Text(
                    item.number.isEmpty ? item.orderNumber : item.number,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(item.orderDate),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  if (item.customRoute.isNotEmpty) Text(item.customRoute),
                  if (item.manager.isNotEmpty)
                    Text('Менеджер: ${item.manager}'),
                  if (item.deliveryType.isNotEmpty)
                    Text('Доставка: ${item.deliveryType}'),
                  const SizedBox(height: 8),
                  Text('Кількість: ${item.count}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
