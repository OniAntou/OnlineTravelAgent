import 'package:flutter_test/flutter_test.dart';
import 'package:online_travel_agent/core/utils/trip_schedule_status.dart';

void main() {
  group('deriveTripScheduleMilestoneStatus', () {
    final today = DateTime(2026, 7, 13, 10, 30);

    test('recognizes the Vietnamese completed trip label', () {
      expect(
        deriveTripScheduleMilestoneStatus(
          tripStatus: 'Đã hoàn thành',
          scheduleDate: '2026-07-13',
          startTime: '11:00',
          endTime: '12:00',
          now: today,
        ),
        'completed',
      );
    });

    test('marks an item completed after its end time', () {
      expect(
        deriveTripScheduleMilestoneStatus(
          tripStatus: 'Đang diễn ra',
          scheduleDate: '2026-07-13',
          startTime: '09:00',
          endTime: '10:00',
          now: today,
        ),
        'completed',
      );
    });

    test('marks an item ongoing only inside its time range', () {
      expect(
        deriveTripScheduleMilestoneStatus(
          tripStatus: 'Đang diễn ra',
          scheduleDate: '2026-07-13',
          startTime: '10:00',
          endTime: '11:00',
          now: today,
        ),
        'ongoing',
      );
    });

    test('uses the next item start as the boundary when end time is absent', () {
      expect(
        deriveTripScheduleMilestoneStatus(
          tripStatus: 'Đang diễn ra',
          scheduleDate: '2026-07-13',
          startTime: '09:00',
          endTime: '',
          nextStartTime: '10:00',
          now: today,
        ),
        'completed',
      );
    });

    test('preserves a manual status override', () {
      expect(
        deriveTripScheduleMilestoneStatus(
          tripStatus: 'Đang diễn ra',
          scheduleDate: '2026-07-13',
          startTime: '09:00',
          endTime: '10:00',
          statusOverride: 'delayed',
          now: today,
        ),
        'delayed',
      );
    });
  });
}
