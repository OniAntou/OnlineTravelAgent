// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_schedule_items_dao.dart';

// ignore_for_file: type=lint
mixin _$TripScheduleItemsDaoMixin on DatabaseAccessor<AppDatabase> {
  $TripScheduleItemsTableTable get tripScheduleItemsTable =>
      attachedDatabase.tripScheduleItemsTable;
  TripScheduleItemsDaoManager get managers => TripScheduleItemsDaoManager(this);
}

class TripScheduleItemsDaoManager {
  final _$TripScheduleItemsDaoMixin _db;
  TripScheduleItemsDaoManager(this._db);
  $$TripScheduleItemsTableTableTableManager get tripScheduleItemsTable =>
      $$TripScheduleItemsTableTableTableManager(
        _db.attachedDatabase,
        _db.tripScheduleItemsTable,
      );
}
