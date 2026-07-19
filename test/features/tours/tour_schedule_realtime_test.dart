import 'package:flutter_test/flutter_test.dart';
import 'package:online_travel_agent/features/tours/application/tour_provider.dart';

void main() {
  group('shouldRefreshTourSchedule', () {
    test('refreshes only for an update to the open tour', () {
      expect(
        shouldRefreshTourSchedule('tour-a', {'tourId': 'tour-a'}),
        isTrue,
      );
    });

    test('ignores an update for another tour', () {
      expect(
        shouldRefreshTourSchedule('tour-a', {'tourId': 'tour-b'}),
        isFalse,
      );
    });

    test('ignores a trip schedule update and an empty payload', () {
      expect(
        shouldRefreshTourSchedule('tour-a', {'tripId': 'trip-1'}),
        isFalse,
      );
      expect(shouldRefreshTourSchedule('tour-a', {}), isFalse);
    });
  });
}
