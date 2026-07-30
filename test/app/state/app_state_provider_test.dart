import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:online_travel_agent/app/state/app_state_provider.dart';
import 'package:online_travel_agent/data/local/app_database.dart';
import 'package:online_travel_agent/data/services/api_provider.dart';
import 'package:online_travel_agent/data/services/sync_service.dart';
import 'package:online_travel_agent/data/services/travel_api_service.dart';
import 'package:online_travel_agent/features/destinations/domain/destination.dart';

import '../../helpers/test_helpers.dart';

class _CountingBootstrapApi extends FakeTravelApiService {
  _CountingBootstrapApi({required super.secureStorage, super.bootstrapData});

  int bootstrapFetchCount = 0;

  @override
  Future<BootstrapData> fetchBootstrap() async {
    bootstrapFetchCount += 1;
    return super.fetchBootstrap();
  }
}

void main() {
  test(
    'bootstrap provider fetches once and persists that exact payload',
    () async {
      final db = AppDatabase.test(NativeDatabase.memory());
      final api = _CountingBootstrapApi(
        secureStorage: FakeSecureStorage(),
        bootstrapData: BootstrapData(
          categories: const ['Popular'],
          destinations: const [
            Destination(
              id: 'destination-1',
              name: 'Da Lat',
              location: 'Lam Dong',
              rating: '4.5',
              duration: '3 days',
              imagePath: '',
            ),
          ],
          recommended: const [],
          trips: const [],
          documents: const [],
          globalDocuments: const [],
          hotels: const [],
          tourPackages: const [],
        ),
      );
      final container = ProviderContainer(
        overrides: [
          apiProvider.overrideWithValue(api),
          syncServiceProvider.overrideWith((ref) => SyncService(ref, db: db)),
        ],
      );

      addTearDown(() async {
        container.dispose();
        await db.close();
      });

      final bootstrap = await container.read(bootstrapProvider.future);

      expect(api.bootstrapFetchCount, 1);
      expect(bootstrap.destinations.single.id, 'destination-1');
      expect((await db.destinationsDao.getAll()).single.id, 'destination-1');
    },
  );
}
