import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:online_travel_agent/database/app_database.dart';
import 'package:online_travel_agent/models/destination.dart';
import 'package:online_travel_agent/models/hotel.dart';
import 'package:online_travel_agent/models/tour_package.dart';
import 'package:online_travel_agent/models/document_item.dart';
import 'package:online_travel_agent/models/trip.dart';
import 'package:online_travel_agent/providers/api_provider.dart';
import 'package:online_travel_agent/services/sync_service.dart';
import 'package:online_travel_agent/services/travel_api_service.dart';

import '../helpers/test_helpers.dart';

void main() {
  late AppDatabase db;
  late FakeTravelApiService fakeApi;
  late ProviderContainer container;
  late SyncService syncService;

  setUp(() {
    db = AppDatabase.test(NativeDatabase.memory());
    fakeApi = FakeTravelApiService(
      secureStorage: FakeSecureStorage(),
      bootstrapData: BootstrapData(
        categories: ['Ẩm thực', 'Địa điểm'],
        destinations: [
          const Destination(
            id: 'd1', name: 'Da Lat', location: 'Lam Dong',
            rating: '4.5', duration: '3 ngày', imagePath: '',
            description: 'Thành phố ngàn hoa', price: '500000',
            reviewsCount: '120',
          ),
        ],
        recommended: [
          const Destination(
            id: 'd1', name: 'Da Lat', location: 'Lam Dong',
            rating: '4.5', duration: '3 ngày', imagePath: '',
          ),
        ],
        trips: [
          const Trip(
            id: 't1', destination: 'Da Lat', location: 'Lam Dong',
            date: '2026-08-01', guests: '2', status: 'Upcoming',
            imagePath: '',
          ),
        ],
        documents: [
          const DocumentItem(
            id: 'doc1', title: 'Passport',
            description: '', icon: Icons.description,
            color: Colors.blue, iconName: 'description', colorHex: '#2196F3',
          ),
        ],
        hotels: [
          const Hotel(
            id: 'h1', name: 'Luxury Hotel', location: 'Da Nang',
            latitude: 16.05, longitude: 108.22, rating: '4.8',
            imagePath: '', description: 'Nice hotel',
            address: '123 Beach', priceFrom: 1200000,
            amenities: [],
          ),
        ],
        tourPackages: [
          const TourPackage(
            id: 'tp1', name: 'Ha Giang Loop', duration: '4N3Đ',
            price: 4500000, destinations: ['Ha Giang'],
            includes: ['Xe máy'], departure: 'Ha Noi',
            description: '', imagePath: '',
          ),
        ],
      ),
    );

    container = ProviderContainer(
      overrides: [
        apiProvider.overrideWithValue(fakeApi),
        syncServiceProvider.overrideWith((ref) => SyncService(ref, db: db)),
      ],
    );
    syncService = container.read(syncServiceProvider);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('syncAll', () {
    test('syncs all data types to database', () async {
      await syncService.syncAll();

      final destinations = await db.destinationsDao.getAll();
      expect(destinations.length, 1);
      expect(destinations.first.name, 'Da Lat');

      final categories = await db.categoriesDao.getAll();
      expect(categories.length, 2);

      final hotels = await db.hotelsDao.getAll();
      expect(hotels.length, 1);
      expect(hotels.first.name, 'Luxury Hotel');

      final tours = await db.tourPackagesDao.getAll();
      expect(tours.length, 1);
      expect(tours.first.name, 'Ha Giang Loop');

      final docs = await db.documentsDao.getAll();
      expect(docs.length, 1);
      expect(docs.first.title, 'Passport');

      final trips = await db.tripsDao.getAll();
      expect(trips.length, 1);
      expect(trips.first.destination, 'Da Lat');
    });

    test('sets isRecommended for destinations in recommended list', () async {
      await syncService.syncAll();

      final dest = await db.destinationsDao.getById('d1');
      expect(dest!.isRecommended, true);
    });

    test('syncs empty data without error', () async {
      final emptyApi = FakeTravelApiService(
        secureStorage: FakeSecureStorage(),
        bootstrapData: BootstrapData(
          categories: [], destinations: [], recommended: [],
          trips: [], documents: [], hotels: [], tourPackages: [],
        ),
      );
      final c = ProviderContainer(overrides: [
        apiProvider.overrideWithValue(emptyApi),
        syncServiceProvider.overrideWith((ref) => SyncService(ref, db: db)),
      ]);
      await c.read(syncServiceProvider).syncAll();

      expect(await db.destinationsDao.getAll(), isEmpty);
      expect(await db.categoriesDao.getAll(), isEmpty);
      expect(await db.hotelsDao.getAll(), isEmpty);
      expect(await db.tourPackagesDao.getAll(), isEmpty);
      expect(await db.documentsDao.getAll(), isEmpty);
      expect(await db.tripsDao.getAll(), isEmpty);

      c.dispose();
    });

    test('handles API error gracefully', () async {
      final errorApi = _ErrorApiService();
      final c = ProviderContainer(overrides: [
        apiProvider.overrideWithValue(errorApi),
        syncServiceProvider.overrideWith((ref) => SyncService(ref, db: db)),
      ]);

      await c.read(syncServiceProvider).syncAll();
      c.dispose();
    });

    test('prevents concurrent syncs', () async {
      var callCount = 0;
      final slowApi = _SlowApiService(() => callCount++);
      final c = ProviderContainer(overrides: [
        apiProvider.overrideWithValue(slowApi),
        syncServiceProvider.overrideWith((ref) => SyncService(ref, db: db)),
      ]);
      final s = c.read(syncServiceProvider);

      final f1 = s.syncAll();
      final f2 = s.syncAll();
      await Future.wait([f1, f2]);

      expect(callCount, 1);
      c.dispose();
    });
  });

  group('periodic sync', () {
    test('startPeriodicSync creates timer', () {
      syncService.startPeriodicSync();
      syncService.stopPeriodicSync();
    });

    test('stopPeriodicSync cancels timer', () {
      syncService.startPeriodicSync();
      syncService.stopPeriodicSync();
      syncService.stopPeriodicSync();
    });
  });

  group('syncFavorite', () {
    test('updates favorite status in database', () async {
      await db.destinationsDao.insertAll([
        DestinationsTableCompanion.insert(id: 'd1', name: 'Da Lat', location: 'Lam Dong'),
      ]);

      await syncService.syncFavorite('d1', true);
      final dest = await db.destinationsDao.getById('d1');
      expect(dest!.isFavorite, true);

      await syncService.syncFavorite('d1', false);
      final updated = await db.destinationsDao.getById('d1');
      expect(updated!.isFavorite, false);
    });
  });

  group('syncTrip', () {
    test('inserts trip to database', () async {
      const trip = Trip(
        id: 't1', destination: 'Da Lat', location: 'Lam Dong',
        date: '2026-08-01', guests: '2', status: 'Upcoming',
        imagePath: '',
      );

      await syncService.syncTrip(trip);
      final trips = await db.tripsDao.getAll();
      expect(trips.length, 1);
      expect(trips.first.destination, 'Da Lat');
    });

    test('updates existing trip on conflict', () async {
      const trip1 = Trip(
        id: 't1', destination: 'Da Lat', location: 'Lam Dong',
        date: '2026-08-01', guests: '2', status: 'Upcoming',
        imagePath: '',
      );
      await syncService.syncTrip(trip1);

      const trip2 = Trip(
        id: 't1', destination: 'Ha Noi', location: 'Ha Noi',
        date: '2026-09-01', guests: '3', status: 'Upcoming',
        imagePath: '',
      );
      await syncService.syncTrip(trip2);

      final trips = await db.tripsDao.getAll();
      expect(trips.length, 1);
      expect(trips.first.destination, 'Ha Noi');
    });
  });

  group('syncTripStatus', () {
    test('updates trip status', () async {
      await db.tripsDao.insertTrip(TripsTableCompanion.insert(
        id: 't1', destination: 'Da Lat',
        location: const Value('Lam Dong'),
        date: const Value('2026-08-01'),
        guests: const Value('2'),
        status: const Value('Upcoming'),
        imagePath: const Value(''),
      ));

      await syncService.syncTripStatus('t1', 'completed');
      final trip = await db.tripsDao.getById('t1');
      expect(trip!.status, 'completed');
    });
  });

  group('dispose', () {
    test('stops periodic sync and closes database', () {
      syncService.startPeriodicSync();
      syncService.dispose();
    });
  });
}

class _ErrorApiService extends FakeTravelApiService {
  _ErrorApiService()
      : super(secureStorage: FakeSecureStorage());

  @override
  Future<BootstrapData> fetchBootstrap() async {
    throw Exception('Network error');
  }
}

class _SlowApiService extends FakeTravelApiService {
  final void Function() onCall;
  _SlowApiService(this.onCall) : super(secureStorage: FakeSecureStorage());

  @override
  Future<BootstrapData> fetchBootstrap() async {
    onCall();
    await Future.delayed(const Duration(milliseconds: 50));
    return super.fetchBootstrap();
  }
}
