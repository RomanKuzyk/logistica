import 'package:flutter/material.dart';

enum _LegacyAlertKind {
  warning,
  info,
  success,
}

Future<void> showLegacyAlertDialog(
  BuildContext context, {
  required String title,
  required String message,
}) {
  final _LegacyAlertKind kind = _resolveKind(title);
  final Color accentColor = switch (kind) {
    _LegacyAlertKind.warning => const Color(0xFFF7C62F),
    _LegacyAlertKind.info => const Color(0xFF3F7AD9),
    _LegacyAlertKind.success => const Color(0xFF34A853),
  };

  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 28),
            padding: const EdgeInsets.fromLTRB(18, 48, 18, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6E6E73),
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: kind == _LegacyAlertKind.warning
                          ? Colors.black
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: accentColor,
              child: Text(
                kind == _LegacyAlertKind.success ? '✓' : 'i',
                style: TextStyle(
                  color: kind == _LegacyAlertKind.warning
                      ? Colors.black87
                      : Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

_LegacyAlertKind _resolveKind(String title) {
  final String normalized = title.trim().toLowerCase();
  if (normalized == 'completed') {
    return _LegacyAlertKind.success;
  }
  if (normalized.contains('print') || normalized.contains('information')) {
    return _LegacyAlertKind.info;
  }
  return _LegacyAlertKind.warning;
}
