import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/features/auth/domain/auth_user.dart';
import 'package:mobile_app_flutter/shared/widgets/app_section_card.dart';

class WorkMenuPage extends StatelessWidget {
  const WorkMenuPage({super.key, required this.user});

  final AuthUser user;

  void _showPlaceholder(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature буде реалізовано наступними кроками.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Work')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            user.displayName.isEmpty ? 'Розпочати роботу' : 'Розпочати: ${user.displayName.toUpperCase()}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          AppSectionCard(
            title: 'Receive order',
            subtitle: 'ORDER_BUY_SEARCH / RESIVE_ORDER_BUY',
            icon: Icons.inventory_2_outlined,
            onTap: () => _showPlaceholder(context, 'Receive order'),
          ),
          AppSectionCard(
            title: 'Unpacking',
            subtitle: 'ORDER_BUY_SEARCH_UNPACKING / UNPACKING_ORDER_BUY',
            icon: Icons.unarchive_outlined,
            onTap: () => _showPlaceholder(context, 'Unpacking'),
          ),
          AppSectionCard(
            title: 'Reprint',
            subtitle: 'Print and label re-issue flow',
            icon: Icons.print_outlined,
            onTap: () => _showPlaceholder(context, 'Reprint'),
          ),
          AppSectionCard(
            title: 'Order details',
            subtitle: 'Read-only order information flow',
            icon: Icons.info_outline,
            onTap: () => _showPlaceholder(context, 'Order details'),
          ),
          AppSectionCard(
            title: 'Manifest',
            subtitle: 'LIST_OPEN_MANIFEST / MANIFEST_ADD_DELETE',
            icon: Icons.qr_code_scanner_outlined,
            onTap: () => _showPlaceholder(context, 'Manifest'),
          ),
        ],
      ),
    );
  }
}
