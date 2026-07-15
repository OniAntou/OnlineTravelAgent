import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/destination.dart';
import '../data/services/sync_service.dart';
import '../core/utils/api_exception.dart';
import '../data/services/api_provider.dart';
import '../app/state/app_state_provider.dart';

// 1. Destinations Notifier (Mutable due to favorites)
class DestinationsNotifier extends Notifier<List<Destination>> {
  final Map<String, Future<void>> _favoriteMutationTails = {};
  final Map<String, bool> _confirmedFavoriteValues = {};

  @override
  List<Destination> build() {
    final bootstrap = ref.watch(bootstrapProvider).value;
    return bootstrap?.destinations ?? [];
  }

  Future<void> toggleFavorite(String id) async {
    final index = state.indexWhere((d) => d.id == id);
    if (index == -1) return;

    final current = state[index];
    final newValue = !current.isFavorite;
    _confirmedFavoriteValues.putIfAbsent(id, () => current.isFavorite);

    _setLocalFavorite(id, newValue);

    final previous = _favoriteMutationTails[id] ?? Future<void>.value();
    late final Future<void> mutation;
    mutation = previous.then((_) async {
      try {
        await ref.read(apiProvider).setFavorite(id, newValue);
        _confirmedFavoriteValues[id] = newValue;
      } catch (error) {
        ref
            .read(destinationErrorProvider.notifier)
            .setError(
              error is ApiException
                  ? error.message
                  : getErrorMessage(error),
            );
        if (identical(_favoriteMutationTails[id], mutation)) {
          _setLocalFavorite(
            id,
            _confirmedFavoriteValues[id] ?? current.isFavorite,
          );
        }
      }
    });
    _favoriteMutationTails[id] = mutation;

    await mutation;
    if (identical(_favoriteMutationTails[id], mutation)) {
      _favoriteMutationTails.remove(id);
      _confirmedFavoriteValues.remove(id);
    }
  }

  void _setLocalFavorite(String id, bool value) {
    final index = state.indexWhere((destination) => destination.id == id);
    if (index == -1) return;
    final current = state[index];
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) current.copyWith(isFavorite: value) else state[i],
    ];
    unawaited(ref.read(syncServiceProvider).syncFavorite(id, value));
    ref.read(recommendedProvider.notifier).syncFavorite(id, value);
  }
}

class DestinationErrorNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setError(String? val) => state = val;
}

final destinationErrorProvider =
    NotifierProvider<DestinationErrorNotifier, String?>(
      DestinationErrorNotifier.new,
    );

final destinationsProvider =
    NotifierProvider<DestinationsNotifier, List<Destination>>(
      DestinationsNotifier.new,
    );

// 2. Recommended Destinations
class RecommendedNotifier extends Notifier<List<Destination>> {
  @override
  List<Destination> build() {
    final bootstrap = ref.watch(bootstrapProvider).value;
    return bootstrap?.recommended ?? [];
  }

  void syncFavorite(String id, bool isFavorite) {
    final index = state.indexWhere((d) => d.id == id);
    if (index == -1) return;
    final current = state[index];
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) current.copyWith(isFavorite: isFavorite) else state[i],
    ];
  }
}

final recommendedProvider =
    NotifierProvider<RecommendedNotifier, List<Destination>>(
      RecommendedNotifier.new,
    );

// 3. Search and Category State
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void update(String value) => state = value;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

class SelectedCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'Tất cả';
  void update(String value) => state = value;
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String>(
      SelectedCategoryNotifier.new,
    );

// 4. Derived Providers (Filtered lists)
class SelectedDestinationNotifier extends Notifier<Destination?> {
  @override
  Destination? build() => null;
  void update(Destination? value) => state = value;
}

final selectedDestinationProvider =
    NotifierProvider<SelectedDestinationNotifier, Destination?>(
      SelectedDestinationNotifier.new,
    );

final filteredDestinationsProvider = Provider<List<Destination>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final category = ref.watch(selectedCategoryProvider);
  final destinations = ref.watch(destinationsProvider);

  return destinations.where((d) {
    final matchesSearch =
        query.isEmpty ||
        d.name.toLowerCase().contains(query) ||
        d.location.toLowerCase().contains(query);
    final matchesCategory = category == 'Tất cả' || d.category == category;
    return matchesSearch && matchesCategory;
  }).toList();
});

final filteredRecommendedProvider = Provider<List<Destination>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final category = ref.watch(selectedCategoryProvider);
  final recommended = ref.watch(recommendedProvider);

  return recommended.where((d) {
    final matchesSearch =
        query.isEmpty ||
        d.name.toLowerCase().contains(query) ||
        d.location.toLowerCase().contains(query);
    final matchesCategory = category == 'Tất cả' || d.category == category;
    return matchesSearch && matchesCategory;
  }).toList();
});

final favoritesProvider = Provider<List<Destination>>((ref) {
  final destinations = ref.watch(destinationsProvider);
  return destinations.where((d) => d.isFavorite).toList();
});

final foodDestinationsProvider = Provider<List<Destination>>((ref) {
  final destinations = ref.watch(destinationsProvider);
  return destinations.where((d) => d.category == 'Ẩm thực').toList();
});
