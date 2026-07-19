import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/tour_package.dart';
import '../../trips/domain/trip_schedule.dart';
import '../../../app/state/app_state_provider.dart';
import '../../../data/services/api_provider.dart';

bool shouldRefreshTourSchedule(String tourId, dynamic event) =>
    event is Map && event['tourId'] == tourId;

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
      await apiService.loadTokenFuture;

      // Real-time WebSocket updates
      final socket = apiService.socket;
      apiService.joinTourRoom(tourId);

      void onScheduleUpdated(dynamic data) {
        if (shouldRefreshTourSchedule(tourId, data)) ref.invalidateSelf();
      }

      socket.on('schedule_updated', onScheduleUpdated);

      ref.onDispose(() {
        socket.off('schedule_updated', onScheduleUpdated);
        apiService.leaveTourRoom(tourId);
      });

      return apiService.fetchTourSchedule(tourId);
    });
