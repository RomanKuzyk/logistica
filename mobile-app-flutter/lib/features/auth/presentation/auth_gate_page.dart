import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/app/app_services.dart';
import 'package:mobile_app_flutter/features/auth/presentation/auth_controller.dart';
import 'package:mobile_app_flutter/features/scanner_capture/presentation/scanner_capture_page.dart';
import 'package:mobile_app_flutter/features/settings/presentation/settings_page.dart';
import 'package:mobile_app_flutter/features/work_menu/presentation/work_menu_page.dart';
import 'package:mobile_app_flutter/shared/widgets/legacy_alert_dialog.dart';

class AuthGatePage extends StatefulWidget {
  const AuthGatePage({super.key, required this.services});

  final AppServices services;

  @override
  State<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends State<AuthGatePage> {
  late final AuthController _controller;
  String? _lastPresentedErrorMessage;

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
          mediaService: widget.services.mediaService,
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
        _scheduleLegacyErrorDialogIfNeeded();
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text(''),
            actions: <Widget>[
              IconButton(
                onPressed: _openSettings,
                icon: const Icon(Icons.edit_outlined),
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

  void _scheduleLegacyErrorDialogIfNeeded() {
    final String? message = _controller.errorMessage;
    if (_controller.status != AuthStatus.error ||
        message == null ||
        message.isEmpty ||
        message == _lastPresentedErrorMessage) {
      return;
    }
    _lastPresentedErrorMessage = message;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      showLegacyAlertDialog(
        context,
        title: 'Atantion',
        message: message,
      );
    });
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
          showProgress: true,
        );
      case AuthStatus.registrationRequired:
        return _StartScreen(
          buttonLabel: 'Розпочати',
          appVersionLabel: widget.services.appVersionLabel,
          helperText:
              'Для початку використання програми\nбудь ласка, відскануйте qr код з особистого кабінету',
          onPrimaryPressed: _startRegistrationScan,
        );
      case AuthStatus.registering:
        return _StartScreen(
          buttonLabel: 'Зачекайте...',
          appVersionLabel: widget.services.appVersionLabel,
          helperText:
              'Для початку використання програми\nбудь ласка, відскануйте qr код з особистого кабінету',
          onPrimaryPressed: null,
          showProgress: true,
        );
      case AuthStatus.readyToStart:
      case AuthStatus.startingWork:
        final user = _controller.currentUser;
        return _StartScreen(
          buttonLabel:
              user == null ? 'Розпочати' : 'Розпочати: ${user.displayName}',
          appVersionLabel: widget.services.appVersionLabel,
          helperText:
              'Для початку використання програми\nбудь ласка, відскануйте qr код з особистого кабінету',
          onPrimaryPressed: _startWork,
        );
      case AuthStatus.error:
        return _StartScreen(
          buttonLabel: 'Розпочати',
          appVersionLabel: widget.services.appVersionLabel,
          helperText:
              'Для початку використання програми\nбудь ласка, відскануйте qr код з особистого кабінету',
          onPrimaryPressed: _controller.bootstrap,
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
    this.showProgress = false,
  });

  final String buttonLabel;
  final String appVersionLabel;
  final String helperText;
  final VoidCallback? onPrimaryPressed;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 20),
        Center(
          child: Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              border: Border.all(color: const Color(0xFFE6E6E6)),
            ),
            child: const Icon(
              Icons.lock_person_outlined,
              size: 86,
              color: Colors.black54,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF0F4786), width: 1.2),
          ),
          child: FilledButton(
            onPressed: onPrimaryPressed,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1877F2),
              disabledBackgroundColor: const Color(0xFF1877F2),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white70,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              shape: const RoundedRectangleBorder(),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            child: Text(
              buttonLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        if (showProgress) ...<Widget>[
          const SizedBox(height: 12),
          const Center(child: CircularProgressIndicator()),
        ],
        const Spacer(),
        Text(
          helperText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          appVersionLabel,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
