// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'destinations_dao.dart';

// ignore_for_file: type=lint
mixin _$DestinationsDaoMixin on DatabaseAccessor<AppDatabase> {
  $DestinationsTableTable get destinationsTable =>
      attachedDatabase.destinationsTable;
  DestinationsDaoManager get managers => DestinationsDaoManager(this);
}

class DestinationsDaoManager {
  final _$DestinationsDaoMixin _db;
  DestinationsDaoManager(this._db);
  $$DestinationsTableTableTableManager get destinationsTable =>
      $$DestinationsTableTableTableManager(
        _db.attachedDatabase,
        _db.destinationsTable,
      );
}
