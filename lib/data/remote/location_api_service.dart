import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/theme/app_theme.dart';
import '../../models/destination.dart';
import '../../models/flight.dart';
import '../../models/hotel.dart';
import '../../models/tour_package.dart';
import 'api_http_client.dart';

class LocationApiService {
  final ApiHttpClient _client;
  LocationApiService(this._client);

  Future<Destination> setFavorite(String destinationId, bool isFavorite) async {
    final data = await _client.patchJson('/api/destinations/$destinationId/favorite', {'isFavorite': isFavorite});
    return Destination.fromJson(data);
  }

  Future<List<Flight>> searchFlights(String? departure, String? arrival) async {
    await _client.ensureTokenLoaded();
    return _client.safeCall(() async {
      final response = await http.get(_client.uriWithQuery('/api/flights/search', {'departure': departure, 'arrival': arrival}), headers: _client.headers).timeout(AppTheme.apiTimeout);
      _client.throwIfError(response);
      final List<dynamic> raw = jsonDecode(response.body);
      return raw.map((e) => Flight.fromJson(e)).toList();
    });
  }

  Future<Map<String, List<dynamic>>> globalSearch(String query) async {
    final data = await _client.getJson(_client.pathWithQuery('/api/search', {'q': query}));
    return {
      'hotels': _parseList(data['hotels'], Hotel.fromJson),
      'tours': _parseList(data['tours'], TourPackage.fromJson),
      'destinations': _parseList(data['destinations'], Destination.fromJson),
    };
  }

  static List<T> _parseList<T>(dynamic raw, T Function(Map<String, dynamic>) fromJson) {
    return ((raw as List?) ?? []).whereType<Map<String, dynamic>>().map(fromJson).toList(growable: false);
  }
}
