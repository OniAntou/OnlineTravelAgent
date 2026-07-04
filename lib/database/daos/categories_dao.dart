import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/categories_table.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [CategoriesTable])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  Future<List<CategoriesTableData>> getAll() => select(categoriesTable).get();

  Future<void> insertAll(List<CategoriesTableCompanion> items) async {
    await batch((batch) {
      batch.insertAll(categoriesTable, items, mode: InsertMode.replace);
    });
  }
}
