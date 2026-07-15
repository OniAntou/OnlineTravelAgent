import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/theme/app_theme.dart';
import 'api_http_client.dart';

class PaymentApiService {
  final ApiHttpClient _client;
  PaymentApiService(this._client);

  Future<Map<String, dynamic>> checkPromoCode(String code) async {
    await _client.ensureTokenLoaded();
    return _client.safeCall(() async {
      final response = await http.get(_client.uriWithQuery('/api/promo-codes/check', {'code': code}), headers: _client.headers).timeout(AppTheme.apiTimeout);
      _client.throwIfError(response);
      return jsonDecode(response.body) as Map<String, dynamic>;
    });
  }

  Future<Map<String, dynamic>> createVnpayPayment({required String tripId, required double amount, String? orderInfo, String? locale}) async {
    return _client.postJson('/api/payment/vnpay/create', {'tripId': tripId, 'amount': amount, 'orderInfo': orderInfo ?? 'Thanh toán đặt chỗ Online Travel Agent', 'locale': locale ?? 'vn'}, queueOnFailure: false);
  }

  Future<Map<String, dynamic>> checkPaymentStatus(String tripId) async {
    return _client.getJson('/api/payment/vnpay/status/$tripId');
  }

  Future<Map<String, dynamic>> createMomoPayment({required String tripId, required double amount, String? orderInfo}) async {
    return _client.postJson('/api/payment/momo/create', {'tripId': tripId, 'amount': amount, 'orderInfo': orderInfo ?? 'Thanh toán đặt chỗ Online Travel Agent'}, queueOnFailure: false);
  }
}
