import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/rooms_table.dart';

part 'rooms_dao.g.dart';

@DriftAccessor(tables: [RoomsTable])
class RoomsDao extends DatabaseAccessor<AppDatabase> with _$RoomsDaoMixin {
  RoomsDao(super.db);

  Future<List<RoomsTableData>> getByHotelId(String hotelId) =>
      (select(roomsTable)..where((t) => t.hotelId.equals(hotelId))).get();

  Future<RoomsTableData?> getById(String id) =>
      (select(roomsTable)..where((t) => t.id.equals(id))).getSingleOrNull();
}
