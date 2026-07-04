import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/trip_schedule_items_table.dart';

part 'trip_schedule_items_dao.g.dart';

@DriftAccessor(tables: [TripScheduleItemsTable])
class TripScheduleItemsDao extends DatabaseAccessor<AppDatabase>
    with _$TripScheduleItemsDaoMixin {
  TripScheduleItemsDao(super.db);

  Future<List<TripScheduleItemsTableData>> getByDayId(String dayId) =>
      (select(tripScheduleItemsTable)
            ..where((t) => t.dayId.equals(dayId))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

  Future<void> insertAll(List<TripScheduleItemsTableCompanion> items) async {
    await batch((batch) {
      batch.insertAll(tripScheduleItemsTable, items, mode: InsertMode.replace);
    });
  }

  Future<void> updateItem(String id,
      {String? statusOverride, String? note}) async {
    final companion = TripScheduleItemsTableCompanion(
      statusOverride: Value(statusOverride),
      note: Value(note),
      updatedAt: Value(DateTime.now().toIso8601String()),
    );
    (update(tripScheduleItemsTable)..where((t) => t.id.equals(id)))
        .write(companion);
  }

  Future<void> deleteByDayId(String dayId) async {
    (delete(tripScheduleItemsTable)..where((t) => t.dayId.equals(dayId)))
        .go();
  }
}
