// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:online_travel_agent/main.dart';
import 'package:online_travel_agent/providers/api_provider.dart';
import 'package:online_travel_agent/services/travel_api_service.dart';
import 'package:online_travel_agent/services/sync_service.dart';
import 'package:online_travel_agent/services/connectivity_service.dart';

class FakeTravelApiService extends TravelApiService {
  @override
  Future<BootstrapData> fetchBootstrap() async {
    return BootstrapData(
      categories: [],
      destinations: [],
      recommended: [],
      trips: [],
      documents: [],
      hotels: [],
      tourPackages: [],
    );
  }
}

class FakeSyncService implements SyncService {
  @override
  void startPeriodicSync() {}

  @override
  void stopPeriodicSync() {}

  @override
  Future<void> syncAll() async {}

  @override
  void dispose() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeConnectivityService implements ConnectivityService {
  final _controller = StreamController<bool>.broadcast();

  @override
  Stream<bool> get onReconnect => _controller.stream;

  @override
  void dispose() => _controller.close();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('vi'), Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('vi'),
        startLocale: const Locale('vi'),
        child: ProviderScope(
          overrides: [
            apiProvider.overrideWithValue(FakeTravelApiService()),
            syncServiceProvider.overrideWithValue(FakeSyncService()),
            connectivityServiceProvider.overrideWithValue(
              FakeConnectivityService(),
            ),
          ],
          child: const OnlineTravelAgentApp(),
        ),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });
}
