// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flights_dao.dart';

// ignore_for_file: type=lint
mixin _$FlightsDaoMixin on DatabaseAccessor<AppDatabase> {
  $FlightsTableTable get flightsTable => attachedDatabase.flightsTable;
  FlightsDaoManager get managers => FlightsDaoManager(this);
}

class FlightsDaoManager {
  final _$FlightsDaoMixin _db;
  FlightsDaoManager(this._db);
  $$FlightsTableTableTableManager get flightsTable =>
      $$FlightsTableTableTableManager(_db.attachedDatabase, _db.flightsTable);
}
