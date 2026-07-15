import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_travel_agent/features/auth/application/auth_provider.dart';
import 'package:online_travel_agent/data/services/api_provider.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('AuthNotifier', () {
    late FakeSecureStorage fakeStorage;
    late FakeTravelApiService fakeApi;
    late ProviderContainer container;

    setUp(() {
      fakeStorage = FakeSecureStorage();
      fakeApi = FakeTravelApiService(secureStorage: fakeStorage);
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is logged out', () {
      container = ProviderContainer(
        overrides: [apiProvider.overrideWithValue(fakeApi)],
      );
      final state = container.read(authProvider);
      expect(state.isLoggedIn, false);
      expect(state.token, isNull);
      expect(state.user, isNull);
    });

    test('login success sets isLoggedIn and user', () async {
      container = ProviderContainer(
        overrides: [apiProvider.overrideWithValue(fakeApi)],
      );
      final notifier = container.read(authProvider.notifier);
      final error = await notifier.login(
        email: 'test@test.com',
        password: 'password123',
      );

      expect(error, isNull);
      final state = container.read(authProvider);
      expect(state.isLoggedIn, true);
      expect(state.token, 'fake_token');
      expect(state.user?.name, 'Test');
      expect(state.user?.email, 'test@test.com');
    });

    test('login failure returns error message', () async {
      fakeApi = FakeTravelApiService(
        secureStorage: fakeStorage,
        loginError: 'Invalid credentials',
      );
      container = ProviderContainer(
        overrides: [apiProvider.overrideWithValue(fakeApi)],
      );
      final notifier = container.read(authProvider.notifier);
      final error = await notifier.login(
        email: 'test@test.com',
        password: 'wrong',
      );

      expect(error, isNotNull);
      expect(error, contains('Invalid credentials'));
      final state = container.read(authProvider);
      expect(state.isLoggedIn, false);
    });

    test('register success sets isLoggedIn and user', () async {
      container = ProviderContainer(
        overrides: [apiProvider.overrideWithValue(fakeApi)],
      );
      final notifier = container.read(authProvider.notifier);
      final error = await notifier.register(
        name: 'NewUser',
        email: 'new@test.com',
        password: 'password123',
      );

      expect(error, isNull);
      final state = container.read(authProvider);
      expect(state.isLoggedIn, true);
      expect(state.user?.name, 'NewUser');
      expect(state.user?.email, 'new@test.com');
    });

    test('register failure returns error message', () async {
      fakeApi = FakeTravelApiService(
        secureStorage: fakeStorage,
        registerError: 'Email already exists',
      );
      container = ProviderContainer(
        overrides: [apiProvider.overrideWithValue(fakeApi)],
      );
      final notifier = container.read(authProvider.notifier);
      final error = await notifier.register(
        name: 'NewUser',
        email: 'existing@test.com',
        password: 'password123',
      );

      expect(error, isNotNull);
      expect(error, contains('Email already exists'));
    });

    test('logout clears state immediately and exposes completion', () async {
      final logoutGate = Completer<void>();
      fakeApi = _DelayedLogoutApi(fakeStorage, logoutGate);
      container = ProviderContainer(
        overrides: [apiProvider.overrideWithValue(fakeApi)],
      );
      final notifier = container.read(authProvider.notifier);

      // Login first
      await notifier.login(email: 'test@test.com', password: 'password123');
      expect(container.read(authProvider).isLoggedIn, true);

      // Logout
      final logoutFuture = notifier.logout();
      final state = container.read(authProvider);
      expect(state.isLoggedIn, false);
      expect(state.token, isNull);
      expect(state.user, isNull);

      var completed = false;
      logoutFuture.then((_) => completed = true);
      await Future<void>.delayed(Duration.zero);
      expect(completed, false);

      logoutGate.complete();
      await logoutFuture;
      expect(completed, true);
    });

    test('session restore from storage', () async {
      // Pre-populate storage
      await fakeStorage.write(key: 'auth_token', value: 'saved_token');
      await fakeStorage.write(key: 'auth_user_name', value: 'SavedUser');
      await fakeStorage.write(key: 'auth_user_email', value: 'saved@test.com');

      fakeApi = FakeTravelApiService(secureStorage: fakeStorage);
      container = ProviderContainer(
        overrides: [apiProvider.overrideWithValue(fakeApi)],
      );

      // Pre-load the token on the fake API (simulating what _loadToken does)
      await fakeApi.loadTokenFuture;

      // Create the notifier - build() calls _restoreSession()
      container.read(authProvider.notifier);

      // Wait for _restoreSession async to complete
      await Future.delayed(const Duration(milliseconds: 500));

      final state = container.read(authProvider);
      expect(state.isLoggedIn, true);
      expect(state.token, 'saved_token');
      expect(state.user?.name, 'SavedUser');
    });
  });
}

class _DelayedLogoutApi extends FakeTravelApiService {
  _DelayedLogoutApi(FakeSecureStorage storage, this.gate)
    : super(secureStorage: storage);

  final Completer<void> gate;

  @override
  Future<void> logout() => gate.future;
}
