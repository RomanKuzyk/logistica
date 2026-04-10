import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/app/app_services.dart';
import 'package:mobile_app_flutter/features/order_search/data/order_search_repository.dart';
import 'package:mobile_app_flutter/features/order_search/domain/order_buy_search_item.dart';
import 'package:mobile_app_flutter/features/order_search/domain/work_mode.dart';
import 'package:mobile_app_flutter/features/order_search/presentation/order_details_page.dart';
import 'package:mobile_app_flutter/features/order_search/presentation/order_result_list_page.dart';
import 'package:mobile_app_flutter/features/order_search/presentation/reprint_action_page.dart';
import 'package:mobile_app_flutter/features/order_search/presentation/order_search_controller.dart';
import 'package:mobile_app_flutter/features/order_search/presentation/order_search_detail_page.dart';
import 'package:mobile_app_flutter/features/order_search/presentation/unpacking_summary_page.dart';
import 'package:mobile_app_flutter/features/scanner_capture/presentation/scanner_capture_page.dart';
import 'package:mobile_app_flutter/shared/widgets/legacy_alert_dialog.dart';

class OrderSearchPage extends StatefulWidget {
  const OrderSearchPage({
    super.key,
    required this.services,
    required this.mode,
  });

  final AppServices services;
  final WorkMode mode;

  @override
  State<OrderSearchPage> createState() => _OrderSearchPageState();
}

class _OrderSearchPageState extends State<OrderSearchPage> {
  late final TextEditingController _textController;
  late final OrderSearchController _controller;
  int _lastHandledTerminalEventId = 0;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _controller = OrderSearchController(
      repository: OrderSearchRepository(apiClient: widget.services.apiClient),
      logger: widget.services.logger,
      mode: widget.mode,
    )..addListener(_syncFromController);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_syncFromController)
      ..dispose();
    _textController.dispose();
    super.dispose();
  }

  void _syncFromController() {
    if (_textController.text != _controller.searchInput) {
      _textController.value = TextEditingValue(
        text: _controller.searchInput,
        selection:
            TextSelection.collapsed(offset: _controller.searchInput.length),
      );
    }

    if (!mounted) {
      return;
    }

    if (_controller.terminalEventId == _lastHandledTerminalEventId) {
      return;
    }
    _lastHandledTerminalEventId = _controller.terminalEventId;

    switch (_controller.status) {
      case OrderSearchStatus.error:
        final String? message = _controller.errorMessage;
        if (message != null && message.isNotEmpty) {
          showLegacyAlertDialog(
            context,
            title: 'Errors',
            message: 'Error : $message',
          );
        }
      case OrderSearchStatus.empty:
        final String query = _controller.normalizedQuery;
        showLegacyAlertDialog(
          context,
          title: 'Errors',
          message: 'Ми нічого не знайшли по вказаним умовам пошуку! \n$query',
        );
      case OrderSearchStatus.loaded:
        final List<OrderBuySearchItem> results = _controller.results;
        if (results.length == 1) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => switch (widget.mode) {
                WorkMode.unpack => UnpackingSummaryPage(
                    order: results.first,
                    services: widget.services,
                  ),
                WorkMode.reprint => ReprintActionPage(
                    order: results.first,
                    services: widget.services,
                  ),
                WorkMode.details => OrderDetailsPage(
                    order: results.first, services: widget.services),
                _ => OrderSearchDetailPage(
                    order: results.first,
                    services: widget.services,
                  ),
              },
            ),
          );
        } else if (results.length > 1) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => OrderResultListPage(
                results: results,
                services: widget.services,
                mode: widget.mode,
              ),
            ),
          );
        }
      case OrderSearchStatus.idle:
      case OrderSearchStatus.loading:
        break;
    }
  }

  Future<void> _openScanner() async {
    final String? scanned = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => const ScannerCapturePage(),
      ),
    );

    if (scanned != null && scanned.isNotEmpty) {
      await _controller.applyScanResult(scanned);
    }
  }

  Future<void> _search() async {
    FocusScope.of(context).unfocus();
    await _controller.search();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) {
        final bool canSearch =
            !_controller.isBusy && _controller.searchInput.trim().isNotEmpty;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              widget.mode.title,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1F1F1F),
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
            children: <Widget>[
              Container(
                color: const Color(0xFFF0F0F0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Column(
                  children: <Widget>[
                    Text(
                      widget.mode.title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF2B2B2B),
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _controller.screenDescription,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2B2B2B),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: TextField(
                  controller: _textController,
                  enabled: !_controller.isBusy,
                  readOnly: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(
                        color: Color(0xFF7A7A7A),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(
                        color: Color(0xFF7A7A7A),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(
                        color: Color(0xFF5F7EA6),
                        width: 1.2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2B2B2B),
                  ),
                  textAlign: TextAlign.center,
                  autocorrect: false,
                  enableSuggestions: false,
                  textInputAction: TextInputAction.search,
                  onChanged: _controller.setSearchInput,
                  onSubmitted: (_) => _search(),
                ),
              ),
              const SizedBox(height: 18),
              _LegacyActionButton(
                label: 'Розпочати пошук',
                enabled: canSearch,
                onPressed: _search,
              ),
              const SizedBox(height: 12),
              _LegacyActionButton(
                label: 'Відсканувати штрихкод',
                enabled: !_controller.isBusy,
                onPressed: _openScanner,
              ),
              if (_controller.totalCod > 0) ...<Widget>[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _controller.clearTotal,
                  icon: const Icon(Icons.clear_all),
                  label: Text(
                      'Скинути локальну суму COD (${_controller.totalCod.toStringAsFixed(2)})'),
                ),
              ],
              const SizedBox(height: 24),
              if (_controller.isBusy)
                const Center(child: CircularProgressIndicator()),
              if (_controller.results.length > 1)
                Card(
                  child: ListTile(
                    title: Text('Знайдено: ${_controller.results.length}'),
                    subtitle: const Text(
                      'Відкриття списку відбувається автоматично, як у legacy flow.',
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _LegacyActionButton extends StatelessWidget {
  const _LegacyActionButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        enabled ? const Color(0xFF197EF4) : const Color(0xFFE2E1E7);
    final Color foregroundColor =
        enabled ? Colors.white : const Color(0xFFB9B7C2);

    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: backgroundColor,
          disabledBackgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledForegroundColor: foregroundColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: Color(0xFF4F6484), width: 1),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
