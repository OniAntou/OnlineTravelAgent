import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/trip_schedule_days_table.dart';

part 'trip_schedule_days_dao.g.dart';

@DriftAccessor(tables: [TripScheduleDaysTable])
class TripScheduleDaysDao extends DatabaseAccessor<AppDatabase>
    with _$TripScheduleDaysDaoMixin {
  TripScheduleDaysDao(super.db);

  Future<List<TripScheduleDaysTableData>> getByTripId(String tripId) =>
      (select(tripScheduleDaysTable)
            ..where((t) => t.tripId.equals(tripId))
            ..orderBy([(t) => OrderingTerm.asc(t.dayNumber)]))
          .get();

  Future<void> insertAll(List<TripScheduleDaysTableCompanion> items) async {
    await batch((batch) {
      batch.insertAll(tripScheduleDaysTable, items, mode: InsertMode.replace);
    });
  }

  Future<void> deleteByTripId(String tripId) async {
    (delete(tripScheduleDaysTable)..where((t) => t.tripId.equals(tripId)))
        .go();
  }
}
