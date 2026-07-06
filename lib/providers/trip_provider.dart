import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../models/trip.dart';
import '../utils/api_exception.dart';
import 'api_provider.dart';
import 'app_state_provider.dart';

String _requiredText(String? value, String field) {
  final normalized = value?.trim() ?? '';
  if (normalized.isEmpty) {
    throw ValidationException(message: '$field không được để trống');
  }
  return normalized;
}

String _requiredGuests(String? guests) {
  final normalized = _requiredText(guests, 'Số khách');
  if (!RegExp(r'[1-9]\d*').hasMatch(normalized)) {
    throw const ValidationException(message: 'Số khách phải lớn hơn 0');
  }
  return normalized;
}

DateTime _requiredDate(String value, String field) {
  final parsed = _parseDate(value);
  if (parsed == null) {
    throw ValidationException(message: '$field không hợp lệ');
  }
  return parsed;
}

DateTime? _parseDate(String value) {
  final normalized = value.trim();
  final vietnameseDate = RegExp(
    r'^(\d{1,2})/(\d{1,2})/(\d{4})$',
  ).firstMatch(normalized);

  if (vietnameseDate != null) {
    final day = int.parse(vietnameseDate.group(1)!);
    final month = int.parse(vietnameseDate.group(2)!);
    final year = int.parse(vietnameseDate.group(3)!);
    final date = DateTime(year, month, day);
    if (date.year == year && date.month == month && date.day == day) {
      return date;
    }
    return null;
  }

  final isoDate = DateTime.tryParse(normalized);
  if (isoDate == null) return null;
  return DateTime(isoDate.year, isoDate.month, isoDate.day);
}

void _validateHotelStay({required String checkIn, required String checkOut}) {
  final checkInDate = _requiredDate(checkIn, 'Ngày nhận phòng');
  final checkOutDate = _requiredDate(checkOut, 'Ngày trả phòng');

  if (!checkOutDate.isAfter(checkInDate)) {
    throw const ValidationException(
      message: 'Ngày trả phòng phải sau ngày nhận phòng',
    );
  }
}

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
    final normalizedDestinationId = _requiredText(
      destinationId,
      'Destination ID',
    );
    final normalizedDate = _requiredText(date, 'Ngày đi');
    final normalizedGuests = _requiredGuests(guests);

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
    } catch (e) {
      throw ApiException(statusCode: 500, message: getErrorMessage(e));
    }
  }

  Future<String?> bookFlight({
    required String flightId,
    required String date,
    required String guests,
  }) async {
    final normalizedFlightId = _requiredText(flightId, 'Flight ID');
    final normalizedDate = _requiredText(date, 'Ngày bay');
    final normalizedGuests = _requiredGuests(guests);

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
    } catch (e) {
      throw ApiException(statusCode: 500, message: getErrorMessage(e));
    }
  }

  Future<String?> bookHotel({
    required String roomId,
    required String checkIn,
    required String checkOut,
    required String guests,
  }) async {
    final normalizedRoomId = _requiredText(roomId, 'Room ID');
    final normalizedCheckIn = _requiredText(checkIn, 'Ngày nhận phòng');
    final normalizedCheckOut = _requiredText(checkOut, 'Ngày trả phòng');
    final normalizedGuests = _requiredGuests(guests);

    _validateHotelStay(
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
    } catch (e) {
      throw ApiException(statusCode: 500, message: getErrorMessage(e));
    }
  }

  Future<String?> bookTour({
    required String tourId,
    required String date,
    required String guests,
    double? totalPrice,
  }) async {
    final normalizedTourId = _requiredText(tourId, 'Tour ID');
    final normalizedDate = _requiredText(date, 'Ngày đi');
    final normalizedGuests = _requiredGuests(guests);

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
    } catch (e) {
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
    final normalizedDestination = _requiredText(destination, 'Điểm đến');
    final normalizedLocation = _requiredText(location, 'Khu vực');
    final normalizedDate = _requiredText(date, 'Ngày đi');
    final normalizedGuests = _requiredGuests(guests);
    final normalizedImagePath = _requiredText(imagePath, 'Ảnh đại diện');

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
    } catch (e) {
      throw ApiException(statusCode: 500, message: getErrorMessage(e));
    }
  }

  Future<void> cancelTrip(String tripId) async {
    try {
      final updatedTrip = await ref.read(apiProvider).cancelTrip(tripId);
      state = state.map((t) => t.id == tripId ? updatedTrip : t).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
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
