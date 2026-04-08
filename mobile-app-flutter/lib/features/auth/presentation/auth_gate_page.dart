import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/app/app_services.dart';
import 'package:mobile_app_flutter/features/auth/presentation/auth_controller.dart';
import 'package:mobile_app_flutter/features/scanner_capture/presentation/scanner_capture_page.dart';
import 'package:mobile_app_flutter/features/settings/presentation/settings_page.dart';
import 'package:mobile_app_flutter/features/work_menu/presentation/work_menu_page.dart';

class AuthGatePage extends StatefulWidget {
  const AuthGatePage({super.key, required this.services});

  final AppServices services;

  @override
  State<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends State<AuthGatePage> {
  late final AuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AuthController(services: widget.services);
    _controller.bootstrap();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsPage(
          settingsStore: widget.services.settingsStore,
          authController: _controller,
        ),
      ),
    );
  }

  Future<void> _startWork() async {
    final user = _controller.currentUser;
    if (user == null) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WorkMenuPage(
          user: user,
          services: widget.services,
        ),
      ),
    );
  }

  Future<void> _startRegistrationScan() async {
    final String? scannedCode = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => const ScannerCapturePage(),
      ),
    );

    if (scannedCode == null || scannedCode.isEmpty) {
      return;
    }

    await _controller.registerEmployee(scannedCode);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(''),
            actions: <Widget>[
              IconButton(
                onPressed: _openSettings,
                icon: const Icon(Icons.edit_square),
              ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildBody(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    switch (_controller.status) {
      case AuthStatus.loading:
        return _StartScreen(
          buttonLabel: 'Зачекайте...',
          appVersionLabel: widget.services.appVersionLabel,
          helperText:
              'Для початку використання програми\nбудь ласка, відскануйте qr код з особистого кабінету',
          onPrimaryPressed: null,
          onDemoMode: null,
          errorMessage: _controller.backendVersion == null
              ? null
              : 'Backend version: ${_controller.backendVersion}',
          showProgress: true,
        );
      case AuthStatus.registrationRequired:
        return _StartScreen(
          buttonLabel: 'Register new user',
          appVersionLabel: widget.services.appVersionLabel,
          helperText:
              'Для початку використання програми\nбудь ласка, відскануйте qr код з особистого кабінету',
          onPrimaryPressed: _startRegistrationScan,
          onDemoMode:
              _controller.canUseDemoMode ? _controller.useDemoMode : null,
          errorMessage: _controller.errorMessage,
        );
      case AuthStatus.registering:
        return _StartScreen(
          buttonLabel: 'Registering...',
          appVersionLabel: widget.services.appVersionLabel,
          helperText:
              'Для початку використання програми\nбудь ласка, відскануйте qr код з особистого кабінету',
          onPrimaryPressed: null,
          onDemoMode: null,
          errorMessage: _controller.errorMessage,
          showProgress: true,
        );
      case AuthStatus.readyToStart:
      case AuthStatus.startingWork:
        final user = _controller.currentUser;
        return _StartScreen(
          buttonLabel: user == null
              ? 'Розпочати'
              : 'Розпочати: ${user.displayName.toUpperCase()}',
          appVersionLabel: widget.services.appVersionLabel,
          helperText:
              'Для початку використання програми\nбудь ласка, відскануйте qr код з особистого кабінету',
          onPrimaryPressed: _startWork,
          onDemoMode:
              _controller.canUseDemoMode ? _controller.useDemoMode : null,
          errorMessage: _controller.backendVersion == null
              ? null
              : 'Backend version: ${_controller.backendVersion}',
        );
      case AuthStatus.error:
        return _StartScreen(
          buttonLabel: 'Retry',
          appVersionLabel: widget.services.appVersionLabel,
          helperText:
              'Для початку використання програми\nбудь ласка, відскануйте qr код з особистого кабінету',
          onPrimaryPressed: _controller.bootstrap,
          onDemoMode:
              _controller.canUseDemoMode ? _controller.useDemoMode : null,
          errorMessage: _controller.errorMessage ?? 'Unknown error',
        );
    }
  }
}

class _StartScreen extends StatelessWidget {
  const _StartScreen({
    required this.buttonLabel,
    required this.appVersionLabel,
    required this.helperText,
    required this.onPrimaryPressed,
    required this.onDemoMode,
    this.errorMessage,
    this.showProgress = false,
  });

  final String buttonLabel;
  final String appVersionLabel;
  final String helperText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onDemoMode;
  final String? errorMessage;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 24),
        const Center(
          child: CircleAvatar(
            radius: 76,
            backgroundColor: Color(0xFFF3F3F3),
            child: Icon(Icons.lock_person_outlined, size: 88),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: onPrimaryPressed,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: const RoundedRectangleBorder(),
          ),
          child: Text(
            buttonLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        ),
        if (showProgress) ...<Widget>[
          const SizedBox(height: 12),
          const Center(child: CircularProgressIndicator()),
        ],
        if (errorMessage != null && errorMessage!.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const Spacer(),
        Text(
          helperText,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          appVersionLabel,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (onDemoMode != null) ...<Widget>[
          const SizedBox(height: 8),
          TextButton(
            onPressed: onDemoMode,
            child: const Text('Demo'),
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }
}
