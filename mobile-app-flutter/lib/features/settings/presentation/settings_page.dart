import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/core/storage/local_settings_store.dart';
import 'package:mobile_app_flutter/features/auth/presentation/auth_controller.dart';

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

  Future<void> _save() async {
    await widget.settingsStore
        .setScannerFinishCharacters(_scannerController.text.trim());
    await widget.settingsStore
        .setBackgroundSyncTimer(_backgroundSyncController.text.trim());
    await widget.settingsStore.setSaveBackgroundFile(_saveBackgroundFile);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Налаштування збережено')),
    );
  }

  Future<void> _persistSilently() async {
    await widget.settingsStore
        .setScannerFinishCharacters(_scannerController.text.trim());
    await widget.settingsStore
        .setBackgroundSyncTimer(_backgroundSyncController.text.trim());
    await widget.settingsStore.setSaveBackgroundFile(_saveBackgroundFile);
  }

  Future<void> _syncNow() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Розпочата сінхронізація ..')),
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
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const SizedBox(height: 16),
          Text(
            'Налаштування',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
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
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _scannerController,
            decoration: const InputDecoration(
              labelText: 'Після сканування додати код (HEX String)',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _persistSilently(),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            value: _saveBackgroundFile,
            onChanged: (bool value) async {
              setState(() {
                _saveBackgroundFile = value;
              });
              await _persistSilently();
            },
            title: const Text('Зберігати фото у фоновому режимі'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _backgroundSyncController,
            decoration: const InputDecoration(
              labelText: 'Час синхронізації',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (_) => _persistSilently(),
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: _busy ? null : _save,
            child: const Text('Зберегти налаштування'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _busy ? null : _syncNow,
            child: Text(_busy ? 'Зачекайте...' : 'Сінхронізувати вже'),
          ),
        ],
      ),
    );
  }
}
