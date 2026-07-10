import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../models/trip.dart';
import '../utils/api_exception.dart';
import 'api_provider.dart';
import 'app_state_provider.dart';

import '../utils/trip_validator.dart';

class TripNotifier extends Notifier<List<Trip>> {
  @override
  List<Trip> build() {
    final bootstrap = ref.watch(bootstrapProvider).value;
    return bootstrap?.trips ?? [];
  }

  void addTrip(Trip trip) {
    state = [trip, ...state];
  }

  Future<String?> bookTrip({
    String? destinationId,
    String? date,
    String? guests,
    double? totalPrice,
  }) async {
    final normalizedDestinationId = TripValidator.requiredText(
      destinationId,
      'Destination ID',
    );
    final normalizedDate = TripValidator.requiredText(date, 'Ngày đi');
    final normalizedGuests = TripValidator.requiredGuests(guests);

    try {
      final trip = await ref
          .read(apiProvider)
          .bookTrip(
            destinationId: normalizedDestinationId,
            date: normalizedDate,
            guests: normalizedGuests,
            totalPrice: totalPrice,
          );
      addTrip(trip);
      return trip.id;
    } on ApiException {
      rethrow;
    } catch (e, st) {
      debugPrint('Error in bookTrip: $e\n$st');
      throw ApiException(statusCode: 500, message: getErrorMessage(e));
    }
  }

  Future<String?> bookFlight({
    required String flightId,
    required String date,
    required String guests,
  }) async {
    final normalizedFlightId = TripValidator.requiredText(flightId, 'Flight ID');
    final normalizedDate = TripValidator.requiredText(date, 'Ngày bay');
    final normalizedGuests = TripValidator.requiredGuests(guests);

    try {
      final trip = await ref
          .read(apiProvider)
          .bookFlight(
            flightId: normalizedFlightId,
            date: normalizedDate,
            guests: normalizedGuests,
          );
      addTrip(trip);
      return trip.id;
    } on ApiException {
      rethrow;
    } catch (e, st) {
      debugPrint('Error in bookFlight: $e\n$st');
      throw ApiException(statusCode: 500, message: getErrorMessage(e));
    }
  }

  Future<String?> bookHotel({
    required String roomId,
    required String checkIn,
    required String checkOut,
    required String guests,
  }) async {
    final normalizedRoomId = TripValidator.requiredText(roomId, 'Room ID');
    final normalizedCheckIn = TripValidator.requiredText(checkIn, 'Ngày nhận phòng');
    final normalizedCheckOut = TripValidator.requiredText(checkOut, 'Ngày trả phòng');
    final normalizedGuests = TripValidator.requiredGuests(guests);

    TripValidator.validateHotelStay(
      checkIn: normalizedCheckIn,
      checkOut: normalizedCheckOut,
    );

    try {
      final trip = await ref
          .read(apiProvider)
          .bookHotel(
            roomId: normalizedRoomId,
            checkIn: normalizedCheckIn,
            checkOut: normalizedCheckOut,
            guests: normalizedGuests,
          );
      addTrip(trip);
      return trip.id;
    } on ApiException {
      rethrow;
    } catch (e, st) {
      debugPrint('Error in bookHotel: $e\n$st');
      throw ApiException(statusCode: 500, message: getErrorMessage(e));
    }
  }

  Future<String?> bookTour({
    required String tourId,
    required String date,
    required String guests,
    double? totalPrice,
  }) async {
    final normalizedTourId = TripValidator.requiredText(tourId, 'Tour ID');
    final normalizedDate = TripValidator.requiredText(date, 'Ngày đi');
    final normalizedGuests = TripValidator.requiredGuests(guests);

    try {
      final trip = await ref
          .read(apiProvider)
          .bookTour(
            tourId: normalizedTourId,
            date: normalizedDate,
            guests: normalizedGuests,
            totalPrice: totalPrice,
          );
      addTrip(trip);
      return trip.id;
    } on ApiException {
      rethrow;
    } catch (e, st) {
      debugPrint('Error in bookTour: $e\n$st');
      throw ApiException(statusCode: 500, message: getErrorMessage(e));
    }
  }

  Future<String?> createCustomTour({
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
    final normalizedDestination = TripValidator.requiredText(destination, 'Điểm đến');
    final normalizedLocation = TripValidator.requiredText(location, 'Khu vực');
    final normalizedDate = TripValidator.requiredText(date, 'Ngày đi');
    final normalizedGuests = TripValidator.requiredGuests(guests);
    final normalizedImagePath = TripValidator.requiredText(imagePath, 'Ảnh đại diện');

    try {
      final trip = await ref
          .read(apiProvider)
          .createCustomTour(
            destination: normalizedDestination,
            location: normalizedLocation,
            date: normalizedDate,
            guests: normalizedGuests,
            imagePath: normalizedImagePath,
            flightIds: flightIds,
            hotelIds: hotelIds,
            roomId: roomId,
            totalPrice: totalPrice,
          );
      addTrip(trip);
      return trip.id;
    } on ApiException {
      rethrow;
    } catch (e, st) {
      debugPrint('Error in createCustomTour: $e\n$st');
      throw ApiException(statusCode: 500, message: getErrorMessage(e));
    }
  }

  Future<void> cancelTrip(String tripId) async {
    try {
      final updatedTrip = await ref.read(apiProvider).cancelTrip(tripId);
      state = state.map((t) => t.id == tripId ? updatedTrip : t).toList();
    } on ApiException {
      rethrow;
    } catch (e, st) {
      debugPrint('Error in cancelTrip: $e\n$st');
      throw ApiException(statusCode: 500, message: getErrorMessage(e));
    }
  }
}

final tripsProvider = NotifierProvider<TripNotifier, List<Trip>>(
  TripNotifier.new,
);

final ongoingTripsProvider = Provider<List<Trip>>((ref) {
  final trips = ref.watch(tripsProvider);
  return trips
      .where(
        (t) =>
            t.status.toLowerCase() ==
                AppConstants.statusOngoing.toLowerCase() ||
            t.status.toLowerCase() ==
                AppConstants.statusOngoingEn.toLowerCase(),
      )
      .toList();
});

final upcomingTripsProvider = Provider<List<Trip>>((ref) {
  final trips = ref.watch(tripsProvider);
  return trips
      .where(
        (t) =>
            t.isUpcoming &&
            t.status.toLowerCase() !=
                AppConstants.statusOngoing.toLowerCase() &&
            t.status.toLowerCase() !=
                AppConstants.statusOngoingEn.toLowerCase(),
      )
      .toList();
});

final historyTripsProvider = Provider<List<Trip>>((ref) {
  final trips = ref.watch(tripsProvider);
  return trips
      .where(
        (t) =>
            !t.isUpcoming &&
            t.status.toLowerCase() !=
                AppConstants.statusOngoing.toLowerCase() &&
            t.status.toLowerCase() !=
                AppConstants.statusOngoingEn.toLowerCase(),
      )
      .toList();
});
