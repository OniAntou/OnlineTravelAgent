import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:online_travel_agent/models/document_item.dart';
import 'package:online_travel_agent/models/trip.dart';
import 'package:online_travel_agent/providers/api_provider.dart';
import 'package:online_travel_agent/providers/app_state_provider.dart';
import 'package:online_travel_agent/providers/profile_provider.dart';
import 'package:online_travel_agent/screens/notifications/notifications_screen.dart';
import 'package:online_travel_agent/services/travel_api_service.dart';

import '../helpers/test_helpers.dart';

BootstrapData _bootstrap({
  List<Trip> trips = const [],
  List<DocumentItem> documents = const [],
}) {
  return BootstrapData(
    categories: [],
    destinations: [],
    recommended: [],
    trips: trips,
    documents: documents,
    hotels: [],
    tourPackages: [],
  );
}

ProviderContainer _makeContainer({
  List<Trip> trips = const [],
  List<DocumentItem> documents = const [],
}) {
  final storage = FakeSecureStorage();
  final api = FakeTravelApiService(secureStorage: storage);
  final container = ProviderContainer(
    overrides: [
      apiProvider.overrideWithValue(api),
      bootstrapProvider.overrideWithValue(
        AsyncData(_bootstrap(trips: trips, documents: documents)),
      ),
    ],
  );
  container.read(documentsProvider.notifier).updateFromBootstrap(documents);
  return container;
}

Widget _buildTestApp(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(home: NotificationsScreen()),
  );
}

void main() {
  testWidgets('shows empty state when there is no trip or document', (
    tester,
  ) async {
    final container = _makeContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(_buildTestApp(container));

    expect(find.text('Chưa có thông báo'), findsOneWidget);
    expect(find.textContaining('mẫu'), findsNothing);
  });

  testWidgets('shows notifications from trip state', (tester) async {
    final container = _makeContainer(
      trips: const [
        Trip(
          id: 'trip-1',
          destination: 'Da Nang',
          location: 'Da Nang',
          date: '10/08/2026',
          guests: '2 Người',
          status: 'Upcoming',
          imagePath: '',
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_buildTestApp(container));

    expect(find.text('Sắp tới: Da Nang'), findsOneWidget);
    expect(find.text('Hoàn thiện hồ sơ du lịch'), findsOneWidget);
    expect(find.textContaining('mẫu'), findsNothing);
  });
}
