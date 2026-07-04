import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/destination.dart';
import '../services/sync_service.dart';
import '../utils/api_exception.dart';
import 'api_provider.dart';
import 'app_state_provider.dart';

// 1. Destinations Notifier (Mutable due to favorites)
class DestinationsNotifier extends Notifier<List<Destination>> {
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
    
    // Optimistic update
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) current.copyWith(isFavorite: newValue) else state[i]
    ];
    
    // Sync to SQLite
    ref.read(syncServiceProvider).syncFavorite(id, newValue);
    
    try {
      await ref.read(apiProvider).setFavorite(id, newValue);
      ref.read(recommendedProvider.notifier).syncFavorite(id, newValue);
    } on ApiException catch (e) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index) current else state[i]
      ];
      ref.read(syncServiceProvider).syncFavorite(id, current.isFavorite);
      ref.read(recommendedProvider.notifier).syncFavorite(id, current.isFavorite);
      ref.read(destinationErrorProvider.notifier).setError(e.message);
      rethrow;
    } catch (e) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index) current else state[i]
      ];
      ref.read(syncServiceProvider).syncFavorite(id, current.isFavorite);
      ref.read(recommendedProvider.notifier).syncFavorite(id, current.isFavorite);
      ref.read(destinationErrorProvider.notifier).setError(getErrorMessage(e));
      rethrow;
    }
  }
}

class DestinationErrorNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setError(String? val) => state = val;
}
final destinationErrorProvider = NotifierProvider<DestinationErrorNotifier, String?>(DestinationErrorNotifier.new);

final destinationsProvider = NotifierProvider<DestinationsNotifier, List<Destination>>(DestinationsNotifier.new);

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
        if (i == index) current.copyWith(isFavorite: isFavorite) else state[i]
    ];
  }
}

final recommendedProvider = NotifierProvider<RecommendedNotifier, List<Destination>>(RecommendedNotifier.new);


// 3. Search and Category State
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void update(String value) => state = value;
}
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class SelectedCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'Tất cả';
  void update(String value) => state = value;
}
final selectedCategoryProvider = NotifierProvider<SelectedCategoryNotifier, String>(SelectedCategoryNotifier.new);

// 4. Derived Providers (Filtered lists)
class SelectedDestinationNotifier extends Notifier<Destination?> {
  @override
  Destination? build() => null;
  void update(Destination? value) => state = value;
}
final selectedDestinationProvider = NotifierProvider<SelectedDestinationNotifier, Destination?>(SelectedDestinationNotifier.new);

final filteredDestinationsProvider = Provider<List<Destination>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final category = ref.watch(selectedCategoryProvider);
  final destinations = ref.watch(destinationsProvider);

  return destinations.where((d) {
    final matchesSearch = query.isEmpty || d.name.toLowerCase().contains(query) || d.location.toLowerCase().contains(query);
    final matchesCategory = category == 'Tất cả' || d.category == category;
    return matchesSearch && matchesCategory;
  }).toList();
});

final filteredRecommendedProvider = Provider<List<Destination>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final category = ref.watch(selectedCategoryProvider);
  final recommended = ref.watch(recommendedProvider);

  return recommended.where((d) {
    final matchesSearch = query.isEmpty || d.name.toLowerCase().contains(query) || d.location.toLowerCase().contains(query);
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
