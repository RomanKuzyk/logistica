import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app_flutter/features/order_search/data/tracking_normalizer.dart';

void main() {
  group('truncateTracking', () {
    test('keeps unknown formats unchanged', () {
      expect(truncateTracking('ABC123'), 'ABC123');
    });

    test('normalizes 28-char percent code', () {
      expect(
        truncateTracking('%10387001000410351689U101616'),
        '1000410351689U',
      );
    });

    test('normalizes 34-char codes that start with 9', () {
      expect(
        truncateTracking('9000000000000000000000123456789012'),
        '123456789012',
      );
    });

    test('normalizes 30-char codes that start with 4', () {
      expect(
        truncateTracking('400000000012345678901234567890'),
        '12345678901234567890',
      );
    });
  });
}
