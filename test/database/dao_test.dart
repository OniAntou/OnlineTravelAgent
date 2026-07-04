import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:online_travel_agent/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.test(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('DestinationsDao', () {
    test('insertAll and getAll', () async {
      await db.destinationsDao.insertAll([
        DestinationsTableCompanion.insert(id: '1', name: 'Da Lat', location: 'Lam Dong'),
        DestinationsTableCompanion.insert(id: '2', name: 'Ha Noi', location: 'Ha Noi'),
      ]);
      final all = await db.destinationsDao.getAll();
      expect(all.length, 2);
      expect(all.first.name, 'Da Lat');
    });

    test('getById returns correct destination', () async {
      await db.destinationsDao.insertAll([
        DestinationsTableCompanion.insert(id: '1', name: 'Da Lat', location: 'Lam Dong'),
      ]);
      final dest = await db.destinationsDao.getById('1');
      expect(dest, isNotNull);
      expect(dest!.name, 'Da Lat');
    });

    test('getById returns null for nonexistent id', () async {
      final dest = await db.destinationsDao.getById('nonexistent');
      expect(dest, isNull);
    });

    test('setFavorite updates favorite status', () async {
      await db.destinationsDao.insertAll([
        DestinationsTableCompanion.insert(id: '1', name: 'Da Lat', location: 'Lam Dong'),
      ]);
      await db.destinationsDao.setFavorite('1', true);
      final dest = await db.destinationsDao.getById('1');
      expect(dest!.isFavorite, true);

      await db.destinationsDao.setFavorite('1', false);
      final updated = await db.destinationsDao.getById('1');
      expect(updated!.isFavorite, false);
    });

    test('getRecommended filters by isRecommended', () async {
      await db.destinationsDao.insertAll([
        DestinationsTableCompanion.insert(
          id: '1', name: 'Da Lat', location: 'Lam Dong',
          isRecommended: const Value(true),
        ),
        DestinationsTableCompanion.insert(id: '2', name: 'Ha Noi', location: 'Ha Noi'),
      ]);
      final recommended = await db.destinationsDao.getRecommended();
      expect(recommended.length, 1);
      expect(recommended.first.name, 'Da Lat');
    });

    test('search finds by name or location', () async {
      await db.destinationsDao.insertAll([
        DestinationsTableCompanion.insert(id: '1', name: 'Da Lat', location: 'Lam Dong'),
        DestinationsTableCompanion.insert(id: '2', name: 'Ha Noi', location: 'Ha Noi'),
      ]);
      final results = await db.destinationsDao.search('Lat');
      expect(results.length, 1);
      expect(results.first.name, 'Da Lat');
    });

    test('insertAll replaces existing entries', () async {
      await db.destinationsDao.insertAll([
        DestinationsTableCompanion.insert(id: '1', name: 'Old Name', location: 'X'),
      ]);
      await db.destinationsDao.insertAll([
        DestinationsTableCompanion.insert(id: '1', name: 'New Name', location: 'Y'),
      ]);
      final all = await db.destinationsDao.getAll();
      expect(all.length, 1);
      expect(all.first.name, 'New Name');
    });
  });

  group('CategoriesDao', () {
    test('insertAll and getAll', () async {
      await db.categoriesDao.insertAll([
        CategoriesTableCompanion.insert(id: 'cat1', name: const Value('Ẩm thực')),
        CategoriesTableCompanion.insert(id: 'cat2', name: const Value('Địa điểm')),
      ]);
      final all = await db.categoriesDao.getAll();
      expect(all.length, 2);
    });
  });

  group('TripsDao', () {
    test('insertTrip and getAll', () async {
      await db.tripsDao.insertTrip(TripsTableCompanion.insert(
        id: 't1', destination: 'Da Lat',
        location: const Value('Lam Dong'),
        date: const Value('2026-08-01'),
        guests: const Value('2'),
        status: const Value('Upcoming'),
        imagePath: const Value('img.jpg'),
      ));
      final all = await db.tripsDao.getAll();
      expect(all.length, 1);
      expect(all.first.destination, 'Da Lat');
    });

    test('getById returns correct trip', () async {
      await db.tripsDao.insertTrip(TripsTableCompanion.insert(
        id: 't1', destination: 'Da Lat',
        location: const Value('Lam Dong'),
        date: const Value('2026-08-01'),
        guests: const Value('2'),
        status: const Value('Upcoming'),
        imagePath: const Value('img.jpg'),
      ));
      final trip = await db.tripsDao.getById('t1');
      expect(trip, isNotNull);
      expect(trip!.destination, 'Da Lat');
    });

    test('updateStatus changes trip status', () async {
      await db.tripsDao.insertTrip(TripsTableCompanion.insert(
        id: 't1', destination: 'Da Lat',
        location: const Value('Lam Dong'),
        date: const Value('2026-08-01'),
        guests: const Value('2'),
        status: const Value('Upcoming'),
        imagePath: const Value('img.jpg'),
      ));
      await db.tripsDao.updateStatus('t1', 'completed');
      final trip = await db.tripsDao.getById('t1');
      expect(trip!.status, 'completed');
    });

    test('insertAll batch inserts', () async {
      await db.tripsDao.insertAll([
        TripsTableCompanion.insert(
          id: 't1', destination: 'Da Lat',
          location: const Value(''), date: const Value(''),
          guests: const Value(''), status: const Value(''),
          imagePath: const Value(''),
        ),
        TripsTableCompanion.insert(
          id: 't2', destination: 'Ha Noi',
          location: const Value(''), date: const Value(''),
          guests: const Value(''), status: const Value(''),
          imagePath: const Value(''),
        ),
      ]);
      final all = await db.tripsDao.getAll();
      expect(all.length, 2);
    });
  });

  group('HotelsDao', () {
    test('insertAll and getAll', () async {
      await db.hotelsDao.insertAll(
        [
          HotelsTableCompanion.insert(
            id: 'h1', name: 'Luxury', location: 'Da Nang',
            latitude: const Value(16.05),
            longitude: const Value(108.22),
          ),
        ],
        [],
      );
      final all = await db.hotelsDao.getAll();
      expect(all.length, 1);
      expect(all.first.name, 'Luxury');
    });
  });

  group('TourPackagesDao', () {
    test('insertAll and getAll', () async {
      await db.tourPackagesDao.insertAll([
        TourPackagesTableCompanion.insert(
          id: 'tp1', name: 'Ha Giang Loop',
          duration: const Value('4N3Đ'),
          price: const Value(4500000),
        ),
      ]);
      final all = await db.tourPackagesDao.getAll();
      expect(all.length, 1);
      expect(all.first.name, 'Ha Giang Loop');
    });
  });

  group('DocumentsDao', () {
    test('insertAll and getAll', () async {
      await db.documentsDao.insertAll([
        DocumentsTableCompanion.insert(
          id: 'd1', title: 'Passport',
        ),
      ]);
      final all = await db.documentsDao.getAll();
      expect(all.length, 1);
      expect(all.first.title, 'Passport');
    });
  });
}
