import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:online_travel_agent/data/services/api_provider.dart';
import 'package:online_travel_agent/features/trips/application/trip_change_request_provider.dart';
import 'package:online_travel_agent/features/trips/domain/trip.dart';
import 'package:online_travel_agent/features/trips/domain/trip_change_request.dart';
import 'package:online_travel_agent/features/trips/presentation/widgets/trip_change_request_panel.dart';
import '../../helpers/test_helpers.dart';

class _TripChangeRequestApi extends FakeTravelApiService {
  final List<TripChangeRequest> requests;

  _TripChangeRequestApi({required super.secureStorage, required this.requests});

  @override
  Future<List<TripChangeRequest>> fetchTripChangeRequests(String tripId) async {
    return requests.where((request) => request.tripId == tripId).toList();
  }
}

void main() {
  test('maps an approved refund with a Decimal amount from the server', () {
    final request = TripChangeRequest.fromJson({
      'id': 'request-1',
      'tripId': 'trip-1',
      'type': 'REFUND',
      'status': 'APPROVED',
      'reason': 'Không thể tham gia chuyến đi.',
      'refundAmount': '750000.00',
      'adminNote': 'Đã duyệt hoàn tiền mô phỏng.',
      'reviewedAt': '2099-08-01T10:00:00.000Z',
    });

    expect(request.type, TripChangeRequestType.refund);
    expect(request.status, TripChangeRequestStatus.approved);
    expect(request.status.displayLabel, 'Đã duyệt');
    expect(request.refundAmount, 750000);
    expect(request.adminNote, 'Đã duyệt hoàn tiền mô phỏng.');
  });

  test('loads change requests scoped to the displayed trip', () async {
    const request = TripChangeRequest(
      id: 'request-1',
      tripId: 'trip-1',
      type: TripChangeRequestType.refund,
      status: TripChangeRequestStatus.pending,
      reason: 'Không thể tham gia chuyến đi.',
    );
    final container = ProviderContainer(
      overrides: [
        apiProvider.overrideWithValue(
          _TripChangeRequestApi(
            secureStorage: FakeSecureStorage(),
            requests: const [request],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final requests = await container.read(
      tripChangeRequestsProvider('trip-1').future,
    );

    expect(requests, const [request]);
  });

  testWidgets('shows the approved refund decision to the customer', (
    tester,
  ) async {
    const request = TripChangeRequest(
      id: 'request-1',
      tripId: 'trip-1',
      type: TripChangeRequestType.refund,
      status: TripChangeRequestStatus.approved,
      reason: 'Không thể tham gia chuyến đi.',
      refundAmount: 750000,
      adminNote: 'Đã duyệt hoàn tiền mô phỏng.',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: TripChangeRequestSummaryCard(request: request)),
      ),
    );

    expect(find.text('Yêu cầu hoàn tiền'), findsOneWidget);
    expect(find.text('Đã duyệt'), findsOneWidget);
    expect(find.textContaining('750.000'), findsOneWidget);
    expect(find.text('Đã duyệt hoàn tiền mô phỏng.'), findsOneWidget);
  });

  test('prevents a second action while a request is pending', () {
    const trip = Trip(
      id: 'trip-1',
      destination: 'Đà Lạt',
      location: 'Lâm Đồng',
      date: '25/08/2099',
      guests: '2',
      status: TripStatus.upcoming,
      imagePath: '',
    );
    const pendingRequest = TripChangeRequest(
      id: 'request-1',
      tripId: 'trip-1',
      type: TripChangeRequestType.refund,
      status: TripChangeRequestStatus.pending,
      reason: 'Không thể tham gia chuyến đi.',
    );

    expect(canRequestTripChange(trip, []), isTrue);
    expect(canRequestTripChange(trip, const [pendingRequest]), isFalse);
  });
}
