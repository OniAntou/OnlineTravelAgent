import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/trip_schedule_updates_table.dart';

part 'trip_schedule_updates_dao.g.dart';

@DriftAccessor(tables: [TripScheduleUpdatesTable])
class TripScheduleUpdatesDao extends DatabaseAccessor<AppDatabase>
    with _$TripScheduleUpdatesDaoMixin {
  TripScheduleUpdatesDao(super.db);

  Future<List<TripScheduleUpdatesTableData>> getByTripId(String tripId) =>
      (select(tripScheduleUpdatesTable)
            ..where((t) => t.tripId.equals(tripId))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

  Future<void> insertAll(List<TripScheduleUpdatesTableCompanion> items) async {
    await batch((batch) {
      batch.insertAll(
        tripScheduleUpdatesTable,
        items,
        mode: InsertMode.replace,
      );
    });
  }

  Future<void> deleteByTripId(String tripId) async {
    await (delete(
      tripScheduleUpdatesTable,
    )..where((t) => t.tripId.equals(tripId))).go();
  }
}
