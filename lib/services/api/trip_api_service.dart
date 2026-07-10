import 'package:uuid/uuid.dart';
import '../../models/trip.dart';
import '../../models/trip_schedule.dart';
import 'api_http_client.dart';

class TripApiService {
  final ApiHttpClient _client;
  TripApiService(this._client);

  Future<Trip> bookTrip({required String destinationId, String? date, String? guests, double? totalPrice}) async {
    final body = <String, dynamic>{'destinationId': destinationId, 'date': date, 'guests': guests, 'requestId': const Uuid().v4()};
    if (totalPrice != null) body['totalPrice'] = totalPrice;
    final data = await _client.postJson('/api/trips/book', body, queueOnFailure: false);
    return Trip.fromJson(data);
  }

  Future<Trip> cancelTrip(String tripId) async {
    final data = await _client.postJson('/api/trips/$tripId/cancel', {});
    return Trip.fromJson(data);
  }

  Future<Trip> bookFlight({required String flightId, required String date, required String guests}) async {
    final data = await _client.postJson('/api/trips/book-flight', {'flightId': flightId, 'date': date, 'guests': guests, 'requestId': const Uuid().v4()}, queueOnFailure: false);
    return Trip.fromJson(data);
  }

  Future<Trip> bookHotel({required String roomId, required String checkIn, required String checkOut, required String guests}) async {
    final data = await _client.postJson('/api/hotels/book', {'roomId': roomId, 'checkIn': checkIn, 'checkOut': checkOut, 'guests': guests, 'requestId': const Uuid().v4()}, queueOnFailure: false);
    return Trip.fromJson(data);
  }

  Future<Trip> bookTour({required String tourId, required String date, required String guests, double? totalPrice}) async {
    final body = <String, dynamic>{'tourId': tourId, 'date': date, 'guests': guests, 'requestId': const Uuid().v4()};
    if (totalPrice != null) body['totalPrice'] = totalPrice;
    final data = await _client.postJson('/api/tours/book', body, queueOnFailure: false);
    return Trip.fromJson(data);
  }

  Future<TripSchedule> fetchTripSchedule(String tripId) async {
    final data = await _client.getJson('/api/trips/$tripId/schedule');
    return TripSchedule.fromJson(data);
  }

  Future<Map<String, TripSchedule>> fetchTripSchedulesBatch(List<String> tripIds) async {
    if (tripIds.isEmpty) return {};
    final data = await _client.getJson(_client.pathWithQuery('/api/trips/schedules', {'ids': tripIds.join(',')}));
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
