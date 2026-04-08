import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/features/order_search/domain/order_buy_search_item.dart';
import 'package:mobile_app_flutter/shared/widgets/legacy_alert_dialog.dart';

class UnpackingItemPage extends StatefulWidget {
  const UnpackingItemPage({
    super.key,
    required this.order,
  });

  final OrderBuySearchItem order;

  @override
  State<UnpackingItemPage> createState() => _UnpackingItemPageState();
}

class _UnpackingItemPageState extends State<UnpackingItemPage> {
  bool checkEnabled = false;
  bool termsEnabled = false;
  bool invoiceEnabled = false;
  bool noDocumentsEnabled = false;

  void _showPlaceholder(String label) {
    showLegacyAlertDialog(
      context,
      title: 'Information',
      message: '$label буде підключено наступним кроком.',
    );
  }

  @override
  Widget build(BuildContext context) {
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
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: <Widget>[
          Text(
            widget.order.displayNumber,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            widget.order.nameOrders.isEmpty ? '—' : widget.order.nameOrders,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 18),
          Container(
            height: 180,
            alignment: Alignment.center,
            color: Colors.white,
            child: const Text(
              'Sorry\nIMAGE\nNOT AVAILABLE',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                height: 1,
                color: Color(0xFFCFCFCF),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _showPlaceholder('Перехід на сайт продавця'),
            child: const Text(
              'Перехід на сайт продавця',
              style: TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Кількість :', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 12),
              Container(
                width: 70,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE3E3E3)),
                ),
                child: const Text('1', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ToggleRow(
            label: 'Чек :',
            value: checkEnabled,
            onChanged: (bool value) => setState(() => checkEnabled = value),
          ),
          _ToggleRow(
            label: 'Умова :',
            value: termsEnabled,
            onChanged: (bool value) => setState(() => termsEnabled = value),
          ),
          _ToggleRow(
            label: 'Фактура :',
            value: invoiceEnabled,
            onChanged: (bool value) => setState(() => invoiceEnabled = value),
          ),
          _ToggleRow(
            label: 'Документи відсутні :',
            value: noDocumentsEnabled,
            onChanged: (bool value) =>
                setState(() => noDocumentsEnabled = value),
          ),
          const SizedBox(height: 10),
          _GrayButton(
            label: 'Фото документів',
            onPressed: () => _showPlaceholder('Фото документів'),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFD0D0D0)),
          const SizedBox(height: 18),
          _GrayButton(
            label: 'Оберіть проблему',
            onPressed: () => _showPlaceholder('Оберіть проблему'),
          ),
          const SizedBox(height: 8),
          _ColorButton(
            label: 'Зробіть фото товару !',
            color: const Color(0xFFFF3B30),
            onPressed: () => _showPlaceholder('Зробіть фото товару'),
          ),
          const SizedBox(height: 8),
          _GrayButton(
            label: 'Прийняти не можливо , зробіть фото',
            onPressed: () =>
                _showPlaceholder('Прийняти не можливо , зробіть фото'),
          ),
          const SizedBox(height: 28),
          const Text(
            'Крупа Віталія Юрковівна',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 4),
          const Text(
            'IN (Зелений)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.red,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(label, style: const TextStyle(fontSize: 18)),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _GrayButton extends StatelessWidget {
  const _GrayButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _ColorButton(
      label: label,
      color: const Color(0xFF9C9C9C),
      onPressed: onPressed,
    );
  }
}

class _ColorButton extends StatelessWidget {
  const _ColorButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
