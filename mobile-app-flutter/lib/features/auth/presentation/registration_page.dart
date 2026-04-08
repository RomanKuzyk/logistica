import 'package:flutter/material.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({
    super.key,
    required this.onRegister,
    required this.busy,
    this.errorMessage,
    this.deviceId,
  });

  final Future<void> Function(String employeeCode) onRegister;
  final bool busy;
  final String? errorMessage;
  final String? deviceId;

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  late final TextEditingController _employeeCodeController;

  @override
  void initState() {
    super.initState();
    _employeeCodeController = TextEditingController();
  }

  @override
  void dispose() {
    _employeeCodeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String employeeCode = _employeeCodeController.text.trim();
    if (employeeCode.isEmpty) {
      return;
    }
    await widget.onRegister(employeeCode);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Register new user',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Перший етап порту підтримує ручне введення employee code. QR scanner буде підключений окремим кроком.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            if (widget.deviceId != null) ...<Widget>[
              SelectableText('Device ID: ${widget.deviceId!}'),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _employeeCodeController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Employee QR / code',
                hintText: '0x...',
              ),
              enabled: !widget.busy,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: widget.busy ? null : _submit,
              child: Text(widget.busy ? 'Registering...' : 'Register'),
            ),
            if (widget.errorMessage != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                widget.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
