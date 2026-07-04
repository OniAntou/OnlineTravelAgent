// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hotels_dao.dart';

// ignore_for_file: type=lint
mixin _$HotelsDaoMixin on DatabaseAccessor<AppDatabase> {
  $HotelsTableTable get hotelsTable => attachedDatabase.hotelsTable;
  $RoomsTableTable get roomsTable => attachedDatabase.roomsTable;
  HotelsDaoManager get managers => HotelsDaoManager(this);
}

class HotelsDaoManager {
  final _$HotelsDaoMixin _db;
  HotelsDaoManager(this._db);
  $$HotelsTableTableTableManager get hotelsTable =>
      $$HotelsTableTableTableManager(_db.attachedDatabase, _db.hotelsTable);
  $$RoomsTableTableTableManager get roomsTable =>
      $$RoomsTableTableTableManager(_db.attachedDatabase, _db.roomsTable);
}
