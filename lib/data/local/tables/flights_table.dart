import 'package:drift/drift.dart';

class FlightsTable extends Table {
  TextColumn get id => text()();
  TextColumn get airline => text()();
  TextColumn get airlineLogo => text().withDefault(const Constant(''))();
  TextColumn get departure => text()();
  TextColumn get arrival => text()();
  TextColumn get departureTime => text().withDefault(const Constant(''))();
  TextColumn get arrivalTime => text().withDefault(const Constant(''))();
  IntColumn get price => integer().withDefault(const Constant(0))();
  TextColumn get duration => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}
