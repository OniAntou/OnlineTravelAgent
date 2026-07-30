import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:online_travel_agent/features/destinations/domain/destination.dart';
import 'package:online_travel_agent/features/destinations/application/destination_provider.dart';
import 'package:online_travel_agent/data/services/api_provider.dart';
import 'package:online_travel_agent/app/state/app_state_provider.dart';
import 'package:online_travel_agent/data/services/travel_api_service.dart';
import 'package:online_travel_agent/data/services/sync_service.dart';
import '../../helpers/test_helpers.dart';

class FakeSyncService implements SyncService {
  @override
  Future<void> syncFavorite(String id, bool isFavorite) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class ControlledFavoriteApi extends FakeTravelApiService {
  final requests = <({bool value, Completer<Destination> completer})>[];

  ControlledFavoriteApi({required super.secureStorage});

  @override
  Future<Destination> setFavorite(
    String destinationId,
    bool isFavorite,
  ) {
    final completer = Completer<Destination>();
    requests.add((value: isFavorite, completer: completer));
    return completer.future;
  }
}

ProviderContainer createContainer({FakeTravelApiService? api}) {
  final fakeStorage = FakeSecureStorage();
  final fakeApi = api ?? FakeTravelApiService(secureStorage: fakeStorage);
  final emptyBootstrap = BootstrapData(
    categories: [],
    destinations: [],
    recommended: [],
    trips: [],
    documents: [],
    globalDocuments: [],
    hotels: [],
    tourPackages: [],
  );
  return ProviderContainer(
    overrides: [
      apiProvider.overrideWithValue(fakeApi),
      bootstrapProvider.overrideWithValue(AsyncData(emptyBootstrap)),
      syncServiceProvider.overrideWithValue(FakeSyncService()),
    ],
  );
}

void main() {
  group('DestinationsNotifier', () {
    late ProviderContainer container;

    tearDown(() {
      container.dispose();
    });

    test('initial state is empty destinations', () {
      container = createContainer();
      final state = container.read(destinationsProvider);
      expect(state, isEmpty);
    });

    test('toggleFavorite updates isFavorite optimistically', () async {
      container = createContainer();
      final notifier = container.read(destinationsProvider.notifier);
      notifier.state = [
        const Destination(
          id: '1', name: 'Da Lat', location: 'Lam Dong',
          rating: '4.5', duration: '3 ngày', imagePath: '',
        ),
      ];

      await notifier.toggleFavorite('1');
      final state = container.read(destinationsProvider);
      expect(state.length, 1);
      expect(state.first.isFavorite, true);
    });

    test('toggleFavorite does nothing for non-existent id', () async {
      container = createContainer();
      final notifier = container.read(destinationsProvider.notifier);
      notifier.state = [
        const Destination(
          id: '1', name: 'Da Lat', location: 'Lam Dong',
          rating: '4.5', duration: '3 ngày', imagePath: '',
        ),
      ];

      await notifier.toggleFavorite('nonexistent');
      final state = container.read(destinationsProvider);
      expect(state.length, 1);
      expect(state.first.isFavorite, false);
    });

    test('serializes rapid favorite writes in tap order', () async {
      final api = ControlledFavoriteApi(secureStorage: FakeSecureStorage());
      container = createContainer(api: api);
      final notifier = container.read(destinationsProvider.notifier);
      notifier.state = [
        const Destination(
          id: '1', name: 'Da Lat', location: 'Lam Dong',
          rating: '4.5', duration: '3 ngày', imagePath: '',
        ),
      ];

      final first = notifier.toggleFavorite('1');
      final second = notifier.toggleFavorite('1');
      await Future<void>.delayed(Duration.zero);

      expect(container.read(destinationsProvider).first.isFavorite, false);
      expect(api.requests.map((request) => request.value), [true]);

      api.requests.first.completer.complete(
        const Destination(
          id: '1', name: 'Da Lat', location: 'Lam Dong',
          rating: '4.5', duration: '3 ngày', imagePath: '', isFavorite: true,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(api.requests.map((request) => request.value), [true, false]);

      api.requests.last.completer.complete(
        const Destination(
          id: '1', name: 'Da Lat', location: 'Lam Dong',
          rating: '4.5', duration: '3 ngày', imagePath: '',
        ),
      );
      await Future.wait([first, second]);

      expect(container.read(destinationsProvider).first.isFavorite, false);
    });
  });

  group('Derived Providers', () {
    late ProviderContainer container;

    tearDown(() {
      container.dispose();
    });

    test('favoritesProvider filters favorites', () {
      container = createContainer();
      final notifier = container.read(destinationsProvider.notifier);
      notifier.state = [
        const Destination(
          id: '1', name: 'A', location: 'B',
          rating: '4.5', duration: '3 ngày', imagePath: '',
          isFavorite: true,
        ),
        const Destination(
          id: '2', name: 'C', location: 'D',
          rating: '4.0', duration: '2 ngày', imagePath: '',
        ),
      ];
      final favorites = container.read(favoritesProvider);
      expect(favorites.length, 1);
      expect(favorites.first.name, 'A');
    });

    test('filteredDestinationsProvider filters by search query', () {
      container = createContainer();
      final destNotifier = container.read(destinationsProvider.notifier);
      destNotifier.state = [
        const Destination(
          id: '1', name: 'Da Lat', location: 'Lam Dong',
          rating: '4.5', duration: '3 ngày', imagePath: '',
        ),
        const Destination(
          id: '2', name: 'Ha Noi', location: 'Ha Noi',
          rating: '4.0', duration: '2 ngày', imagePath: '',
        ),
      ];
      container.read(searchQueryProvider.notifier).update('Da Lat');
      final filtered = container.read(filteredDestinationsProvider);
      expect(filtered.length, 1);
      expect(filtered.first.name, 'Da Lat');
    });

    test('filteredDestinationsProvider filters by category', () {
      container = createContainer();
      final destNotifier = container.read(destinationsProvider.notifier);
      destNotifier.state = [
        const Destination(
          id: '1', name: 'A', location: 'B',
          rating: '4.5', duration: '3 ngày', imagePath: '',
          category: 'Ẩm thực',
        ),
        const Destination(
          id: '2', name: 'C', location: 'D',
          rating: '4.0', duration: '2 ngày', imagePath: '',
        ),
      ];
      container.read(selectedCategoryProvider.notifier).update('Ẩm thực');
      final filtered = container.read(filteredDestinationsProvider);
      expect(filtered.length, 1);
      expect(filtered.first.category, 'Ẩm thực');
    });

    test('foodDestinationsProvider filters food category', () {
      container = createContainer();
      final destNotifier = container.read(destinationsProvider.notifier);
      destNotifier.state = [
        const Destination(
          id: '1', name: 'A', location: 'B',
          rating: '4.5', duration: '3 ngày', imagePath: '',
          category: 'Ẩm thực',
        ),
        const Destination(
          id: '2', name: 'C', location: 'D',
          rating: '4.0', duration: '2 ngày', imagePath: '',
        ),
      ];
      final food = container.read(foodDestinationsProvider);
      expect(food.length, 1);
      expect(food.first.category, 'Ẩm thực');
    });
  });

  group('Simple Notifiers', () {
    late ProviderContainer container;

    tearDown(() {
      container.dispose();
    });

    test('searchQueryProvider updates', () {
      container = createContainer();
      expect(container.read(searchQueryProvider), '');
      container.read(searchQueryProvider.notifier).update('test');
      expect(container.read(searchQueryProvider), 'test');
    });

    test('selectedCategoryProvider updates', () {
      container = createContainer();
      expect(container.read(selectedCategoryProvider), 'Tất cả');
      container.read(selectedCategoryProvider.notifier).update('Ẩm thực');
      expect(container.read(selectedCategoryProvider), 'Ẩm thực');
    });

    test('destinationErrorProvider updates', () {
      container = createContainer();
      expect(container.read(destinationErrorProvider), isNull);
      container.read(destinationErrorProvider.notifier).setError('Error!');
      expect(container.read(destinationErrorProvider), 'Error!');
    });
  });
}
