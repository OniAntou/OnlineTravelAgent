// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tour_packages_dao.dart';

// ignore_for_file: type=lint
mixin _$TourPackagesDaoMixin on DatabaseAccessor<AppDatabase> {
  $TourPackagesTableTable get tourPackagesTable =>
      attachedDatabase.tourPackagesTable;
  TourPackagesDaoManager get managers => TourPackagesDaoManager(this);
}

class TourPackagesDaoManager {
  final _$TourPackagesDaoMixin _db;
  TourPackagesDaoManager(this._db);
  $$TourPackagesTableTableTableManager get tourPackagesTable =>
      $$TourPackagesTableTableTableManager(
        _db.attachedDatabase,
        _db.tourPackagesTable,
      );
}
