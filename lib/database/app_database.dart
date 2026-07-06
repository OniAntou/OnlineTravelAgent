import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/destinations_table.dart';
import 'tables/categories_table.dart';
import 'tables/hotels_table.dart';
import 'tables/rooms_table.dart';
import 'tables/tour_packages_table.dart';
import 'tables/trips_table.dart';
import 'tables/trip_schedule_days_table.dart';
import 'tables/trip_schedule_items_table.dart';
import 'tables/trip_schedule_updates_table.dart';
import 'tables/reviews_table.dart';
import 'tables/documents_table.dart';
import 'daos/destinations_dao.dart';
import 'daos/categories_dao.dart';
import 'daos/hotels_dao.dart';
import 'daos/rooms_dao.dart';
import 'daos/tour_packages_dao.dart';
import 'daos/trips_dao.dart';
import 'daos/trip_schedule_days_dao.dart';
import 'daos/trip_schedule_items_dao.dart';
import 'daos/trip_schedule_updates_dao.dart';
import 'daos/reviews_dao.dart';
import 'daos/documents_dao.dart';
import 'tables/offline_queue_table.dart';
import 'daos/offline_queue_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    DestinationsTable,
    CategoriesTable,
    HotelsTable,
    RoomsTable,
    TourPackagesTable,
    TripsTable,
    TripScheduleDaysTable,
    TripScheduleItemsTable,
    TripScheduleUpdatesTable,
    ReviewsTable,
    DocumentsTable,
    OfflineQueueTable,
  ],
  daos: [
    DestinationsDao,
    CategoriesDao,
    HotelsDao,
    RoomsDao,
    TourPackagesDao,
    TripsDao,
    TripScheduleDaysDao,
    TripScheduleItemsDao,
    TripScheduleUpdatesDao,
    ReviewsDao,
    DocumentsDao,
    OfflineQueueDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.test(super.executor);

  static AppDatabase? _instance;
  factory AppDatabase.instance() => _instance ??= AppDatabase();

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 3) {
        await m.createTable(offlineQueueTable);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'travel_agent.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
