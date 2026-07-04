// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_schedule_days_dao.dart';

// ignore_for_file: type=lint
mixin _$TripScheduleDaysDaoMixin on DatabaseAccessor<AppDatabase> {
  $TripScheduleDaysTableTable get tripScheduleDaysTable =>
      attachedDatabase.tripScheduleDaysTable;
  TripScheduleDaysDaoManager get managers => TripScheduleDaysDaoManager(this);
}

class TripScheduleDaysDaoManager {
  final _$TripScheduleDaysDaoMixin _db;
  TripScheduleDaysDaoManager(this._db);
  $$TripScheduleDaysTableTableTableManager get tripScheduleDaysTable =>
      $$TripScheduleDaysTableTableTableManager(
        _db.attachedDatabase,
        _db.tripScheduleDaysTable,
      );
}
