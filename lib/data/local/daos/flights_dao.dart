import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/flights_table.dart';

part 'flights_dao.g.dart';

@DriftAccessor(tables: [FlightsTable])
class FlightsDao extends DatabaseAccessor<AppDatabase> with _$FlightsDaoMixin {
  FlightsDao(super.db);

  Future<List<FlightsTableData>> getAll() => select(flightsTable).get();

  Future<List<FlightsTableData>> search({String? departure, String? arrival}) {
    final query = select(flightsTable);
    if (departure != null && departure.isNotEmpty) {
      query.where((t) => t.departure.equals(departure));
    }
    if (arrival != null && arrival.isNotEmpty) {
      query.where((t) => t.arrival.equals(arrival));
    }
    return query.get();
  }

  Future<void> insertAll(List<FlightsTableCompanion> flights) async {
    await batch((batch) {
      batch.insertAll(flightsTable, flights, mode: InsertMode.replace);
    });
  }
}
