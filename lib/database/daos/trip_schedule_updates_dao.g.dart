// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_schedule_updates_dao.dart';

// ignore_for_file: type=lint
mixin _$TripScheduleUpdatesDaoMixin on DatabaseAccessor<AppDatabase> {
  $TripScheduleUpdatesTableTable get tripScheduleUpdatesTable =>
      attachedDatabase.tripScheduleUpdatesTable;
  TripScheduleUpdatesDaoManager get managers =>
      TripScheduleUpdatesDaoManager(this);
}

class TripScheduleUpdatesDaoManager {
  final _$TripScheduleUpdatesDaoMixin _db;
  TripScheduleUpdatesDaoManager(this._db);
  $$TripScheduleUpdatesTableTableTableManager get tripScheduleUpdatesTable =>
      $$TripScheduleUpdatesTableTableTableManager(
        _db.attachedDatabase,
        _db.tripScheduleUpdatesTable,
      );
}
