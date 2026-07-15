import 'package:drift/drift.dart';

class CategoriesTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}
