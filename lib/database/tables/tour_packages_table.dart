import 'package:drift/drift.dart';

class TourPackagesTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get imagePath => text().withDefault(const Constant(''))();
  TextColumn get duration => text().withDefault(const Constant(''))();
  RealColumn get price => real().withDefault(const Constant(0.0))();
  RealColumn get originalPrice => real().nullable()();
  TextColumn get destinations => text().withDefault(const Constant('[]'))();
  TextColumn get includes => text().withDefault(const Constant('[]'))();
  TextColumn get departure => text().withDefault(const Constant(''))();
  TextColumn get departureDate => text().nullable()();
  BoolColumn get isPopular => boolean().withDefault(const Constant(false))();
  BoolColumn get includesGuide => boolean().withDefault(const Constant(true))();
  RealColumn get guideFee => real().withDefault(const Constant(50.0))();

  @override
  Set<Column> get primaryKey => {id};
}
