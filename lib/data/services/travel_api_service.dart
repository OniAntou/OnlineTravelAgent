import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../features/destinations/domain/destination.dart';
import '../../features/profile/domain/document_item.dart';
import '../../features/flights/domain/flight.dart';
import '../../features/hotels/domain/hotel.dart';
import '../../shared/models/review.dart';
import '../../features/hotels/domain/room.dart';
import '../../features/tours/domain/tour_package.dart';
import '../../features/trips/domain/trip.dart';
import '../../features/trips/domain/trip_schedule.dart';
import '../remote/api_http_client.dart';

import '../remote/auth_api_service.dart';
import '../remote/trip_api_service.dart';
import '../remote/location_api_service.dart';
import '../remote/document_api_service.dart';
import '../remote/review_api_service.dart';
import 'realtime_room_registry.dart';
import '../remote/payment_api_service.dart';
import '../remote/partner_api_service.dart';

export '../remote/api_http_client.dart' show ApiHttpClient;

class BootstrapData {
  final List<String> categories;
  final List<Destination> destinations;
  final List<Destination> recommended;
  final List<Trip> trips;
  final List<DocumentItem> documents;
  final List<Hotel> hotels;
  final List<TourPackage> tourPackages;
  final List<Flight> flights;

  BootstrapData({
    required this.categories,
    required this.destinations,
    required this.recommended,
    required this.trips,
    required this.documents,
    required this.hotels,
    required this.tourPackages,
    this.flights = const [],
  });
}

class TravelApiService {
  final ApiHttpClient _client;
  String? _bootstrapEtag;

  late final AuthApiService auth;
  late final TripApiService tripsService;
  late final LocationApiService location;
  late final DocumentApiService documentsService;
  late final ReviewApiService reviews;
  late final PaymentApiService payment;
  late final PartnerApiService partner;

  TravelApiService({String? baseUrl, FlutterSecureStorage? secureStorage})
    : _client = ApiHttpClient(baseUrl: baseUrl, secureStorage: secureStorage) {
    auth = AuthApiService(_client);
    tripsService = TripApiService(_client);
    location = LocationApiService(_client);
    documentsService = DocumentApiService(_client);
    reviews = ReviewApiService(_client);
    payment = PaymentApiService(_client);
    partner = PartnerApiService(_client);
  }

  FlutterSecureStorage get secureStorage => _client.secureStorage;
  String get baseUrl => _client.baseUrl;
  String? get token => _client.token;
  set token(String? value) => _client.token = value;
  String? get userName => _client.userName;
  set userName(String? value) => _client.userName = value;
  String? get userEmail => _client.userEmail;
  set userEmail(String? value) => _client.userEmail = value;
  String? get userRole => _client.userRole;
  set userRole(String? value) => _client.userRole = value;
  Future<void> get loadTokenFuture => _client.loadTokenFuture;
  String? get refreshToken => _client.refreshToken;
  set refreshToken(String? value) => _client.refreshToken = value;

  set onAuthError(void Function()? handler) => _client.onAuthError = handler;

  io.Socket? _socket;
  final RealtimeRoomRegistry _realtimeRooms = RealtimeRoomRegistry();
  io.Socket get socket {
    if (_socket == null) {
      final created = io.io(
        _client.baseUrl,
        io.OptionBuilder().setTransports(['websocket']).build(),
      );
      created.on('connect', (_) {
        _realtimeRooms.rejoin(token: token, emit: created.emit);
      });
      _socket = created;
    }
    return _socket!;
  }

  void joinTripRoom(String tripId) {
    _realtimeRooms.trackTrip(tripId);
    _realtimeRooms.rejoin(token: token, emit: socket.emit);
  }

  void leaveTripRoom(String tripId) {
    _realtimeRooms.untrackTrip(tripId);
    _socket?.emit('leave_trip_room', tripId);
  }

  void joinTourRoom(String tourId) {
    _realtimeRooms.trackTour(tourId);
    _realtimeRooms.rejoin(token: token, emit: socket.emit);
  }

  void leaveTourRoom(String tourId) {
    _realtimeRooms.untrackTour(tourId);
    _socket?.emit('leave_tour_room', tourId);
  }

  Future<BootstrapData> fetchBootstrap() async {
    final response = await _client.getJsonIfModified('/api/bootstrap');
    final data = response.data!;
    _bootstrapEtag = response.eTag;
    return _parseBootstrap(data);
  }

  /// Avoids transferring and re-writing the complete offline snapshot when
  /// the server confirms it is unchanged since the previous sync.
  Future<BootstrapData?> fetchBootstrapIfChanged() async {
    if (_bootstrapEtag == null) {
      return fetchBootstrap();
    }
    final response = await _client.getJsonIfModified(
      '/api/bootstrap',
      eTag: _bootstrapEtag,
    );
    if (response.notModified) return null;
    _bootstrapEtag = response.eTag;
    return _parseBootstrap(response.data!);
  }

  BootstrapData _parseBootstrap(Map<String, dynamic> data) {
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
      flights: _parseList(data['flights'], Flight.fromJson),
    );
  }

  // Delegated Auth Methods
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) => auth.login(email: email, password: password);
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) => auth.register(name: name, email: email, password: password);
  Future<void> logout() async {
    _realtimeRooms.clear();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    await auth.logout();
  }

  void dispose() {
    _realtimeRooms.clear();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _client.dispose();
  }

  Future<Map<String, dynamic>> becomePartner() => auth.becomePartner();

  // Delegated Location Methods
  Future<Destination> setFavorite(String destinationId, bool isFavorite) =>
      location.setFavorite(destinationId, isFavorite);
  Future<List<Flight>> searchFlights(String? departure, String? arrival) =>
      location.searchFlights(departure, arrival);
  Future<Map<String, List<dynamic>>> globalSearch(String query) =>
      location.globalSearch(query);

  // Delegated Trip Methods
  Future<Trip> bookTrip({
    required String destinationId,
    String? date,
    String? guests,
    double? totalPrice,
  }) => tripsService.bookTrip(
    destinationId: destinationId,
    date: date,
    guests: guests,
    totalPrice: totalPrice,
  );
  Future<Trip> cancelTrip(String tripId) => tripsService.cancelTrip(tripId);
  Future<Trip> bookFlight({
    required String flightId,
    required String date,
    required String guests,
  }) => tripsService.bookFlight(flightId: flightId, date: date, guests: guests);
  Future<Trip> bookHotel({
    required String roomId,
    required String checkIn,
    required String checkOut,
    required String guests,
  }) => tripsService.bookHotel(
    roomId: roomId,
    checkIn: checkIn,
    checkOut: checkOut,
    guests: guests,
  );
  Future<Trip> bookTour({
    required String tourId,
    required String date,
    required String guests,
    double? totalPrice,
  }) => tripsService.bookTour(
    tourId: tourId,
    date: date,
    guests: guests,
    totalPrice: totalPrice,
  );
  Future<TripSchedule> fetchTripSchedule(String tripId) =>
      tripsService.fetchTripSchedule(tripId);
  Future<Map<String, TripSchedule>> fetchTripSchedulesBatch(
    List<String> tripIds,
  ) => tripsService.fetchTripSchedulesBatch(tripIds);
  Future<TripSchedule> fetchTourSchedule(String tourId) =>
      tripsService.fetchTourSchedule(tourId);

  // Delegated Document Methods
  Future<DocumentItem> addDocument({
    required String title,
    required String description,
    required String icon,
    required String color,
  }) => documentsService.addDocument(
    title: title,
    description: description,
    icon: icon,
    color: color,
  );
  Future<bool> deleteDocument(String documentId) =>
      documentsService.deleteDocument(documentId);

  // Delegated Review Methods
  Future<ReviewResponse> getReviews({
    required String targetType,
    required String targetId,
    String? cursor,
    int limit = 20,
  }) => reviews.getReviews(
    targetType: targetType,
    targetId: targetId,
    cursor: cursor,
    limit: limit,
  );
  Future<Review> createReview({
    required String targetType,
    required String targetId,
    required int rating,
    required String comment,
  }) => reviews.createReview(
    targetType: targetType,
    targetId: targetId,
    rating: rating,
    comment: comment,
  );
  Future<bool> deleteReview(String reviewId) => reviews.deleteReview(reviewId);

  // Delegated Payment Methods
  Future<Map<String, dynamic>> checkPromoCode(String code) =>
      payment.checkPromoCode(code);
  Future<Map<String, dynamic>> createVnpayPayment({
    required String tripId,
    required double amount,
    String? orderInfo,
    String? locale,
  }) => payment.createVnpayPayment(
    tripId: tripId,
    amount: amount,
    orderInfo: orderInfo,
    locale: locale,
  );
  Future<Map<String, dynamic>> checkPaymentStatus(String tripId) =>
      payment.checkPaymentStatus(tripId);
  Future<Map<String, dynamic>> createMomoPayment({
    required String tripId,
    required double amount,
    String? orderInfo,
  }) => payment.createMomoPayment(
    tripId: tripId,
    amount: amount,
    orderInfo: orderInfo,
  );

  // Delegated Partner Methods
  Future<List<Hotel>> getPartnerHotels() => partner.getPartnerHotels();
  Future<Hotel> createPartnerHotel(Map<String, dynamic> data) =>
      partner.createPartnerHotel(data);
  Future<List<TourPackage>> getPartnerTours() => partner.getPartnerTours();
  Future<TourPackage> createPartnerTour(Map<String, dynamic> data) =>
      partner.createPartnerTour(data);
  Future<Hotel> updatePartnerHotel(String id, Map<String, dynamic> data) =>
      partner.updatePartnerHotel(id, data);
  Future<void> deletePartnerHotel(String id) => partner.deletePartnerHotel(id);
  Future<TourPackage> updatePartnerTour(String id, Map<String, dynamic> data) =>
      partner.updatePartnerTour(id, data);
  Future<void> deletePartnerTour(String id) => partner.deletePartnerTour(id);
  Future<Map<String, dynamic>> getPartnerStats() => partner.getPartnerStats();
  Future<List<Room>> getPartnerHotelRooms(String hotelId) =>
      partner.getPartnerHotelRooms(hotelId);
  Future<Room> createPartnerRoom(String hotelId, Map<String, dynamic> data) =>
      partner.createPartnerRoom(hotelId, data);
  Future<void> updatePartnerRoom(
    String hotelId,
    String roomId,
    Map<String, dynamic> data,
  ) => partner.updatePartnerRoom(hotelId, roomId, data);
  Future<void> deletePartnerRoom(String hotelId, String roomId) =>
      partner.deletePartnerRoom(hotelId, roomId);

  Future<void> flushRequest(
    String method,
    String path,
    Map<String, dynamic>? body,
  ) async {
    await _client.flushRequest(method, path, body);
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
