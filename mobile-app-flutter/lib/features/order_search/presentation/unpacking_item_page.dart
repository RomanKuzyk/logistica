import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/app/app_services.dart';
import 'package:mobile_app_flutter/core/api/api_exceptions.dart';
import 'package:mobile_app_flutter/core/media/media_exceptions.dart';
import 'package:mobile_app_flutter/core/printing/legacy_print_service.dart';
import 'package:mobile_app_flutter/features/order_search/data/unpacking_repository.dart';
import 'package:mobile_app_flutter/features/order_search/domain/order_buy_search_item.dart';
import 'package:mobile_app_flutter/features/order_search/domain/trable.dart';
import 'package:mobile_app_flutter/features/order_search/domain/unpacking_order_item_state.dart';
import 'package:mobile_app_flutter/features/order_search/presentation/trable_picker_page.dart';
import 'package:mobile_app_flutter/features/order_search/presentation/unpacking_controller.dart';
import 'package:mobile_app_flutter/shared/widgets/legacy_alert_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class UnpackingItemPage extends StatefulWidget {
  const UnpackingItemPage({
    super.key,
    required this.order,
    required this.services,
  });

  final OrderBuySearchItem order;
  final AppServices services;

  @override
  State<UnpackingItemPage> createState() => _UnpackingItemPageState();
}

class _UnpackingItemPageState extends State<UnpackingItemPage> {
  late final UnpackingController _controller;
  final Map<String, TextEditingController> _countControllers =
      <String, TextEditingController>{};
  final Map<String, TextEditingController> _commentControllers =
      <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    _controller = UnpackingController(
      repository: UnpackingRepository(apiClient: widget.services.apiClient),
      mediaService: widget.services.mediaService,
      printService: widget.services.printService,
      logger: widget.services.logger,
    )..load(widget.order.idRef);
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _countControllers.values) {
      controller.dispose();
    }
    for (final TextEditingController controller in _commentControllers.values) {
      controller.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickTrable(int index) async {
    try {
      final List<Trable> items = await _controller.loadTrables();
      if (!mounted) {
        return;
      }
      final Trable? selected = await Navigator.of(context).push<Trable>(
        MaterialPageRoute<Trable>(
          builder: (_) => TrablePickerPage(items: items),
        ),
      );
      if (selected != null) {
        _controller.updateTrable(index, selected);
      }
    } on ApiException catch (error) {
      _showMessage('Error : ${error.message}');
    }
  }

  Future<void> _captureOrderPhoto(int index) async {
    try {
      await _controller.captureOrderPhoto(index);
    } on MediaException catch (error) {
      if (error is MediaCancelledException) {
        return;
      }
      _showMessage(error.message, title: 'PHOTO');
    }
  }

  Future<void> _captureDocumentPhoto(int index) async {
    try {
      await _controller.captureDocumentPhoto(index);
    } on MediaException catch (error) {
      if (error is MediaCancelledException) {
        return;
      }
      _showMessage(error.message, title: 'PHOTO');
    }
  }

  Future<void> _submit(int index) async {
    final String? validation = _controller.validate(index);
    if (validation != null) {
      _showMessage(validation, title: 'Помилка');
      return;
    }

    try {
      final UnpackingSubmitOutcome outcome = await _controller.submit(
        index,
        orderBuyIdRef: widget.order.idRef,
      );
      if (!mounted) {
        return;
      }

      if (!outcome.result.isSuccess) {
        _showMessage('Error : ${outcome.result.errorDetail}', title: 'Помилка');
        return;
      }

      if (_controller.itemCount == 1) {
        await showLegacyAlertDialog(
          context,
          title: 'Completed',
          message: 'Замовлення оброблено. Дякую !',
        );
      }

      await _showPrintAlertIfNeeded(outcome.printResult);

      if (!mounted) {
        return;
      }

      if (_controller.itemCount == 1) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    } on ApiException catch (error) {
      _showMessage('Error : ${error.message}', title: 'Помилка');
    }
  }

  Future<void> _showPrintAlertIfNeeded(LegacyPrintResult result) async {
    switch (result.status) {
      case LegacyPrintStatus.completed:
        return;
      case LegacyPrintStatus.cancelled:
        return showLegacyAlertDialog(
          context,
          title: 'Print',
          message: 'User push cancel button...',
        );
      case LegacyPrintStatus.dataUnavailable:
        return showLegacyAlertDialog(
          context,
          title: 'Print',
          message: 'Sorry print is not compleated data is null..',
        );
      case LegacyPrintStatus.failed:
        return showLegacyAlertDialog(
          context,
          title: 'Print',
          message: 'Sorry print is not compleated..: ${result.errorMessage}',
        );
    }
  }

  Future<void> _openSellerSite(String link) async {
    final Uri? uri = Uri.tryParse(link);
    if (uri == null) {
      return;
    }

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  void _ensureControllers(List<UnpackingOrderItemState> items) {
    for (final UnpackingOrderItemState item in items) {
      _countControllers.putIfAbsent(
        item.orderItem.idRef,
        () => TextEditingController(text: item.count.toString()),
      );
      final TextEditingController countController =
          _countControllers[item.orderItem.idRef]!;
      if (countController.text != item.count.toString()) {
        countController.text = item.count.toString();
      }

      _commentControllers.putIfAbsent(
        item.orderItem.idRef,
        () => TextEditingController(text: item.trableComments),
      );
      final TextEditingController commentController =
          _commentControllers[item.orderItem.idRef]!;
      if (commentController.text != item.trableComments) {
        commentController.text = item.trableComments;
      }
    }
  }

  void _showMessage(String message, {String title = 'Помилка'}) {
    showLegacyAlertDialog(context, title: title, message: message);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) {
        _ensureControllers(_controller.items);
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text(''),
            actions: const <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    'Обрати',
                    style: TextStyle(color: Colors.white38, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          body: AbsorbPointer(
            absorbing: _controller.isBusy,
            child: _buildBody(),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _controller.errorMessage!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_controller.items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Ми нічого не знайшли по вказаним умовам пошуку!',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: _controller.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 18),
      itemBuilder: (BuildContext context, int index) {
        final UnpackingOrderItemState item = _controller.items[index];
        return _UnpackingOrderCard(
          state: item,
          countController: _countControllers[item.orderItem.idRef]!,
          commentController: _commentControllers[item.orderItem.idRef]!,
          onCountChanged: (String value) =>
              _controller.updateCount(index, value),
          onCommentsChanged: (String value) =>
              _controller.updateComments(index, value),
          onSelectTypeDocuments: (int value) =>
              _controller.updateTypeDocuments(index, value),
          onSelectTrable: () => _pickTrable(index),
          onCaptureOrderPhoto: () => _captureOrderPhoto(index),
          onCaptureDocumentPhoto: item.documentPhotoButtonEnabled
              ? () => _captureDocumentPhoto(index)
              : null,
          onOpenSellerSite: item.orderItem.link.isNotEmpty
              ? () => _openSellerSite(item.orderItem.link)
              : null,
          onSubmit: item.disabled ? null : () => _submit(index),
        );
      },
    );
  }
}

class _UnpackingOrderCard extends StatelessWidget {
  const _UnpackingOrderCard({
    required this.state,
    required this.countController,
    required this.commentController,
    required this.onCountChanged,
    required this.onCommentsChanged,
    required this.onSelectTypeDocuments,
    required this.onSelectTrable,
    required this.onCaptureOrderPhoto,
    required this.onCaptureDocumentPhoto,
    required this.onOpenSellerSite,
    required this.onSubmit,
  });

  final UnpackingOrderItemState state;
  final TextEditingController countController;
  final TextEditingController commentController;
  final ValueChanged<String> onCountChanged;
  final ValueChanged<String> onCommentsChanged;
  final ValueChanged<int> onSelectTypeDocuments;
  final VoidCallback onSelectTrable;
  final VoidCallback onCaptureOrderPhoto;
  final VoidCallback? onCaptureDocumentPhoto;
  final VoidCallback? onOpenSellerSite;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final bool isActionDisabled = state.disabled;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD7D7D7)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            state.orderItem.number,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 2),
          Text(
            state.orderItem.orderDate,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: state.orderItem.linkPhoto.isEmpty
                ? _buildImagePlaceholder()
                : Image.network(
                    state.orderItem.linkPhoto,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                  ),
          ),
          TextButton(
            onPressed: onOpenSellerSite,
            child: const Text(
              'Перехід на сайт продавця',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Кількість :', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 12),
              SizedBox(
                width: 78,
                height: 34,
                child: TextField(
                  controller: countController,
                  enabled: !isActionDisabled,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  ),
                  onChanged: onCountChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _LegacySwitchRow(
            label: 'Чек :',
            value: state.typeDocuments == 1,
            enabled: !isActionDisabled,
            onChanged: (_) => onSelectTypeDocuments(1),
          ),
          _LegacySwitchRow(
            label: 'Умова :',
            value: state.typeDocuments == 2,
            enabled: !isActionDisabled,
            onChanged: (_) => onSelectTypeDocuments(2),
          ),
          _LegacySwitchRow(
            label: 'Фактура :',
            value: state.typeDocuments == 3,
            enabled: !isActionDisabled,
            onChanged: (_) => onSelectTypeDocuments(3),
          ),
          _LegacySwitchRow(
            label: 'Документи відсутні :',
            value: state.typeDocuments == 4,
            enabled: !isActionDisabled,
            onChanged: (_) => onSelectTypeDocuments(4),
          ),
          const SizedBox(height: 10),
          _LegacyColorButton(
            label: state.photoDocumentsExecute
                ? 'Зроблено фото документів'
                : 'Фото документів',
            color: onCaptureDocumentPhoto == null
                ? const Color(0xFF9C9C9C)
                : const Color(0xFF34A853),
            onPressed: onCaptureDocumentPhoto,
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFD0D0D0)),
          const SizedBox(height: 14),
          _LegacyColorButton(
            label: state.trableButtonLabel,
            color: const Color(0xFFB08D5C),
            onPressed: isActionDisabled ? null : onSelectTrable,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: commentController,
            enabled: !isActionDisabled,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.zero),
              hintText: 'Коментар до проблеми',
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onChanged: onCommentsChanged,
          ),
          const SizedBox(height: 8),
          _LegacyColorButton(
            label: state.photoExecute
                ? 'Зроблено фото товару'
                : 'Зробіть фото товару !',
            color: state.photoExecute
                ? const Color(0xFF1877F2)
                : const Color(0xFFFF3B30),
            onPressed: isActionDisabled ? null : onCaptureOrderPhoto,
          ),
          const SizedBox(height: 8),
          _LegacyColorButton(
            label: state.disabled
                ? '- ТОВАР РАЗПАКОВАНО -'
                : state.photoExecute
                    ? 'Прийняти товар'
                    : 'Прийняти не можливо , зробіть фото',
            color: state.disabled
                ? Colors.orange
                : state.photoExecute
                    ? const Color(0xFF34A853)
                    : const Color(0xFF9C9C9C),
            onPressed: state.disabled || !state.photoExecute ? null : onSubmit,
          ),
          const SizedBox(height: 20),
          Text(
            state.orderItem.manager,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            state.orderItem.customRoute,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.red,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.white,
    );
  }
}

class _LegacySwitchRow extends StatelessWidget {
  const _LegacySwitchRow({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 18),
          ),
        ),
        Switch(
          value: value,
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}

class _LegacyColorButton extends StatelessWidget {
  const _LegacyColorButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: color.withValues(alpha: 0.85),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white70,
          shape: const RoundedRectangleBorder(),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        child: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}
