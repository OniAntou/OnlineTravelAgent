import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart' as drift;
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../database/app_database.dart';

import '../core/exceptions.dart';
import '../core/theme/app_theme.dart';
import '../models/destination.dart';
import '../models/document_item.dart';
import '../models/flight.dart';
import '../models/trip.dart';
import '../models/hotel.dart';
import '../models/review.dart';
import '../models/room.dart';
import '../models/tour_package.dart';
import '../models/trip_schedule.dart';
import '../utils/api_exception.dart';

class BootstrapData {
  final List<String> categories;
  final List<Destination> destinations;
  final List<Destination> recommended;
  final List<Trip> trips;
  final List<DocumentItem> documents;
  final List<Hotel> hotels;
  final List<TourPackage> tourPackages;

  BootstrapData({
    required this.categories,
    required this.destinations,
    required this.recommended,
    required this.trips,
    required this.documents,
    required this.hotels,
    required this.tourPackages,
  });
}

class TravelApiService {
  TravelApiService({String? baseUrl, FlutterSecureStorage? secureStorage})
    : _baseUrl = baseUrl ?? _defaultBaseUrl(),
      _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    loadTokenFuture = _loadToken();
  }

  final String _baseUrl;
  final FlutterSecureStorage _secureStorage;
  FlutterSecureStorage get secureStorage => _secureStorage;
  String? token;
  String? userName;
  String? userEmail;
  late final Future<void> loadTokenFuture;
  void Function()? onAuthError;

  static const String _tokenKey = 'auth_token';

  io.Socket? _socket;
  io.Socket get socket {
    _socket ??= io.io(
      _baseUrl,
      io.OptionBuilder().setTransports(['websocket']).build(),
    );
    return _socket!;
  }

  Future<void> _loadToken() async {
    try {
      token = await _secureStorage.read(key: _tokenKey);
      userName = await _secureStorage.read(key: 'auth_user_name');
      userEmail = await _secureStorage.read(key: 'auth_user_email');
    } catch (e) {
      debugPrint('Failed to read token from secure storage: $e');
    }
  }

  Future<void> _ensureTokenLoaded() async {
    await loadTokenFuture;
  }

  static String _defaultBaseUrl() {
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    if (fromDefine.isNotEmpty) {
      assert(
        !kReleaseMode || fromDefine.startsWith('https://'),
        'Production API URL must use HTTPS',
      );
      return fromDefine;
    }
    if (kReleaseMode) {
      throw StateError(
        'API_BASE_URL must be set in release mode via --dart-define=API_BASE_URL=https://...',
      );
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<http.Response> _sendRequest(
    String method,
    String path, [
    Map<String, dynamic>? body,
    bool queueOnFailure = true,
  ]) async {
    await _ensureTokenLoaded();
    return _safeCall(
      () async {
        http.Response response;
        final uri = _uri(path);
        switch (method) {
          case 'GET':
            response = await http
                .get(uri, headers: _headers)
                .timeout(AppTheme.apiTimeout);
            break;
          case 'POST':
            response = await http
                .post(uri, headers: _headers, body: jsonEncode(body))
                .timeout(AppTheme.apiTimeout);
            break;
          case 'PATCH':
            response = await http
                .patch(uri, headers: _headers, body: jsonEncode(body))
                .timeout(AppTheme.apiTimeout);
            break;
          case 'PUT':
            response = await http
                .put(uri, headers: _headers, body: jsonEncode(body))
                .timeout(AppTheme.apiTimeout);
            break;
          case 'DELETE':
            response = await http
                .delete(uri, headers: _headers)
                .timeout(AppTheme.apiTimeout);
            break;
          default:
            throw UnsupportedError('Unsupported HTTP method: $method');
        }
        _throwIfError(response);
        return response;
      },
      method,
      path,
      body,
      queueOnFailure,
    );
  }

  Future<Map<String, dynamic>> _getJson(String path) async {
    final response = await _sendRequest('GET', path);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> _getList(String path) async {
    final response = await _sendRequest('GET', path);
    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _sendRequest('POST', path, body);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _patchJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _sendRequest('PATCH', path, body);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _putJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _sendRequest('PUT', path, body);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> _delete(String path) async {
    await _sendRequest('DELETE', path);
  }

  Future<BootstrapData> fetchBootstrap() async {
    final data = await _getJson('/api/bootstrap');
    return BootstrapData(
      categories: ((data['categories'] as List?) ?? []).cast<String>().toList(
        growable: false,
      ),
      destinations: _parseList(data['destinations'], Destination.fromJson),
      recommended: _parseList(data['recommended'], Destination.fromJson),
      trips: _parseList(data['trips'], Trip.fromJson),
      documents: _parseList(data['documents'], DocumentItem.fromJson),
      hotels: _parseList(data['hotels'], Hotel.fromJson),
      tourPackages: _parseList(data['tourPackages'], TourPackage.fromJson),
    );
  }

  Future<Destination> setFavorite(String destinationId, bool isFavorite) async {
    final data = await _patchJson('/api/destinations/$destinationId/favorite', {
      'isFavorite': isFavorite,
    });
    return Destination.fromJson(data);
  }

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
    };
    if (totalPrice != null) body['totalPrice'] = totalPrice;
    final data = await _postJson('/api/trips/book', body);
    return Trip.fromJson(data);
  }

  Future<Trip> cancelTrip(String tripId) async {
    final data = await _postJson('/api/trips/$tripId/cancel', {});
    return Trip.fromJson(data);
  }

  Future<List<Flight>> searchFlights(String? departure, String? arrival) async {
    await _ensureTokenLoaded();
    return _safeCall(() async {
      String query = '';
      if (departure != null && arrival != null) {
        query = '?departure=$departure&arrival=$arrival';
      } else if (departure != null) {
        query = '?departure=$departure';
      } else if (arrival != null) {
        query = '?arrival=$arrival';
      }
      final response = await http
          .get(_uri('/api/flights/search$query'), headers: _headers)
          .timeout(AppTheme.apiTimeout);
      _throwIfError(response);
      final List<dynamic> raw = jsonDecode(response.body);
      return raw.map((e) => Flight.fromJson(e)).toList();
    });
  }

  Future<Trip> bookFlight({
    required String flightId,
    required String date,
    required String guests,
  }) async {
    final data = await _postJson('/api/trips/book-flight', {
      'flightId': flightId,
      'date': date,
      'guests': guests,
    });
    return Trip.fromJson(data);
  }

  Future<DocumentItem> addDocument({
    required String title,
    required String description,
    required String icon,
    required String color,
  }) async {
    final data = await _postJson('/api/documents', {
      'title': title,
      'description': description,
      'icon': icon,
      'color': color,
    });
    return DocumentItem.fromJson(data);
  }

  Future<bool> deleteDocument(String documentId) async {
    await _ensureTokenLoaded();
    return _safeCall(() async {
      final response = await http
          .delete(_uri('/api/documents/$documentId'), headers: _headers)
          .timeout(AppTheme.apiTimeout);
      _throwIfError(response);
      return true;
    });
  }

  Future<ReviewResponse> getReviews({
    required String targetType,
    required String targetId,
  }) async {
    final data = await _getJson(
      '/api/reviews?targetType=$targetType&targetId=$targetId',
    );
    return ReviewResponse.fromJson(data);
  }

  Future<Review> createReview({
    required String targetType,
    required String targetId,
    required int rating,
    required String comment,
  }) async {
    final data = await _postJson('/api/reviews', {
      'targetType': targetType,
      'targetId': targetId,
      'rating': rating,
      'comment': comment,
    });
    return Review.fromJson(data);
  }

  Future<bool> deleteReview(String reviewId) async {
    await _ensureTokenLoaded();
    return _safeCall(() async {
      final response = await http
          .delete(_uri('/api/reviews/$reviewId'), headers: _headers)
          .timeout(AppTheme.apiTimeout);
      _throwIfError(response);
      return true;
    });
  }

  Future<Trip> bookHotel({
    required String roomId,
    required String checkIn,
    required String checkOut,
    required String guests,
  }) async {
    final data = await _postJson('/api/hotels/book', {
      'roomId': roomId,
      'checkIn': checkIn,
      'checkOut': checkOut,
      'guests': guests,
    });
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
    };
    if (totalPrice != null) body['totalPrice'] = totalPrice;
    final data = await _postJson('/api/tours/book', body);
    return Trip.fromJson(data);
  }

  Future<Trip> createCustomTour({
    required String destination,
    required String location,
    required String date,
    required String guests,
    required String imagePath,
    List<String>? flightIds,
    List<String>? hotelIds,
    String? roomId,
    double? totalPrice,
  }) async {
    final body = <String, dynamic>{
      'destination': destination,
      'location': location,
      'date': date,
      'guests': guests,
      'imagePath': imagePath,
    };
    if (flightIds != null) body['flightIds'] = flightIds;
    if (hotelIds != null) body['hotelIds'] = hotelIds;
    if (roomId != null) body['roomId'] = roomId;
    if (totalPrice != null) body['totalPrice'] = totalPrice;
    final data = await _postJson('/api/trips/custom-tour', body);
    return Trip.fromJson(data);
  }

  Future<TripSchedule> fetchTripSchedule(String tripId) async {
    final data = await _getJson('/api/trips/$tripId/schedule');
    return TripSchedule.fromJson(data);
  }

  Future<TripSchedule> fetchTourSchedule(String tourId) async {
    final data = await _getJson('/api/tours/$tourId/schedule');
    // Notice that ScheduleTemplate and TripSchedule have very similar structure.
    // TripSchedule.fromJson works fine if 'days' array and 'items' array structures match.
    // We can reuse TripSchedule for displaying the tour schedule.
    // Wait, ScheduleTemplate from DB has `tourPackageId`, not `tripId`.
    // The JSON from backend might not map perfectly.
    // Let's ensure it has tripId or we just provide a default.
    data['tripId'] = data['tripId'] ?? tourId;
    return TripSchedule.fromJson(data);
  }

  Future<Map<String, dynamic>> checkPromoCode(String code) async {
    await _ensureTokenLoaded();
    return _safeCall(() async {
      final response = await http
          .get(_uri('/api/promo-codes/check?code=$code'), headers: _headers)
          .timeout(AppTheme.apiTimeout);
      _throwIfError(response);
      return jsonDecode(response.body) as Map<String, dynamic>;
    });
  }

  // ── VNPAY Payment ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> createVnpayPayment({
    required String tripId,
    required double amount,
    String? orderInfo,
    String? locale,
  }) async {
    return _postJson('/api/payment/vnpay/create', {
      'tripId': tripId,
      'amount': amount,
      'orderInfo': orderInfo ?? 'Thanh toán đặt chỗ Online Travel Agent',
      'locale': locale ?? 'vn',
    });
  }

  Future<Map<String, dynamic>> checkPaymentStatus(String tripId) async {
    return _getJson('/api/payment/vnpay/status/$tripId');
  }

  // ── MoMo Payment ───────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> createMomoPayment({
    required String tripId,
    required double amount,
    String? orderInfo,
  }) async {
    return _postJson('/api/payment/momo/create', {
      'tripId': tripId,
      'amount': amount,
      'orderInfo': orderInfo ?? 'Thanh toán đặt chỗ Online Travel Agent',
    });
  }

  // ── Auth ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await _postJson('/api/auth/login', {
      'email': email,
      'password': password,
    });
    return _handleAuthResponse(res);
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await _postJson('/api/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
    return _handleAuthResponse(res);
  }

  Future<Map<String, dynamic>> _handleAuthResponse(
    Map<String, dynamic> res,
  ) async {
    final tokenValue = res['token']?.toString();
    if (tokenValue != null) {
      token = tokenValue;
      try {
        await _secureStorage.write(key: _tokenKey, value: tokenValue);
        final resName = (res['user'] as Map<String, dynamic>?)?['name']
            ?.toString();
        final resEmail = (res['user'] as Map<String, dynamic>?)?['email']
            ?.toString();
        if (resName != null) {
          userName = resName;
          await _secureStorage.write(key: 'auth_user_name', value: resName);
        }
        if (resEmail != null) {
          userEmail = resEmail;
          await _secureStorage.write(key: 'auth_user_email', value: resEmail);
        }
      } catch (e) {
        debugPrint('Failed to write auth data to secure storage: $e');
      }
    }
    return res;
  }

  Future<void> logout() async {
    token = null;
    userName = null;
    userEmail = null;
    try {
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: 'auth_user_name');
      await _secureStorage.delete(key: 'auth_user_email');
    } catch (e) {
      debugPrint('Failed to delete auth data from secure storage: $e');
    }
  }

  Future<Map<String, dynamic>> becomePartner() async {
    return await _postJson('/api/auth/become-partner', {});
  }

  Future<List<Hotel>> getPartnerHotels() async {
    final data = await _getList('/api/partner/hotels');
    return _parseList(data, Hotel.fromJson);
  }

  Future<Hotel> createPartnerHotel(Map<String, dynamic> data) async {
    final res = await _postJson('/api/partner/hotels', data);
    return Hotel.fromJson(res);
  }

  Future<List<TourPackage>> getPartnerTours() async {
    final data = await _getList('/api/partner/tours');
    return _parseList(data, TourPackage.fromJson);
  }

  Future<TourPackage> createPartnerTour(Map<String, dynamic> data) async {
    final res = await _postJson('/api/partner/tours', data);
    return TourPackage.fromJson(res);
  }

  Future<Hotel> updatePartnerHotel(String id, Map<String, dynamic> data) async {
    final res = await _putJson('/api/partner/hotels/$id', data);
    return Hotel.fromJson(res);
  }

  Future<void> deletePartnerHotel(String id) async {
    await _delete('/api/partner/hotels/$id');
  }

  Future<TourPackage> updatePartnerTour(
    String id,
    Map<String, dynamic> data,
  ) async {
    final res = await _putJson('/api/partner/tours/$id', data);
    return TourPackage.fromJson(res);
  }

  Future<void> deletePartnerTour(String id) async {
    await _delete('/api/partner/tours/$id');
  }

  Future<Map<String, dynamic>> getPartnerStats() async {
    return await _getJson('/api/partner/stats');
  }

  Future<List<Room>> getPartnerHotelRooms(String hotelId) async {
    final data = await _getList('/api/partner/hotels/$hotelId/rooms');
    return data.whereType<Map<String, dynamic>>().map(Room.fromJson).toList();
  }

  Future<Room> createPartnerRoom(
    String hotelId,
    Map<String, dynamic> data,
  ) async {
    final res = await _postJson('/api/partner/hotels/$hotelId/rooms', data);
    return Room.fromJson(res);
  }

  Future<void> updatePartnerRoom(
    String hotelId,
    String roomId,
    Map<String, dynamic> data,
  ) async {
    await _putJson('/api/partner/hotels/$hotelId/rooms/$roomId', data);
  }

  Future<void> deletePartnerRoom(String hotelId, String roomId) async {
    await _delete('/api/partner/hotels/$hotelId/rooms/$roomId');
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

  void _throwIfError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    final body = response.body;
    String message;
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      message =
          json['error']?.toString() ?? json['message']?.toString() ?? body;
    } catch (_) {
      message = body;
    }

    switch (response.statusCode) {
      case 400:
        throw ValidationException(message: message);
      case 401:
        if (onAuthError != null) onAuthError!();
        throw AuthException(message: message);
      case 403:
        throw ForbiddenException(message: message);
      case 404:
        throw NotFoundException(message: message);
      case 500:
      case 502:
      case 503:
        throw ServerException(message: message);
      default:
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Lỗi API ($response.statusCode): $message',
        );
    }
  }

  Future<T> _safeCall<T>(
    Future<T> Function() call, [
    String? method,
    String? path,
    Map<String, dynamic>? body,
    bool queueOnFailure = true,
  ]) async {
    try {
      return await call();
    } on ApiException {
      rethrow;
    } on SocketException {
      if (queueOnFailure && method != null && method != 'GET' && path != null) {
        await _queueRequest(method, path, body);
        throw const NetworkException(
          message: 'Mạng rớt. Đã lưu yêu cầu vào hàng đợi Offline.',
        );
      }
      throw const NetworkException();
    } on HttpException {
      if (queueOnFailure && method != null && method != 'GET' && path != null) {
        await _queueRequest(method, path, body);
        throw const NetworkException(
          message: 'Không thể kết nối. Đã lưu yêu cầu vào hàng đợi Offline.',
        );
      }
      throw const NetworkException(message: 'Không thể kết nối đến máy chủ.');
    } on TimeoutException {
      if (queueOnFailure && method != null && method != 'GET' && path != null) {
        await _queueRequest(method, path, body);
        throw const TimeoutApiException(
          message: 'Hết thời gian. Đã lưu yêu cầu vào hàng đợi Offline.',
        );
      }
      throw const TimeoutApiException();
    } on FormatException {
      throw const ParseException();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _queueRequest(
    String method,
    String path,
    Map<String, dynamic>? body,
  ) async {
    final db = AppDatabase.instance();
    await db.offlineQueueDao.insertItem(
      OfflineQueueTableCompanion.insert(
        endpoint: path,
        method: method,
        bodyJson: drift.Value(body != null ? jsonEncode(body) : null),
      ),
    );
  }

  Future<void> flushRequest(
    String method,
    String path,
    Map<String, dynamic>? body,
  ) async {
    await _sendRequest(method, path, body, false);
  }
}
