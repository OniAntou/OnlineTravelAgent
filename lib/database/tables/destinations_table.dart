import 'package:drift/drift.dart';

class DestinationsTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get location => text()();
  TextColumn get rating => text().withDefault(const Constant('0'))();
  TextColumn get duration => text().withDefault(const Constant(''))();
  TextColumn get imagePath => text().withDefault(const Constant(''))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get price => text().withDefault(const Constant('0'))();
  TextColumn get reviewsCount => text().withDefault(const Constant('0'))();
  TextColumn get category => text().withDefault(const Constant('Địa điểm'))();
  RealColumn get latitude => real().withDefault(const Constant(0.0))();
  RealColumn get longitude => real().withDefault(const Constant(0.0))();
  BoolColumn get isRecommended => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
