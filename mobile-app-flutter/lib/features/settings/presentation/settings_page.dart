import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/core/storage/local_settings_store.dart';
import 'package:mobile_app_flutter/features/auth/presentation/auth_controller.dart';
import 'package:mobile_app_flutter/shared/widgets/legacy_alert_dialog.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.settingsStore,
    required this.authController,
  });

  final LocalSettingsStore settingsStore;
  final AuthController authController;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController _scannerController;
  late final TextEditingController _backgroundSyncController;
  late bool _saveBackgroundFile;
  bool _busy = false;
  bool _disconnectValue = false;

  @override
  void initState() {
    super.initState();
    _scannerController = TextEditingController(
        text: widget.settingsStore.scannerFinishCharacters);
    _backgroundSyncController =
        TextEditingController(text: widget.settingsStore.backgroundSyncTimer);
    _saveBackgroundFile = widget.settingsStore.saveBackgroundFile;
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _backgroundSyncController.dispose();
    super.dispose();
  }

  Future<void> _persistSilently() async {
    await widget.settingsStore
        .setScannerFinishCharacters(_scannerController.text.trim());
    await widget.settingsStore
        .setBackgroundSyncTimer(_backgroundSyncController.text.trim());
    await widget.settingsStore.setSaveBackgroundFile(_saveBackgroundFile);
  }

  Future<void> _syncNow() async {
    await showLegacyAlertDialog(
      context,
      title: 'Information',
      message: 'Розпочата сінхронізація ..',
    );
  }

  Future<void> _disconnect() async {
    setState(() {
      _busy = true;
      _disconnectValue = true;
    });

    await widget.authController.disconnect();

    if (!mounted) {
      return;
    }

    setState(() {
      _busy = false;
      _disconnectValue = false;
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
        children: <Widget>[
          Text(
            'Налаштування',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 36),
          SwitchListTile(
            value: _disconnectValue,
            onChanged: _busy
                ? null
                : (bool value) {
                    if (!value) {
                      return;
                    }
                    _disconnect();
                  },
            title: const Text('Відмінити реєстрацію'),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          const Text(
            'Після сканування додати код (HEX String)',
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _scannerController,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.zero),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: Color(0xFFE3E3E3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: Color(0xFF1877F2)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
            onChanged: (_) => _persistSilently(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Час сінхронізації',
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          SwitchListTile(
            value: _saveBackgroundFile,
            onChanged: (bool value) async {
              setState(() {
                _saveBackgroundFile = value;
              });
              await _persistSilently();
            },
            title: const Text('Зберігати фото у фоновому режимі'),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _backgroundSyncController,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.zero),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: Color(0xFFE3E3E3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: Color(0xFF1877F2)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
            keyboardType: TextInputType.number,
            onChanged: (_) => _persistSilently(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 46,
            child: FilledButton(
            onPressed: _busy ? null : _syncNow,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1877F2),
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              child: Text(_busy ? 'Зачекайте...' : 'Сінхронізувати вже'),
            ),
          ),
        ],
      ),
    );
  }
}
