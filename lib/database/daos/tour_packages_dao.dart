import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/tour_packages_table.dart';

part 'tour_packages_dao.g.dart';

@DriftAccessor(tables: [TourPackagesTable])
class TourPackagesDao extends DatabaseAccessor<AppDatabase>
    with _$TourPackagesDaoMixin {
  TourPackagesDao(super.db);

  Future<List<TourPackagesTableData>> getAll() =>
      select(tourPackagesTable).get();

  Future<TourPackagesTableData?> getById(String id) =>
      (select(tourPackagesTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<List<TourPackagesTableData>> search(String query) =>
      (select(tourPackagesTable)
            ..where((t) =>
                t.name.like('%$query%') | t.departure.like('%$query%')))
          .get();

  Future<void> insertAll(List<TourPackagesTableCompanion> items) async {
    await batch((batch) {
      batch.insertAll(tourPackagesTable, items, mode: InsertMode.replace);
    });
  }
}
