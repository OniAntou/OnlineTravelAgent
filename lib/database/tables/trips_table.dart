import 'package:drift/drift.dart';

class TripsTable extends Table {
  TextColumn get id => text()();
  TextColumn get destination => text()();
  TextColumn get location => text().withDefault(const Constant(''))();
  TextColumn get date => text().withDefault(const Constant(''))();
  TextColumn get guests => text().withDefault(const Constant('1'))();
  TextColumn get status => text().withDefault(const Constant('upcoming'))();
  TextColumn get imagePath => text().withDefault(const Constant(''))();
  BoolColumn get isUpcoming => boolean().withDefault(const Constant(true))();
  TextColumn get flightId => text().nullable()();
  TextColumn get hotelId => text().nullable()();
  TextColumn get roomId => text().nullable()();
  RealColumn get totalPrice => real().nullable()();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  TextColumn get createdAt => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}
