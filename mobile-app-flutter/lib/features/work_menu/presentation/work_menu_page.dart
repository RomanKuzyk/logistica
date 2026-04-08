import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/app/app_services.dart';
import 'package:mobile_app_flutter/features/auth/domain/auth_user.dart';
import 'package:mobile_app_flutter/features/manifest/presentation/manifest_list_page.dart';
import 'package:mobile_app_flutter/features/order_search/domain/work_mode.dart';
import 'package:mobile_app_flutter/features/order_search/presentation/order_search_page.dart';

class WorkMenuPage extends StatefulWidget {
  const WorkMenuPage({
    super.key,
    required this.user,
    required this.services,
  });

  final AuthUser user;
  final AppServices services;

  @override
  State<WorkMenuPage> createState() => _WorkMenuPageState();
}

class _WorkMenuPageState extends State<WorkMenuPage> {
  WorkMode? _selectedMode;

  Future<void> _openMode(WorkMode mode, Widget page) async {
    setState(() {
      _selectedMode = mode;
    });
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
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
          widget.user.displayName,
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
            enabled: _selectedMode != WorkMode.receive,
            onTap: () => _openMode(
              WorkMode.receive,
              OrderSearchPage(
                services: widget.services,
                mode: WorkMode.receive,
              ),
            ),
          ),
          _LegacyMenuButton(
            title: 'Розпакувати',
            enabled: _selectedMode != WorkMode.unpack,
            onTap: () => _openMode(
              WorkMode.unpack,
              OrderSearchPage(
                services: widget.services,
                mode: WorkMode.unpack,
              ),
            ),
          ),
          _LegacyMenuButton(
            title: 'Передрукувати',
            enabled: _selectedMode != WorkMode.reprint,
            onTap: () => _openMode(
              WorkMode.reprint,
              OrderSearchPage(
                services: widget.services,
                mode: WorkMode.reprint,
              ),
            ),
          ),
          _LegacyMenuButton(
            title: 'Формування маніфесту',
            enabled: _selectedMode != WorkMode.manifest,
            onTap: () => _openMode(
              WorkMode.manifest,
              const ManifestListPage(),
            ),
          ),
          _LegacyMenuButton(
            title: 'Деталі замовлення (PL)',
            enabled: _selectedMode != WorkMode.details,
            onTap: () => _openMode(
              WorkMode.details,
              OrderSearchPage(
                services: widget.services,
                mode: WorkMode.details,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegacyMenuButton extends StatelessWidget {
  const _LegacyMenuButton({
    required this.title,
    required this.enabled,
    required this.onTap,
  });

  final String title;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: FilledButton(
          onPressed: enabled ? onTap : null,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF1877F2),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFF1877F2),
            disabledForegroundColor: Colors.white38,
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
