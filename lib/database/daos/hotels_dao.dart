import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/hotels_table.dart';
import '../tables/rooms_table.dart';

part 'hotels_dao.g.dart';

@DriftAccessor(tables: [HotelsTable, RoomsTable])
class HotelsDao extends DatabaseAccessor<AppDatabase> with _$HotelsDaoMixin {
  HotelsDao(super.db);

  Future<List<HotelsTableData>> getAll() => select(hotelsTable).get();

  Future<HotelsTableData?> getById(String id) =>
      (select(hotelsTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<List<HotelsTableData>> search(String query) =>
      (select(hotelsTable)
            ..where((t) =>
                t.name.like('%$query%') | t.location.like('%$query%')))
          .get();

  Future<List<RoomsTableData>> getRoomsByHotel(String hotelId) =>
      (select(roomsTable)..where((t) => t.hotelId.equals(hotelId))).get();

  Future<void> insertAll(List<HotelsTableCompanion> hotels, List<RoomsTableCompanion> rooms) async {
    await batch((batch) {
      batch.insertAll(hotelsTable, hotels, mode: InsertMode.replace);
    });
    await batch((batch) {
      batch.insertAll(roomsTable, rooms, mode: InsertMode.replace);
    });
  }
}
