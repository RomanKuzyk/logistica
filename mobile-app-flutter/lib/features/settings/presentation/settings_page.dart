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

  @override
  void initState() {
    super.initState();
    _scannerController = TextEditingController(text: widget.settingsStore.scannerFinishCharacters);
    _backgroundSyncController = TextEditingController(text: widget.settingsStore.backgroundSyncTimer);
    _saveBackgroundFile = widget.settingsStore.saveBackgroundFile;
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _backgroundSyncController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await widget.settingsStore.setScannerFinishCharacters(_scannerController.text.trim());
    await widget.settingsStore.setBackgroundSyncTimer(_backgroundSyncController.text.trim());
    await widget.settingsStore.setSaveBackgroundFile(_saveBackgroundFile);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Налаштування збережено')),
    );
  }

  Future<void> _disconnect() async {
    setState(() {
      _busy = true;
    });

    await widget.authController.disconnect();

    if (!mounted) {
      return;
    }

    setState(() {
      _busy = false;
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
          TextField(
            controller: _scannerController,
            decoration: const InputDecoration(
              labelText: 'Scanner finish characters',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _backgroundSyncController,
            decoration: const InputDecoration(
              labelText: 'Background sync timer',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            value: _saveBackgroundFile,
            onChanged: (bool value) {
              setState(() {
                _saveBackgroundFile = value;
              });
            },
            title: const Text('Save photo in background'),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _save, child: const Text('Save settings')),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _busy ? null : _disconnect,
            child: Text(_busy ? 'Disconnecting...' : 'Disconnect device'),
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Manual sync буде реалізовано окремим кроком.')),
              );
            },
            child: const Text('Sync now'),
          ),
        ],
      ),
    );
  }
}
