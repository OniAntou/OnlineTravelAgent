import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/destinations_table.dart';

part 'destinations_dao.g.dart';

@DriftAccessor(tables: [DestinationsTable])
class DestinationsDao extends DatabaseAccessor<AppDatabase>
    with _$DestinationsDaoMixin {
  DestinationsDao(super.db);

  Future<List<DestinationsTableData>> getAll() =>
      select(destinationsTable).get();

  Future<List<DestinationsTableData>> getRecommended() =>
      (select(destinationsTable)..where((t) => t.isRecommended.equals(true)))
          .get();

  Future<List<DestinationsTableData>> getByCategory(String category) =>
      (select(destinationsTable)
            ..where((t) => t.category.equals(category)))
          .get();

  Future<List<DestinationsTableData>> search(String query) =>
      (select(destinationsTable)
            ..where((t) =>
                t.name.like('%$query%') | t.location.like('%$query%')))
          .get();

  Future<DestinationsTableData?> getById(String id) =>
      (select(destinationsTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<void> insertAll(List<DestinationsTableCompanion> items) async {
    await batch((batch) {
      batch.insertAll(destinationsTable, items, mode: InsertMode.replace);
    });
  }

  Future<void> toggleFavorite(String id) async {
    final dest = await getById(id);
    if (dest != null) {
      (update(destinationsTable)..where((t) => t.id.equals(id))).write(
        DestinationsTableCompanion(
          isFavorite: Value(!dest.isFavorite),
        ),
      );
    }
  }

  Future<void> setFavorite(String id, bool isFavorite) async {
    (update(destinationsTable)..where((t) => t.id.equals(id))).write(
      DestinationsTableCompanion(
        isFavorite: Value(isFavorite),
      ),
    );
  }
}
