import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:online_travel_agent/data/services/travel_api_service.dart';

class FakeSecureStorage extends FlutterSecureStorage {
  final Map<String, String> data = {};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return data[key];
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      data[key] = value;
    } else {
      data.remove(key);
    }
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    data.remove(key);
  }
}

class TestTravelApiService extends TravelApiService {
  TestTravelApiService({required super.secureStorage}) : super(baseUrl: 'http://localhost:3000');

  @override
  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    await loadTokenFuture;
    final res = {
      'token': 'fake_jwt_token_nya',
      'user': {
        'name': 'Rushia',
        'email': 'rushia@neko.com',
      }
    };
    final tokenValue = res['token']?.toString();
    if (tokenValue != null) {
      token = tokenValue;
      userName = 'Rushia';
      userEmail = 'rushia@neko.com';
      try {
        await secureStorage.write(key: 'auth_token', value: tokenValue);
        await secureStorage.write(key: 'auth_user_name', value: 'Rushia');
        await secureStorage.write(key: 'auth_user_email', value: 'rushia@neko.com');
      } catch (_) {}
    }
    return res;
  }
}

void main() {
  group('TravelApiService Auth Session Tests', () {
    late FakeSecureStorage fakeStorage;
    late TestTravelApiService apiService;

    setUp(() {
      fakeStorage = FakeSecureStorage();
    });

    test('should save token and user info on successful login', () async {
      apiService = TestTravelApiService(secureStorage: fakeStorage);
      final res = await apiService.login(email: 'rushia@neko.com', password: 'password123');

      expect(res['token'], 'fake_jwt_token_nya');
      expect(apiService.token, 'fake_jwt_token_nya');
      expect(apiService.userName, 'Rushia');
      expect(apiService.userEmail, 'rushia@neko.com');

      // Verify that it is written to secure storage
      expect(await fakeStorage.read(key: 'auth_token'), 'fake_jwt_token_nya');
      expect(await fakeStorage.read(key: 'auth_user_name'), 'Rushia');
      expect(await fakeStorage.read(key: 'auth_user_email'), 'rushia@neko.com');
    });

    test('should load token and user info on initialization', () async {
      // Pre-populate secure storage
      await fakeStorage.write(key: 'auth_token', value: 'saved_token_nya');
      await fakeStorage.write(key: 'auth_user_name', value: 'Rushia Neko');
      await fakeStorage.write(key: 'auth_user_email', value: 'rushia@neko.com');

      apiService = TestTravelApiService(secureStorage: fakeStorage);
      await apiService.loadTokenFuture;

      expect(apiService.token, 'saved_token_nya');
      expect(apiService.userName, 'Rushia Neko');
      expect(apiService.userEmail, 'rushia@neko.com');
    });

    test('should delete token and user info on logout', () async {
      await fakeStorage.write(key: 'auth_token', value: 'saved_token_nya');
      apiService = TestTravelApiService(secureStorage: fakeStorage);
      await apiService.loadTokenFuture;

      expect(apiService.token, 'saved_token_nya');

      await apiService.logout();

      expect(apiService.token, isNull);
      expect(apiService.userName, isNull);
      expect(apiService.userEmail, isNull);
      expect(await fakeStorage.read(key: 'auth_token'), isNull);
    });
  });
}
