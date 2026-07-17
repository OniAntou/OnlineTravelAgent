import '../../features/destinations/domain/destination.dart';
import '../../features/flights/domain/flight.dart';
import '../../features/hotels/domain/hotel.dart';
import '../../features/tours/domain/tour_package.dart';
import 'api_http_client.dart';

class LocationApiService {
  final ApiHttpClient _client;
  LocationApiService(this._client);

  Future<Destination> setFavorite(String destinationId, bool isFavorite) async {
    final data = await _client.patchJson(
      '/api/destinations/$destinationId/favorite',
      {'isFavorite': isFavorite},
    );
    return Destination.fromJson(data);
  }

  Future<List<Flight>> searchFlights(String? departure, String? arrival) async {
    final raw = await _client.getList(
      _client.pathWithQuery('/api/flights/search', {
        'departure': departure,
        'arrival': arrival,
      }),
    );
    return raw
        .whereType<Map<String, dynamic>>()
        .map(Flight.fromJson)
        .toList(growable: false);
  }

  Future<Map<String, List<dynamic>>> globalSearch(String query) async {
    final data = await _client.getJson(
      _client.pathWithQuery('/api/search', {'q': query}),
    );
    return {
      'hotels': _parseList(data['hotels'], Hotel.fromJson),
      'tours': _parseList(data['tours'], TourPackage.fromJson),
      'destinations': _parseList(data['destinations'], Destination.fromJson),
    };
  }

  static List<T> _parseList<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return ((raw as List?) ?? [])
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .toList(growable: false);
  }
}
