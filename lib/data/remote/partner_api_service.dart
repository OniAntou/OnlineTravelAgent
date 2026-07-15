import '../../models/hotel.dart';
import '../../models/room.dart';
import '../../models/tour_package.dart';
import 'api_http_client.dart';

class PartnerApiService {
  final ApiHttpClient _client;
  PartnerApiService(this._client);

  Future<List<Hotel>> getPartnerHotels() async {
    final data = await _client.getList('/api/partner/hotels');
    return _parseList(data, Hotel.fromJson);
  }

  Future<Hotel> createPartnerHotel(Map<String, dynamic> data) async {
    final res = await _client.postJson('/api/partner/hotels', data);
    return Hotel.fromJson(res);
  }

  Future<List<TourPackage>> getPartnerTours() async {
    final data = await _client.getList('/api/partner/tours');
    return _parseList(data, TourPackage.fromJson);
  }

  Future<TourPackage> createPartnerTour(Map<String, dynamic> data) async {
    final res = await _client.postJson('/api/partner/tours', data);
    return TourPackage.fromJson(res);
  }

  Future<Hotel> updatePartnerHotel(String id, Map<String, dynamic> data) async {
    final res = await _client.putJson('/api/partner/hotels/$id', data);
    return Hotel.fromJson(res);
  }

  Future<void> deletePartnerHotel(String id) async {
    await _client.delete('/api/partner/hotels/$id');
  }

  Future<TourPackage> updatePartnerTour(String id, Map<String, dynamic> data) async {
    final res = await _client.putJson('/api/partner/tours/$id', data);
    return TourPackage.fromJson(res);
  }

  Future<void> deletePartnerTour(String id) async {
    await _client.delete('/api/partner/tours/$id');
  }

  Future<Map<String, dynamic>> getPartnerStats() async {
    return await _client.getJson('/api/partner/stats');
  }

  Future<List<Room>> getPartnerHotelRooms(String hotelId) async {
    final data = await _client.getList('/api/partner/hotels/$hotelId/rooms');
    return data.whereType<Map<String, dynamic>>().map(Room.fromJson).toList();
  }

  Future<Room> createPartnerRoom(String hotelId, Map<String, dynamic> data) async {
    final res = await _client.postJson('/api/partner/hotels/$hotelId/rooms', data);
    return Room.fromJson(res);
  }

  Future<void> updatePartnerRoom(String hotelId, String roomId, Map<String, dynamic> data) async {
    await _client.putJson('/api/partner/hotels/$hotelId/rooms/$roomId', data);
  }

  Future<void> deletePartnerRoom(String hotelId, String roomId) async {
    await _client.delete('/api/partner/hotels/$hotelId/rooms/$roomId');
  }

  static List<T> _parseList<T>(dynamic raw, T Function(Map<String, dynamic>) fromJson) {
    return ((raw as List?) ?? []).whereType<Map<String, dynamic>>().map(fromJson).toList(growable: false);
  }
}
