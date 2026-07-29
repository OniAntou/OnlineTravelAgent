import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:online_travel_agent/data/services/api_provider.dart';
import 'package:online_travel_agent/data/services/travel_api_service.dart';
import 'package:online_travel_agent/features/booking/presentation/payment_method_screen.dart';

class _CashTestApi extends TravelApiService {
  bool confirmed = false;

  _CashTestApi() : super(baseUrl: 'http://localhost:3000');

  @override
  Future<Map<String, dynamic>> confirmCashTestPayment(String tripId) async {
    confirmed = true;
    return {
      'tripId': tripId,
      'paymentStatus': 'SUCCESS',
      'paymentMethod': 'cash_test',
    };
  }
}

void main() {
  testWidgets('cash is an immediate successful test payment', (tester) async {
    final api = _CashTestApi();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [apiProvider.overrideWithValue(api)],
        child: MaterialApp(
          home: PaymentMethodScreen(
            totalPrice: 100000,
            onPaymentSuccess: () async => 'trip-test-1',
          ),
        ),
      ),
    );

    await tester.tap(find.text('Tiền mặt'));
    await tester.tap(find.text('Xác nhận & Thanh toán'));
    await tester.pumpAndSettle();

    expect(find.text('Đặt tour thành công!'), findsOneWidget);
    expect(api.confirmed, isTrue);
  });
}
