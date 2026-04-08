import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/app/app_services.dart';
import 'package:mobile_app_flutter/features/auth/domain/auth_user.dart';
import 'package:mobile_app_flutter/features/order_search/domain/work_mode.dart';
import 'package:mobile_app_flutter/features/order_search/presentation/order_search_page.dart';

class WorkMenuPage extends StatelessWidget {
  const WorkMenuPage({
    super.key,
    required this.user,
    required this.services,
  });

  final AuthUser user;
  final AppServices services;

  void _showPlaceholder(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature буде реалізовано наступними кроками.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          user.displayName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
        children: <Widget>[
          Container(
            height: 46,
            alignment: Alignment.center,
            color: const Color(0xFFF0F0F0),
            child: const Text(
              'Оберіть дію',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _LegacyMenuButton(
            title: 'Прийняти замовлення',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => OrderSearchPage(
                    services: services,
                    mode: WorkMode.receive,
                  ),
                ),
              );
            },
          ),
          _LegacyMenuButton(
            title: 'Розпакувати',
            onTap: () => _showPlaceholder(context, 'Unpacking'),
          ),
          _LegacyMenuButton(
            title: 'Передрукувати',
            onTap: () => _showPlaceholder(context, 'Reprint'),
          ),
          _LegacyMenuButton(
            title: 'Формування маніфесту',
            onTap: () => _showPlaceholder(context, 'Manifest'),
          ),
          _LegacyMenuButton(
            title: 'Деталі замовлення (PL)',
            onTap: () => _showPlaceholder(context, 'Order details'),
          ),
        ],
      ),
    );
  }
}

class _LegacyMenuButton extends StatelessWidget {
  const _LegacyMenuButton({
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF1877F2),
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
