import 'package:drift/drift.dart';

class ReviewsTable extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get userName => text().withDefault(const Constant(''))();
  TextColumn get targetType => text()();
  TextColumn get targetId => text()();
  IntColumn get rating => integer().withDefault(const Constant(5))();
  TextColumn get comment => text().withDefault(const Constant(''))();
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}
