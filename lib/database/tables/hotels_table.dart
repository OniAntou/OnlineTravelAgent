import 'package:drift/drift.dart';

class HotelsTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get location => text()();
  RealColumn get latitude => real().withDefault(const Constant(0.0))();
  RealColumn get longitude => real().withDefault(const Constant(0.0))();
  TextColumn get rating => text().withDefault(const Constant('0'))();
  TextColumn get imagePath => text().withDefault(const Constant(''))();
  TextColumn get description => text().withDefault(const Constant(''))();
  RealColumn get priceFrom => real().withDefault(const Constant(0.0))();
  TextColumn get address => text().withDefault(const Constant(''))();
  TextColumn get amenities => text().withDefault(const Constant('[]'))();

  @override
  Set<Column> get primaryKey => {id};
}
