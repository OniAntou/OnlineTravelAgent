// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trips_dao.dart';

// ignore_for_file: type=lint
mixin _$TripsDaoMixin on DatabaseAccessor<AppDatabase> {
  $TripsTableTable get tripsTable => attachedDatabase.tripsTable;
  TripsDaoManager get managers => TripsDaoManager(this);
}

class TripsDaoManager {
  final _$TripsDaoMixin _db;
  TripsDaoManager(this._db);
  $$TripsTableTableTableManager get tripsTable =>
      $$TripsTableTableTableManager(_db.attachedDatabase, _db.tripsTable);
}
