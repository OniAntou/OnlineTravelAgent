// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_queue_dao.dart';

// ignore_for_file: type=lint
mixin _$OfflineQueueDaoMixin on DatabaseAccessor<AppDatabase> {
  $OfflineQueueTableTable get offlineQueueTable =>
      attachedDatabase.offlineQueueTable;
  OfflineQueueDaoManager get managers => OfflineQueueDaoManager(this);
}

class OfflineQueueDaoManager {
  final _$OfflineQueueDaoMixin _db;
  OfflineQueueDaoManager(this._db);
  $$OfflineQueueTableTableTableManager get offlineQueueTable =>
      $$OfflineQueueTableTableTableManager(
        _db.attachedDatabase,
        _db.offlineQueueTable,
      );
}
