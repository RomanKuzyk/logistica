import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/app/app_services.dart';
import 'package:mobile_app_flutter/features/auth/presentation/auth_controller.dart';
import 'package:mobile_app_flutter/features/auth/presentation/registration_page.dart';
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
      MaterialPageRoute<void>(builder: (_) => WorkMenuPage(user: user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('GlobalCars Mobile'),
            actions: <Widget>[
              IconButton(onPressed: _openSettings, icon: const Icon(Icons.settings)),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildBody(context),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_controller.status) {
      case AuthStatus.loading:
        return _InfoScaffold(
          title: 'Loading...',
          subtitle: _controller.backendVersion == null
              ? 'Перевіряємо реєстрацію девайса'
              : 'Backend version: ${_controller.backendVersion}',
          child: const Padding(
            padding: EdgeInsets.only(top: 16),
            child: CircularProgressIndicator(),
          ),
        );
      case AuthStatus.registrationRequired:
        return RegistrationPage(
          onRegister: _controller.registerEmployee,
          onDemoMode: _controller.useDemoMode,
          busy: false,
          canUseDemoMode: _controller.canUseDemoMode,
          errorMessage: _controller.errorMessage,
          deviceId: _controller.deviceId,
        );
      case AuthStatus.registering:
        return RegistrationPage(
          onRegister: _controller.registerEmployee,
          onDemoMode: _controller.useDemoMode,
          busy: true,
          canUseDemoMode: _controller.canUseDemoMode,
          errorMessage: _controller.errorMessage,
          deviceId: _controller.deviceId,
        );
      case AuthStatus.readyToStart:
      case AuthStatus.startingWork:
        final user = _controller.currentUser;
        return _InfoScaffold(
          title: user == null
              ? 'Розпочати роботу'
              : 'Розпочати: ${user.displayName.toUpperCase()}',
          subtitle: _controller.backendVersion == null
              ? 'Девайс зареєстрований'
              : 'Backend version: ${_controller.backendVersion}',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (_controller.deviceId != null) ...<Widget>[
                const SizedBox(height: 16),
                SelectableText('Device ID: ${_controller.deviceId!}'),
              ],
              const SizedBox(height: 16),
              FilledButton(onPressed: _startWork, child: const Text('Розпочати')),
            ],
          ),
        );
      case AuthStatus.error:
        return _InfoScaffold(
          title: 'Auth error',
          subtitle: _controller.errorMessage ?? 'Unknown error',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 16),
              FilledButton(onPressed: _controller.bootstrap, child: const Text('Retry')),
            ],
          ),
        );
    }
  }
}

class _InfoScaffold extends StatelessWidget {
  const _InfoScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(subtitle),
            child,
          ],
        ),
      ),
    );
  }
}
