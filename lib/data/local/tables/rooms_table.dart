import 'package:drift/drift.dart';

class RoomsTable extends Table {
  TextColumn get id => text()();
  TextColumn get hotelId => text()();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  RealColumn get price => real().withDefault(const Constant(0.0))();
  IntColumn get capacity => integer().withDefault(const Constant(1))();
  TextColumn get imagePath => text().withDefault(const Constant(''))();
  TextColumn get amenities => text().withDefault(const Constant('[]'))();

  @override
  Set<Column> get primaryKey => {id};
}
