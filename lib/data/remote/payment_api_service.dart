import 'api_http_client.dart';

class PaymentApiService {
  final ApiHttpClient _client;
  PaymentApiService(this._client);

  Future<Map<String, dynamic>> checkPromoCode(String code) async {
    return _client.getJson(
      _client.pathWithQuery('/api/promo-codes/check', {'code': code}),
    );
  }

  Future<Map<String, dynamic>> createVnpayPayment({
    required String tripId,
    String? orderInfo,
    String? locale,
  }) async {
    return _client.postJson('/api/payment/vnpay/create', {
      'tripId': tripId,
      'orderInfo': orderInfo ?? 'Thanh toÃ¡n Ä‘áº·t chá»— Online Travel Agent',
      'locale': locale ?? 'vn',
    }, queueOnFailure: false);
  }

  Future<Map<String, dynamic>> checkPaymentStatus(String tripId) async {
    return _client.getJson('/api/payment/vnpay/status/$tripId');
  }

  Future<Map<String, dynamic>> confirmCashTestPayment(String tripId) async {
    return _client.postJson('/api/payment/test/cash/confirm', {
      'tripId': tripId,
    }, queueOnFailure: false);
  }
}
