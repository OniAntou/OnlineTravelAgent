import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../core/exceptions.dart';
import '../../core/theme/app_theme.dart';
import '../../database/app_database.dart';
import '../../utils/api_exception.dart';

class ApiHttpClient {
  ApiHttpClient({String? baseUrl, FlutterSecureStorage? secureStorage})
    : _baseUrl = baseUrl ?? _defaultBaseUrl(),
      _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    loadTokenFuture = _loadToken();
  }

  final String _baseUrl;
  final FlutterSecureStorage _secureStorage;
  FlutterSecureStorage get secureStorage => _secureStorage;
  String? token;
  String? refreshToken;
  String? userName;
  String? userEmail;
  String? userRole;
  late final Future<void> loadTokenFuture;
  void Function()? onAuthError;
  Future<bool>? _refreshFuture;

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'auth_refresh_token';

  Future<void> _loadToken() async {
    try {
      token = await _secureStorage.read(key: _tokenKey);
      refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      userName = await _secureStorage.read(key: 'auth_user_name');
      userEmail = await _secureStorage.read(key: 'auth_user_email');
      userRole = await _secureStorage.read(key: 'auth_user_role');
    } catch (e) {
      debugPrint('Failed to read token from secure storage: $e');
    }
  }

  Future<void> ensureTokenLoaded() async {
    await loadTokenFuture;
  }

  String get baseUrl => _baseUrl;

  static String _defaultBaseUrl() {
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    return resolveBaseUrl(
      apiBaseUrl: fromDefine,
      releaseMode: kReleaseMode,
      isAndroid: !kIsWeb && defaultTargetPlatform == TargetPlatform.android,
    );
  }

  @visibleForTesting
  static String resolveBaseUrl({
    required String apiBaseUrl,
    required bool releaseMode,
    required bool isAndroid,
  }) {
    if (apiBaseUrl.isNotEmpty) {
      if (releaseMode && !apiBaseUrl.startsWith('https://')) {
        throw StateError('Production API URL must use HTTPS');
      }
      return apiBaseUrl;
    }
    if (releaseMode) {
      throw StateError(
        'API_BASE_URL must be set in release mode via --dart-define=API_BASE_URL=https://...',
      );
    }
    if (isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  Uri uri(String path) => Uri.parse('$_baseUrl$path');

  Uri uriWithQuery(String path, Map<String, String?> query) {
    return Uri.parse('$_baseUrl${pathWithQuery(path, query)}');
  }

  String pathWithQuery(String path, Map<String, String?> query) {
    final filtered = <String, String>{};
    query.forEach((key, value) {
      if (value != null && value.isNotEmpty) {
        filtered[key] = value;
      }
    });
    return Uri(
      path: path,
      queryParameters: filtered.isEmpty ? null : filtered,
    ).toString();
  }

  Map<String, String> get headers {
    final result = {'Content-Type': 'application/json'};
    if (token != null && token!.isNotEmpty) {
      result['Authorization'] = 'Bearer $token';
    }
    return result;
  }

  bool _canAutoRefresh(String path) {
    return !path.startsWith('/api/auth/login') &&
        !path.startsWith('/api/auth/register') &&
        !path.startsWith('/api/auth/refresh');
  }

  Future<bool> refreshAccessToken() {
    final refreshInFlight = _refreshFuture;
    if (refreshInFlight != null) return refreshInFlight;
    if (refreshToken == null || refreshToken!.isEmpty) {
      return Future<bool>.value(false);
    }

    late final Future<bool> refresh;
    refresh = _performRefreshAccessToken().whenComplete(() {
      if (identical(_refreshFuture, refresh)) {
        _refreshFuture = null;
      }
    });
    _refreshFuture = refresh;
    return refresh;
  }

  Future<bool> _performRefreshAccessToken() async {
    try {
      final response = await http
          .post(
            uri('/api/auth/refresh'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(AppTheme.apiTimeout);

      if (response.statusCode != 200) return false;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final nextToken = data['token']?.toString();
      final nextRefreshToken = data['refreshToken']?.toString();
      if (nextToken == null || nextRefreshToken == null) return false;

      token = nextToken;
      refreshToken = nextRefreshToken;
      await _secureStorage.write(key: _tokenKey, value: nextToken);
      await _secureStorage.write(
        key: _refreshTokenKey,
        value: nextRefreshToken,
      );
      return true;
    } catch (e) {
      debugPrint('Refresh token failed: $e');
      return false;
    }
  }

  Future<http.Response> sendRequest(
    String method,
    String path, [
    Map<String, dynamic>? body,
    bool queueOnFailure = true,
  ]) async {
    await ensureTokenLoaded();
    return safeCall(
      () => _sendRequestOnce(method, path, body, allowRefresh: true),
      method,
      path,
      body,
      queueOnFailure,
    );
  }

  Future<http.Response> _sendRequestOnce(
    String method,
    String path,
    Map<String, dynamic>? body, {
    required bool allowRefresh,
  }) async {
    final response = await _executeHttp(method, path, body);

    if (response.statusCode == 401 && allowRefresh && _canAutoRefresh(path)) {
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        return _sendRequestOnce(method, path, body, allowRefresh: false);
      }
    }

    throwIfError(response);
    return response;
  }

  Future<http.Response> _executeHttp(
    String method,
    String path,
    Map<String, dynamic>? body,
  ) async {
    final targetUri = uri(path);
    switch (method) {
      case 'GET':
        return http
            .get(targetUri, headers: headers)
            .timeout(AppTheme.apiTimeout);
      case 'POST':
        return http
            .post(targetUri, headers: headers, body: jsonEncode(body))
            .timeout(AppTheme.apiTimeout);
      case 'PATCH':
        return http
            .patch(targetUri, headers: headers, body: jsonEncode(body))
            .timeout(AppTheme.apiTimeout);
      case 'PUT':
        return http
            .put(targetUri, headers: headers, body: jsonEncode(body))
            .timeout(AppTheme.apiTimeout);
      case 'DELETE':
        return http
            .delete(targetUri, headers: headers)
            .timeout(AppTheme.apiTimeout);
      default:
        throw UnsupportedError('Unsupported HTTP method: $method');
    }
  }

  Future<Map<String, dynamic>> getJson(String path) async {
    final response = await sendRequest('GET', path);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> getList(String path) async {
    final response = await sendRequest('GET', path);
    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body, {
    bool queueOnFailure = true,
  }) async {
    final response = await sendRequest('POST', path, body, queueOnFailure);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> patchJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await sendRequest('PATCH', path, body);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> putJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await sendRequest('PUT', path, body);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> delete(String path) async {
    await sendRequest('DELETE', path);
  }

  Future<Map<String, dynamic>> handleAuthResponse(
    Map<String, dynamic> res,
  ) async {
    final tokenValue = res['token']?.toString();
    final refreshValue = res['refreshToken']?.toString();
    if (tokenValue != null) {
      token = tokenValue;
      refreshToken = refreshValue;
      try {
        await _secureStorage.write(key: _tokenKey, value: tokenValue);
        if (refreshValue != null) {
          await _secureStorage.write(
            key: _refreshTokenKey,
            value: refreshValue,
          );
        }
        final resName = (res['user'] as Map<String, dynamic>?)?['name']
            ?.toString();
        final resEmail = (res['user'] as Map<String, dynamic>?)?['email']
            ?.toString();
        final resRole = (res['user'] as Map<String, dynamic>?)?['role']
            ?.toString();
        if (resName != null) {
          userName = resName;
          await _secureStorage.write(key: 'auth_user_name', value: resName);
        }
        if (resEmail != null) {
          userEmail = resEmail;
          await _secureStorage.write(key: 'auth_user_email', value: resEmail);
        }
        if (resRole != null) {
          userRole = resRole;
          await _secureStorage.write(key: 'auth_user_role', value: resRole);
        }
      } catch (e) {
        debugPrint('Failed to write auth data to secure storage: $e');
      }
    }
    return res;
  }

  Future<void> logout() async {
    final currentRefreshToken = refreshToken;
    try {
      if (currentRefreshToken != null && currentRefreshToken.isNotEmpty) {
        await http
            .post(
              uri('/api/auth/logout'),
              headers: headers,
              body: jsonEncode({'refreshToken': currentRefreshToken}),
            )
            .timeout(AppTheme.apiTimeout);
      }
    } catch (e) {
      debugPrint('Server logout failed: $e');
    }

    token = null;
    refreshToken = null;
    userName = null;
    userEmail = null;
    userRole = null;
    try {
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      await _secureStorage.delete(key: 'auth_user_name');
      await _secureStorage.delete(key: 'auth_user_email');
      await _secureStorage.delete(key: 'auth_user_role');
    } catch (e) {
      debugPrint('Failed to delete auth data from secure storage: $e');
    }

    try {
      await _clearLocalUserOwnedData();
    } catch (e) {
      debugPrint('Failed to clear local user data: $e');
    }
  }

  Future<void> _clearLocalUserOwnedData() async {
    var hasInitializedBinding = true;
    assert(() {
      hasInitializedBinding = BindingBase.debugBindingType() != null;
      return true;
    }());
    if (!hasInitializedBinding) return;

    await AppDatabase.instance().clearUserOwnedData();
  }

  void throwIfError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    final body = response.body;
    String message;
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      message =
          json['error']?.toString() ?? json['message']?.toString() ?? body;
    } catch (_) {
      message = body;
    }

    switch (response.statusCode) {
      case 400:
        throw ValidationException(message: message);
      case 401:
        if (onAuthError != null) onAuthError!();
        throw AuthException(message: message);
      case 403:
        throw ForbiddenException(message: message);
      case 404:
        throw NotFoundException(message: message);
      case 500:
      case 502:
      case 503:
        throw ServerException(message: message);
      default:
        throw ApiException(
          statusCode: response.statusCode,
          message: 'API Error (${response.statusCode}): $message',
        );
    }
  }

  Future<T> safeCall<T>(
    Future<T> Function() call, [
    String? method,
    String? path,
    Map<String, dynamic>? body,
    bool queueOnFailure = true,
  ]) async {
    try {
      return await call();
    } on ApiException {
      rethrow;
    } on SocketException {
      if (queueOnFailure && method != null && method != 'GET' && path != null) {
        await queueRequest(method, path, body);
        throw const NetworkException(
          message: 'Network disconnected. Request queued offline.',
        );
      }
      throw const NetworkException();
    } on HttpException {
      if (queueOnFailure && method != null && method != 'GET' && path != null) {
        await queueRequest(method, path, body);
        throw const NetworkException(
          message: 'Cannot connect to server. Request queued offline.',
        );
      }
      throw const NetworkException(message: 'Cannot connect to server.');
    } on TimeoutException {
      if (queueOnFailure && method != null && method != 'GET' && path != null) {
        await queueRequest(method, path, body);
        throw const TimeoutApiException(
          message: 'Request timed out. Request queued offline.',
        );
      }
      throw const TimeoutApiException();
    } on FormatException {
      throw const ParseException();
    }
  }

  Future<void> queueRequest(
    String method,
    String path,
    Map<String, dynamic>? body,
  ) async {
    final db = AppDatabase.instance();
    await db.offlineQueueDao.insertItem(
      OfflineQueueTableCompanion.insert(
        endpoint: path,
        method: method,
        bodyJson: drift.Value(body != null ? jsonEncode(body) : null),
      ),
    );
  }

  Future<void> flushRequest(
    String method,
    String path,
    Map<String, dynamic>? body,
  ) async {
    await sendRequest(method, path, body, false);
  }
}
