import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/documents_table.dart';

part 'documents_dao.g.dart';

@DriftAccessor(tables: [DocumentsTable])
class DocumentsDao extends DatabaseAccessor<AppDatabase>
    with _$DocumentsDaoMixin {
  DocumentsDao(super.db);

  Future<List<DocumentsTableData>> getAll() => select(documentsTable).get();

  Future<void> insertAll(List<DocumentsTableCompanion> items) async {
    await batch((batch) {
      batch.insertAll(documentsTable, items, mode: InsertMode.replace);
    });
  }

  Future<void> insertDocument(DocumentsTableCompanion item) async {
    await into(documentsTable).insertOnConflictUpdate(item);
  }

  Future<void> deleteById(String id) async {
    (delete(documentsTable)..where((t) => t.id.equals(id))).go();
  }
}
