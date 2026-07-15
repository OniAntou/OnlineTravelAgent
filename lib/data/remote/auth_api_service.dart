import 'api_http_client.dart';

class AuthApiService {
  final ApiHttpClient _client;
  AuthApiService(this._client);

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    await _client.waitForLocalLogout();
    final res = await _client.postJson('/api/auth/login', {
      'email': email,
      'password': password,
    }, queueOnFailure: false);
    return _client.handleAuthResponse(res);
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _client.waitForLocalLogout();
    final res = await _client.postJson('/api/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    }, queueOnFailure: false);
    return _client.handleAuthResponse(res);
  }

  Future<void> logout() => _client.logout();

  Future<Map<String, dynamic>> becomePartner() async {
    return await _client.postJson(
      '/api/auth/become-partner',
      {},
      queueOnFailure: false,
    );
  }
}
