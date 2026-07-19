import 'package:flutter_test/flutter_test.dart';
import 'package:online_travel_agent/data/remote/trip_api_service.dart';
import 'package:online_travel_agent/features/trips/domain/trip_change_request.dart';

void main() {
  test('chunks unique trip schedule IDs to the backend limit', () {
    final ids = [
      ...List.generate(maxTripScheduleIdsPerRequest, (index) => 'trip-$index'),
      'trip-0',
      'trip-50',
    ];

    final chunks = chunkTripScheduleIds(ids).toList(growable: false);

    expect(chunks, hasLength(2));
    expect(chunks.first, hasLength(maxTripScheduleIdsPerRequest));
    expect(chunks.last, ['trip-50']);
  });

  test('builds the owned schedule-item confirmation request', () {
    expect(
      confirmTripScheduleItemPath('trip-1', 'item-1'),
      '/api/trips/trip-1/schedule/items/item-1/status',
    );
    expect(confirmTripScheduleItemBody, {'statusOverride': 'completed'});
  });

  test('builds owned trip change request paths and bodies', () {
    expect(
      tripChangeRequestsPath('trip-1'),
      '/api/trips/trip-1/change-requests',
    );
    expect(
      createTripChangeRequestBody(
        type: TripChangeRequestType.reschedule,
        reason: 'Tôi cần chuyển lịch vì có lịch thi.',
        requestedDate: '25/08/2099',
      ),
      {
        'type': 'RESCHEDULE',
        'reason': 'Tôi cần chuyển lịch vì có lịch thi.',
        'requestedDate': '25/08/2099',
      },
    );
  });
}
