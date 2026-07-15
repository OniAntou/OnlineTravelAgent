import 'package:flutter_test/flutter_test.dart';
import 'package:online_travel_agent/data/services/realtime_room_registry.dart';

void main() {
  test('rejoins every active room after a socket reconnect', () {
    final registry = RealtimeRoomRegistry()
      ..trackTrip('trip-1')
      ..trackTour('tour-1');
    final emitted = <(String, dynamic)>[];

    registry.rejoin(
      token: 'token-1',
      emit: (event, payload) => emitted.add((event, payload)),
    );

    expect(emitted.map((entry) => entry.$1), [
      'join_trip_room',
      'join_tour_room',
    ]);
    expect(emitted[0].$2, {'tripId': 'trip-1', 'token': 'token-1'});
    expect(emitted[1].$2, {'tourId': 'tour-1', 'token': 'token-1'});
  });

  test('does not rejoin authenticated rooms without a token', () {
    final registry = RealtimeRoomRegistry()..trackTrip('trip-1');
    final emitted = <(String, dynamic)>[];

    registry.rejoin(
      token: null,
      emit: (event, payload) => emitted.add((event, payload)),
    );

    expect(emitted, isEmpty);
  });
}
