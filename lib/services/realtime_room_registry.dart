typedef RealtimeEmit = void Function(String event, dynamic payload);

class RealtimeRoomRegistry {
  final Set<String> _tripIds = <String>{};
  final Set<String> _tourIds = <String>{};

  void trackTrip(String tripId) => _tripIds.add(tripId);
  void untrackTrip(String tripId) => _tripIds.remove(tripId);
  void trackTour(String tourId) => _tourIds.add(tourId);
  void untrackTour(String tourId) => _tourIds.remove(tourId);
  void clear() {
    _tripIds.clear();
    _tourIds.clear();
  }

  void rejoin({required String? token, required RealtimeEmit emit}) {
    if (token == null || token.isEmpty) return;
    for (final tripId in _tripIds) {
      emit('join_trip_room', {'tripId': tripId, 'token': token});
    }
    for (final tourId in _tourIds) {
      emit('join_tour_room', {'tourId': tourId, 'token': token});
    }
  }
}
