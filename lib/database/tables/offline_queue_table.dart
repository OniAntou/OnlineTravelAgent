import 'package:drift/drift.dart';

@DataClassName('OfflineQueueItem')
class OfflineQueueTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get endpoint => text()();
  TextColumn get method => text()();
  TextColumn get bodyJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
