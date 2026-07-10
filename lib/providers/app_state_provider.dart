import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../services/sync_service.dart';
import '../services/travel_api_service.dart';
import 'api_provider.dart';
import 'auth_provider.dart';
import 'profile_provider.dart';

final bootstrapProvider = FutureProvider<BootstrapData>((ref) async {
  final api = ref.watch(apiProvider);
  final syncService = ref.watch(syncServiceProvider);
  // Watch token to trigger refetch on login/logout
  final token = ref.watch(authProvider.select((state) => state.token));
  final isLoggedIn = token != null && token.isNotEmpty;

  // Load from SQLite first (offline-first)
  final cached = await syncService.loadBootstrapFromSQLite();
  final scopedCached = isLoggedIn ? cached : _withoutUserOwnedData(cached);

  // Then fetch fresh data from API in background
  try {
    final fresh = await api.fetchBootstrap();
    // Sync to SQLite for next launch
    await syncService.syncAll();
    return fresh;
  } catch (error, stackTrace) {
    // API failed, log error and use cached data
    debugPrint('Failed to fetch bootstrap data: $error\n$stackTrace');
    return scopedCached;
  }
});

BootstrapData _withoutUserOwnedData(BootstrapData data) {
  return BootstrapData(
    categories: data.categories,
    destinations: data.destinations
        .map((destination) => destination.copyWith(isFavorite: false))
        .toList(growable: false),
    recommended: data.recommended
        .map((destination) => destination.copyWith(isFavorite: false))
        .toList(growable: false),
    trips: const [],
    documents: const [],
    hotels: data.hotels,
    tourPackages: data.tourPackages,
    flights: data.flights,
  );
}

// Sync bootstrap data to documents provider
final bootstrapSyncProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<BootstrapData>>(bootstrapProvider, (previous, next) {
    final data = next.value;
    if (data != null) {
      ref.read(documentsProvider.notifier).updateFromBootstrap(data.documents);
    }
  });
});

// A provider for the categories list (static from bootstrap)
final categoriesProvider = Provider<List<String>>((ref) {
  final bootstrap = ref.watch(bootstrapProvider).value;
  if (bootstrap == null || bootstrap.categories.isEmpty) {
    return AppConstants.defaultCategories;
  }

  // Replicate the filtering logic from the old travel_provider
  final remaining = bootstrap.categories
      .where((c) => !AppConstants.hiddenCategories.contains(c))
      .toSet();

  final result = <String>[];
  for (final category in AppConstants.defaultCategories) {
    if (remaining.remove(category)) {
      result.add(category);
    }
  }
  result.addAll(remaining);
  return result;
});
