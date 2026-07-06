import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/offline_queue_table.dart';

part 'offline_queue_dao.g.dart';

@DriftAccessor(tables: [OfflineQueueTable])
class OfflineQueueDao extends DatabaseAccessor<AppDatabase>
    with _$OfflineQueueDaoMixin {
  OfflineQueueDao(super.db);

  Future<List<OfflineQueueItem>> getAll() => select(offlineQueueTable).get();

  Future<int> insertItem(OfflineQueueTableCompanion item) =>
      into(offlineQueueTable).insert(item);

  Future<void> deleteItem(int id) =>
      (delete(offlineQueueTable)..where((t) => t.id.equals(id))).go();

  Future<void> clearQueue() => delete(offlineQueueTable).go();
}
