import 'package:drift/drift.dart';

class TripScheduleUpdatesTable extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text()();
  TextColumn get message => text()();
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}
