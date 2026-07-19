import 'package:flutter_test/flutter_test.dart';
import 'package:online_travel_agent/features/trips/application/trip_gps_progress.dart';
import 'package:online_travel_agent/features/trips/domain/trip_schedule.dart';

TripScheduleItem scheduleItem({
  required String id,
  required double? latitude,
  required double? longitude,
  String? statusOverride,
}) {
  return TripScheduleItem(
    id: id,
    title: id,
    description: '',
    startTime: '09:00',
    endTime: '10:00',
    location: 'Test location',
    latitude: latitude,
    longitude: longitude,
    statusOverride: statusOverride,
  );
}

void main() {
  group('trip GPS progress', () {
    test('selects the first unfinished coordinate-bearing schedule item', () {
      final target = selectNextGpsTarget(
        tripStatus: 'ongoing',
        schedule: TripSchedule(
          tripId: 'trip-1',
          days: [
            TripScheduleDay(
              id: 'day-1',
              dayNumber: 1,
              items: [
                scheduleItem(
                  id: 'complete',
                  latitude: 10.0,
                  longitude: 106.0,
                  statusOverride: 'completed',
                ),
                scheduleItem(id: 'missing', latitude: null, longitude: null),
                scheduleItem(id: 'next', latitude: 10.1, longitude: 106.1),
              ],
            ),
          ],
          updates: [],
        ),
        now: DateTime(2026, 7, 18, 9),
      );

      expect(target!.item.id, 'next');
      expect(target.coordinate, const GpsCoordinate(10.1, 106.1));
    });

    test('only offers arrival confirmation at 150 metres or nearer', () {
      expect(isWithinArrivalRadius(150), isTrue);
      expect(isWithinArrivalRadius(150.01), isFalse);
    });

    test('rejects invalid geographic coordinates', () {
      expect(isValidGpsCoordinate(latitude: 91, longitude: 106), isFalse);
      expect(isValidGpsCoordinate(latitude: 10, longitude: 181), isFalse);
      expect(isValidGpsCoordinate(latitude: 10, longitude: 106), isTrue);
    });

    test('builds the browser fallback directions URI', () {
      expect(
        buildBrowserDirectionsUri(const GpsCoordinate(10.1, 106.1)).toString(),
        'https://www.google.com/maps/dir/?api=1&destination=10.1%2C106.1',
      );
    });
  });
}
