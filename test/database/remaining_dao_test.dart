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

  group('RoomsDao', () {
    test('getByHotelId returns rooms for specific hotel', () async {
      // Insert hotels first (foreign key)
      await db.hotelsDao.insertAll(
        [
          HotelsTableCompanion.insert(
            id: 'h1', name: 'Hotel A', location: 'Da Nang',
            latitude: const Value(16.0),
            longitude: const Value(108.0),
          ),
        ],
        [],
      );

      // Insert rooms via hotelsDao
      await db.hotelsDao.insertAll(
        [
          HotelsTableCompanion.insert(
            id: 'h1', name: 'Hotel A', location: 'Da Nang',
            latitude: const Value(16.0),
            longitude: const Value(108.0),
          ),
        ],
        [
          RoomsTableCompanion.insert(
            id: 'r1', hotelId: 'h1', name: 'Deluxe',
            price: const Value(2000000.0),
            capacity: const Value(2),
          ),
          RoomsTableCompanion.insert(
            id: 'r2', hotelId: 'h1', name: 'Standard',
            price: const Value(1000000.0),
            capacity: const Value(1),
          ),
          RoomsTableCompanion.insert(
            id: 'r3', hotelId: 'h2', name: 'Suite',
          ),
        ],
      );

      final rooms = await db.roomsDao.getByHotelId('h1');
      expect(rooms.length, 2);
      expect(rooms.any((r) => r.name == 'Deluxe'), true);
      expect(rooms.any((r) => r.name == 'Standard'), true);
    });

    test('getById returns specific room', () async {
      await db.hotelsDao.insertAll(
        [
          HotelsTableCompanion.insert(
            id: 'h1', name: 'Hotel A', location: 'X',
            latitude: const Value(0), longitude: const Value(0),
          ),
        ],
        [
          RoomsTableCompanion.insert(id: 'r1', hotelId: 'h1', name: 'Deluxe'),
        ],
      );

      final room = await db.roomsDao.getById('r1');
      expect(room, isNotNull);
      expect(room!.name, 'Deluxe');
    });

    test('getById returns null for nonexistent', () async {
      final room = await db.roomsDao.getById('nonexistent');
      expect(room, isNull);
    });
  });

  group('ReviewsDao', () {
    test('insertReview and getByTarget', () async {
      await db.reviewsDao.insertReview(ReviewsTableCompanion.insert(
        id: 'rev1',
        userId: 'u1',
        userName: const Value('Test User'),
        targetType: 'destination',
        targetId: 'd1',
        rating: const Value(5),
        comment: const Value('Great!'),
        createdAt: '2026-07-01T10:00:00.000Z',
      ));

      await db.reviewsDao.insertReview(ReviewsTableCompanion.insert(
        id: 'rev2',
        userId: 'u2',
        targetType: 'destination',
        targetId: 'd2',
        createdAt: '2026-07-02T10:00:00.000Z',
      ));

      final reviews = await db.reviewsDao.getByTarget('destination', 'd1');
      expect(reviews.length, 1);
      expect(reviews.first.userName, 'Test User');
    });

    test('deleteById removes review', () async {
      await db.reviewsDao.insertReview(ReviewsTableCompanion.insert(
        id: 'rev1', userId: 'u1', targetType: 'hotel',
        targetId: 'h1', createdAt: '2026-07-01T10:00:00.000Z',
      ));

      await db.reviewsDao.deleteById('rev1');
      final reviews = await db.reviewsDao.getByTarget('hotel', 'h1');
      expect(reviews, isEmpty);
    });

    test('insertReview upserts on conflict', () async {
      await db.reviewsDao.insertReview(ReviewsTableCompanion.insert(
        id: 'rev1', userId: 'u1', targetType: 'hotel',
        targetId: 'h1', rating: const Value(3),
        createdAt: '2026-07-01T10:00:00.000Z',
      ));
      await db.reviewsDao.insertReview(ReviewsTableCompanion.insert(
        id: 'rev1', userId: 'u1', targetType: 'hotel',
        targetId: 'h1', rating: const Value(5),
        createdAt: '2026-07-01T10:00:00.000Z',
      ));

      final reviews = await db.reviewsDao.getByTarget('hotel', 'h1');
      expect(reviews.length, 1);
      expect(reviews.first.rating, 5);
    });
  });

  group('TripScheduleDaysDao', () {
    test('insertAll and getByTripId ordered by dayNumber', () async {
      await db.tripScheduleDaysDao.insertAll([
        TripScheduleDaysTableCompanion.insert(
          id: 'day2', tripId: 't1', dayNumber: const Value(2),
        ),
        TripScheduleDaysTableCompanion.insert(
          id: 'day1', tripId: 't1', dayNumber: const Value(1),
        ),
      ]);

      final days = await db.tripScheduleDaysDao.getByTripId('t1');
      expect(days.length, 2);
      expect(days.first.dayNumber, 1);
      expect(days.last.dayNumber, 2);
    });

    test('deleteByTripId removes all days for trip', () async {
      await db.tripScheduleDaysDao.insertAll([
        TripScheduleDaysTableCompanion.insert(
          id: 'day1', tripId: 't1', dayNumber: const Value(1),
        ),
        TripScheduleDaysTableCompanion.insert(
          id: 'day2', tripId: 't2', dayNumber: const Value(1),
        ),
      ]);

      await db.tripScheduleDaysDao.deleteByTripId('t1');
      final days = await db.tripScheduleDaysDao.getByTripId('t1');
      expect(days, isEmpty);

      final otherDays = await db.tripScheduleDaysDao.getByTripId('t2');
      expect(otherDays.length, 1);
    });
  });

  group('TripScheduleItemsDao', () {
    test('getByDayId ordered by sortOrder', () async {
      await db.tripScheduleDaysDao.insertAll([
        TripScheduleDaysTableCompanion.insert(
          id: 'day1', tripId: 't1', dayNumber: const Value(1),
        ),
      ]);

      await db.tripScheduleItemsDao.insertAll([
        TripScheduleItemsTableCompanion.insert(
          id: 'item2', dayId: 'day1', title: const Value('B'),
          sortOrder: const Value(2),
        ),
        TripScheduleItemsTableCompanion.insert(
          id: 'item1', dayId: 'day1', title: const Value('A'),
          sortOrder: const Value(1),
        ),
      ]);

      final items = await db.tripScheduleItemsDao.getByDayId('day1');
      expect(items.length, 2);
      expect(items.first.title, 'A');
      expect(items.last.title, 'B');
    });

    test('updateItem changes statusOverride and note', () async {
      await db.tripScheduleDaysDao.insertAll([
        TripScheduleDaysTableCompanion.insert(
          id: 'day1', tripId: 't1', dayNumber: const Value(1),
        ),
      ]);
      await db.tripScheduleItemsDao.insertAll([
        TripScheduleItemsTableCompanion.insert(
          id: 'item1', dayId: 'day1', title: const Value('Activity'),
        ),
      ]);

      await db.tripScheduleItemsDao.updateItem(
        'item1',
        statusOverride: 'completed',
        note: 'Done!',
      );

      final item = (await db.tripScheduleItemsDao.getByDayId('day1')).first;
      expect(item.statusOverride, 'completed');
      expect(item.note, 'Done!');
      expect(item.updatedAt, isNotNull);
    });

    test('deleteByDayId removes items', () async {
      await db.tripScheduleDaysDao.insertAll([
        TripScheduleDaysTableCompanion.insert(
          id: 'day1', tripId: 't1', dayNumber: const Value(1),
        ),
      ]);
      await db.tripScheduleItemsDao.insertAll([
        TripScheduleItemsTableCompanion.insert(
          id: 'item1', dayId: 'day1', title: const Value('A'),
        ),
      ]);

      await db.tripScheduleItemsDao.deleteByDayId('day1');
      final items = await db.tripScheduleItemsDao.getByDayId('day1');
      expect(items, isEmpty);
    });
  });

  group('TripScheduleUpdatesDao', () {
    test('insertAll and getByTripId ordered by createdAt', () async {
      await db.tripScheduleUpdatesDao.insertAll([
        TripScheduleUpdatesTableCompanion.insert(
          id: 'u2', tripId: 't1',
          message: 'Second',
          createdAt: '2026-07-02T10:00:00.000Z',
        ),
        TripScheduleUpdatesTableCompanion.insert(
          id: 'u1', tripId: 't1',
          message: 'First',
          createdAt: '2026-07-01T10:00:00.000Z',
        ),
      ]);

      final updates = await db.tripScheduleUpdatesDao.getByTripId('t1');
      expect(updates.length, 2);
      expect(updates.first.message, 'First');
      expect(updates.last.message, 'Second');
    });

    test('deleteByTripId removes updates', () async {
      await db.tripScheduleUpdatesDao.insertAll([
        TripScheduleUpdatesTableCompanion.insert(
          id: 'u1', tripId: 't1', message: 'A',
          createdAt: '2026-07-01T10:00:00.000Z',
        ),
        TripScheduleUpdatesTableCompanion.insert(
          id: 'u2', tripId: 't2', message: 'B',
          createdAt: '2026-07-01T10:00:00.000Z',
        ),
      ]);

      await db.tripScheduleUpdatesDao.deleteByTripId('t1');
      expect(await db.tripScheduleUpdatesDao.getByTripId('t1'), isEmpty);
      expect((await db.tripScheduleUpdatesDao.getByTripId('t2')).length, 1);
    });
  });
}
