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
    required double amount,
    String? orderInfo,
    String? locale,
  }) async {
    return _client.postJson('/api/payment/vnpay/create', {
      'tripId': tripId,
      'amount': amount,
      'orderInfo': orderInfo ?? 'Thanh toán đặt chỗ Online Travel Agent',
      'locale': locale ?? 'vn',
    }, queueOnFailure: false);
  }

  Future<Map<String, dynamic>> checkPaymentStatus(String tripId) async {
    return _client.getJson('/api/payment/vnpay/status/$tripId');
  }

  Future<Map<String, dynamic>> createMomoPayment({
    required String tripId,
    required double amount,
    String? orderInfo,
  }) async {
    return _client.postJson('/api/payment/momo/create', {
      'tripId': tripId,
      'amount': amount,
      'orderInfo': orderInfo ?? 'Thanh toán đặt chỗ Online Travel Agent',
    }, queueOnFailure: false);
  }
}
