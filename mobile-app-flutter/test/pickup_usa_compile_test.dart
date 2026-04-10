import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app_flutter/features/pickup_usa/data/pickup_repository.dart';
import 'package:mobile_app_flutter/features/pickup_usa/domain/pickup_models.dart';
import 'package:mobile_app_flutter/features/pickup_usa/presentation/pickup_pages.dart';

void main() {
  test('pickup USA constants mirror legacy lists', () {
    expect(PickupRepository.cancelReasons, hasLength(4));
    expect(PickupRepository.timeOptions, hasLength(16));
    expect(PickupRepository.cancelReasons.first, isA<PickupCancelReason>());
    expect(PickupConfirmationMode.sms.name, 'sms');
  });
}
