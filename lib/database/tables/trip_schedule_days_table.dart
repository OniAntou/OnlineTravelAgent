import 'package:drift/drift.dart';

class TripScheduleDaysTable extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text()();
  IntColumn get dayNumber => integer().withDefault(const Constant(1))();
  TextColumn get date => text().nullable()();
  TextColumn get title => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}
