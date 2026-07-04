import 'package:drift/drift.dart';

class DocumentsTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get iconName => text().withDefault(const Constant('description'))();
  TextColumn get colorHex => text().withDefault(const Constant('#2196F3'))();

  @override
  Set<Column> get primaryKey => {id};
}
