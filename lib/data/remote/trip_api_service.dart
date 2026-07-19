import 'package:uuid/uuid.dart';
import '../../features/trips/domain/trip.dart';
import '../../features/trips/domain/trip_change_request.dart';
import '../../features/trips/domain/trip_schedule.dart';
import 'api_http_client.dart';

const maxTripScheduleIdsPerRequest = 50;
const confirmTripScheduleItemBody = {'statusOverride': 'completed'};

String confirmTripScheduleItemPath(String tripId, String itemId) =>
    '/api/trips/$tripId/schedule/items/$itemId/status';

String tripChangeRequestsPath(String tripId) =>
    '/api/trips/$tripId/change-requests';

Map<String, dynamic> createTripChangeRequestBody({
  required TripChangeRequestType type,
  required String reason,
  String? requestedDate,
}) {
  if (type == TripChangeRequestType.unknown) {
    throw ArgumentError.value(type, 'type', 'A known request type is required');
  }

  final body = <String, dynamic>{'type': type.serverValue, 'reason': reason};
  final normalizedDate = requestedDate?.trim();
  if (normalizedDate != null && normalizedDate.isNotEmpty) {
    body['requestedDate'] = normalizedDate;
  }
  return body;
}

Iterable<List<String>> chunkTripScheduleIds(Iterable<String> tripIds) sync* {
  final uniqueIds = <String>{};
  for (final tripId in tripIds) {
    final normalizedId = tripId.trim();
    if (normalizedId.isNotEmpty) uniqueIds.add(normalizedId);
  }

  final ids = uniqueIds.toList(growable: false);
  for (
    var start = 0;
    start < ids.length;
    start += maxTripScheduleIdsPerRequest
  ) {
    final end = (start + maxTripScheduleIdsPerRequest).clamp(0, ids.length);
    yield ids.sublist(start, end);
  }
}

class TripApiService {
  final ApiHttpClient _client;
  TripApiService(this._client);

  Future<Trip> bookTrip({
    required String destinationId,
    String? date,
    String? guests,
    double? totalPrice,
  }) async {
    final body = <String, dynamic>{
      'destinationId': destinationId,
      'date': date,
      'guests': guests,
      'requestId': const Uuid().v4(),
    };
    if (totalPrice != null) body['totalPrice'] = totalPrice;
    final data = await _client.postJson(
      '/api/trips/book',
      body,
      queueOnFailure: false,
    );
    return Trip.fromJson(data);
  }

  Future<List<TripChangeRequest>> fetchTripChangeRequests(String tripId) async {
    final data = await _client.getList(tripChangeRequestsPath(tripId));
    return data
        .whereType<Map<String, dynamic>>()
        .map(TripChangeRequest.fromJson)
        .toList(growable: false);
  }

  Future<TripChangeRequest> createTripChangeRequest({
    required String tripId,
    required TripChangeRequestType type,
    required String reason,
    String? requestedDate,
  }) async {
    final data = await _client.postJson(
      tripChangeRequestsPath(tripId),
      createTripChangeRequestBody(
        type: type,
        reason: reason,
        requestedDate: requestedDate,
      ),
      queueOnFailure: false,
    );
    return TripChangeRequest.fromJson(data);
  }

  Future<Trip> bookFlight({
    required String flightId,
    required String date,
    required String guests,
  }) async {
    final data = await _client.postJson('/api/trips/book-flight', {
      'flightId': flightId,
      'date': date,
      'guests': guests,
      'requestId': const Uuid().v4(),
    }, queueOnFailure: false);
    return Trip.fromJson(data);
  }

  Future<Trip> bookHotel({
    required String roomId,
    required String checkIn,
    required String checkOut,
    required String guests,
  }) async {
    final data = await _client.postJson('/api/hotels/book', {
      'roomId': roomId,
      'checkIn': checkIn,
      'checkOut': checkOut,
      'guests': guests,
      'requestId': const Uuid().v4(),
    }, queueOnFailure: false);
    return Trip.fromJson(data);
  }

  Future<Trip> bookTour({
    required String tourId,
    required String date,
    required String guests,
    double? totalPrice,
  }) async {
    final body = <String, dynamic>{
      'tourId': tourId,
      'date': date,
      'guests': guests,
      'requestId': const Uuid().v4(),
    };
    if (totalPrice != null) body['totalPrice'] = totalPrice;
    final data = await _client.postJson(
      '/api/tours/book',
      body,
      queueOnFailure: false,
    );
    return Trip.fromJson(data);
  }

  Future<TripSchedule> fetchTripSchedule(String tripId) async {
    final data = await _client.getJson('/api/trips/$tripId/schedule');
    return TripSchedule.fromJson(data);
  }

  Future<void> confirmTripScheduleItem(String tripId, String itemId) async {
    await _client.patchJson(
      confirmTripScheduleItemPath(tripId, itemId),
      confirmTripScheduleItemBody,
    );
  }

  Future<Map<String, TripSchedule>> fetchTripSchedulesBatch(
    List<String> tripIds,
  ) async {
    final result = <String, TripSchedule>{};
    for (final ids in chunkTripScheduleIds(tripIds)) {
      result.addAll(await _fetchTripSchedulesBatchChunk(ids));
    }
    return result;
  }

  Future<Map<String, TripSchedule>> _fetchTripSchedulesBatchChunk(
    List<String> tripIds,
  ) async {
    final data = await _client.getJson(
      _client.pathWithQuery('/api/trips/schedules', {'ids': tripIds.join(',')}),
    );
    final result = <String, TripSchedule>{};
    data.forEach((tripId, value) {
      if (value is Map<String, dynamic>) {
        result[tripId] = TripSchedule.fromJson(value);
      }
    });
    return result;
  }

  Future<TripSchedule> fetchTourSchedule(String tourId) async {
    final data = await _client.getJson('/api/tours/$tourId/schedule');
    data['tripId'] = data['tripId'] ?? tourId;
    return TripSchedule.fromJson(data);
  }
}
