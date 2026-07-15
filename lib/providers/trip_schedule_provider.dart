import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trip_schedule.dart';
import 'api_provider.dart';

final tripScheduleProvider = FutureProvider.autoDispose
    .family<TripSchedule, String>((ref, tripId) async {
      final apiService = ref.watch(apiProvider);
      await apiService.loadTokenFuture;

      // Real-time WebSocket updates
      final socket = apiService.socket;

      // Listen to this specific trip's room
      apiService.joinTripRoom(tripId);

      void onScheduleUpdated(dynamic data) {
        if (data is Map && data['tripId'] != null && data['tripId'] != tripId) {
          return;
        }
        ref.invalidateSelf();
      }

      socket.on('schedule_updated', onScheduleUpdated);

      ref.onDispose(() {
        socket.off('schedule_updated', onScheduleUpdated);
        apiService.leaveTripRoom(tripId);
      });

      return apiService.fetchTripSchedule(tripId);
    });
