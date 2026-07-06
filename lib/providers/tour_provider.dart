import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tour_package.dart';
import '../models/trip_schedule.dart';
import 'app_state_provider.dart';
import 'api_provider.dart';

final toursProvider = Provider<List<TourPackage>>((ref) {
  final bootstrap = ref.watch(bootstrapProvider).value;
  return bootstrap?.tourPackages ?? [];
});

class TourFavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String tourId) {
    if (state.contains(tourId)) {
      state = {...state}..remove(tourId);
    } else {
      state = {...state, tourId};
    }
  }

  bool isFavorite(String tourId) => state.contains(tourId);
}

final tourFavoritesProvider =
    NotifierProvider<TourFavoritesNotifier, Set<String>>(
      TourFavoritesNotifier.new,
    );

final tourScheduleProvider = FutureProvider.autoDispose
    .family<TripSchedule, String>((ref, tourId) async {
      final apiService = ref.watch(apiProvider);

      // Real-time WebSocket updates
      final socket = apiService.socket;

      // Listen to this specific tour's room
      socket.emit('join_tour_room', tourId);

      void onScheduleUpdated(dynamic data) {
        ref.invalidateSelf();
      }

      socket.on('schedule_updated', onScheduleUpdated);

      ref.onDispose(() {
        socket.off('schedule_updated', onScheduleUpdated);
      });

      return apiService.fetchTourSchedule(tourId);
    });
