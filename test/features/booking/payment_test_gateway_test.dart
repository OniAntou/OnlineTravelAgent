import 'package:flutter_test/flutter_test.dart';
import 'package:online_travel_agent/features/booking/application/payment_test_gateway.dart';

void main() {
  test('hides cash test payments in a release build without an opt-in', () {
    expect(
      isCashTestPaymentEnabled(isReleaseBuild: true, allowTestPayments: false),
      isFalse,
    );
  });

  test(
    'allows cash test payments in development or an opted-in release build',
    () {
      expect(
        isCashTestPaymentEnabled(
          isReleaseBuild: false,
          allowTestPayments: false,
        ),
        isTrue,
      );
      expect(
        isCashTestPaymentEnabled(isReleaseBuild: true, allowTestPayments: true),
        isTrue,
      );
    },
  );
}
