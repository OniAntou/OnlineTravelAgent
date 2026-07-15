import 'package:drift/drift.dart';

class TripScheduleItemsTable extends Table {
  TextColumn get id => text()();
  TextColumn get dayId => text()();
  TextColumn get startTime => text().withDefault(const Constant(''))();
  TextColumn get endTime => text().withDefault(const Constant(''))();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get locationName => text().withDefault(const Constant(''))();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get statusOverride => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get updatedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
