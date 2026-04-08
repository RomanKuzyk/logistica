import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/features/order_search/domain/trable.dart';

class TrablePickerPage extends StatelessWidget {
  const TrablePickerPage({
    super.key,
    required this.items,
  });

  final List<Trable> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Оберіть проблему')),
      body: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (BuildContext context, int index) {
          final Trable trable = items[index];
          return ListTile(
            title: Text(trable.name),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).pop<Trable>(trable),
          );
        },
      ),
    );
  }
}
