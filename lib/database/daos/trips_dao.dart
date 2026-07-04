import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/trips_table.dart';

part 'trips_dao.g.dart';

@DriftAccessor(tables: [TripsTable])
class TripsDao extends DatabaseAccessor<AppDatabase> with _$TripsDaoMixin {
  TripsDao(super.db);

  Future<List<TripsTableData>> getAll() =>
      (select(tripsTable)..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Future<List<TripsTableData>> getOngoing() {
    final now = DateTime.now().toIso8601String().substring(0, 10);
    return (select(tripsTable)
          ..where((t) =>
              t.status.equals('ongoing') &
              t.date.isSmallerOrEqualValue(now)))
        .get();
  }

  Future<List<TripsTableData>> getUpcoming() {
    final now = DateTime.now().toIso8601String().substring(0, 10);
    return (select(tripsTable)
          ..where((t) =>
              t.isUpcoming.equals(true) &
              t.date.isBiggerThanValue(now)))
        .get();
  }

  Future<List<TripsTableData>> getHistory() {
    final now = DateTime.now().toIso8601String().substring(0, 10);
    return (select(tripsTable)
          ..where((t) =>
              t.status.equals('completed') |
              (t.date.isSmallerThanValue(now) & t.isUpcoming.equals(false))))
        .get();
  }

  Future<TripsTableData?> getById(String id) =>
      (select(tripsTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<void> insertTrip(TripsTableCompanion trip) async {
    await into(tripsTable).insertOnConflictUpdate(trip);
  }

  Future<void> updateStatus(String id, String status) async {
    (update(tripsTable)..where((t) => t.id.equals(id))).write(
      TripsTableCompanion(
        status: Value(status),
      ),
    );
  }

  Future<void> insertAll(List<TripsTableCompanion> items) async {
    await batch((batch) {
      batch.insertAll(tripsTable, items, mode: InsertMode.replace);
    });
  }
}
