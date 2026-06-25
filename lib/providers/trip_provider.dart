import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../models/trip.dart';
import '../utils/api_exception.dart';
import 'app_state_provider.dart';
import 'api_provider.dart';

class TripNotifier extends Notifier<List<Trip>> {
  @override
  List<Trip> build() {
    final bootstrap = ref.watch(bootstrapProvider).value;
    return bootstrap?.trips ?? [];
  }

  void addTrip(Trip trip) {
    state = [trip, ...state];
  }

  Future<String?> bookTrip({String? destinationId, String? date, String? guests, double? totalPrice}) async {
    if (destinationId == null) {
      throw const ValidationException(message: 'Destination ID không được để trống');
    }
    try {
      final trip = await ref.read(apiProvider).bookTrip(
        destinationId: destinationId,
        date: date,
        guests: guests,
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

  Future<String?> bookFlight({required String flightId, required String date, required String guests}) async {
    try {
      final trip = await ref.read(apiProvider).bookFlight(
        flightId: flightId, date: date, guests: guests
      );
      addTrip(trip);
      return trip.id;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(statusCode: 500, message: getErrorMessage(e));
    }
  }

  Future<String?> bookHotel({required String roomId, required String checkIn, required String checkOut, required String guests}) async {
    try {
      final trip = await ref.read(apiProvider).bookHotel(
        roomId: roomId, checkIn: checkIn, checkOut: checkOut, guests: guests
      );
      addTrip(trip);
      return trip.id;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(statusCode: 500, message: getErrorMessage(e));
    }
  }

  Future<String?> bookTour({required String tourId, required String date, required String guests, double? totalPrice}) async {
    try {
      final trip = await ref.read(apiProvider).bookTour(
        tourId: tourId, date: date, guests: guests, totalPrice: totalPrice
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
    required String destination, required String location, required String date,
    required String guests, required String imagePath,
    List<String>? flightIds, List<String>? hotelIds, String? roomId, double? totalPrice,
  }) async {
    try {
      final trip = await ref.read(apiProvider).createCustomTour(
        destination: destination, location: location, date: date,
        guests: guests, imagePath: imagePath, flightIds: flightIds,
        hotelIds: hotelIds, roomId: roomId, totalPrice: totalPrice
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

final tripsProvider = NotifierProvider<TripNotifier, List<Trip>>(TripNotifier.new);

// Derived Providers
final ongoingTripsProvider = Provider<List<Trip>>((ref) {
  final trips = ref.watch(tripsProvider);
  return trips.where((t) => 
    t.status.toLowerCase() == AppConstants.statusOngoing.toLowerCase() || 
    t.status.toLowerCase() == AppConstants.statusOngoingEn.toLowerCase()
  ).toList();
});

final upcomingTripsProvider = Provider<List<Trip>>((ref) {
  final trips = ref.watch(tripsProvider);
  return trips.where((t) => 
    t.isUpcoming && 
    t.status.toLowerCase() != AppConstants.statusOngoing.toLowerCase() && 
    t.status.toLowerCase() != AppConstants.statusOngoingEn.toLowerCase()
  ).toList();
});

final historyTripsProvider = Provider<List<Trip>>((ref) {
  final trips = ref.watch(tripsProvider);
  return trips.where((t) => 
    !t.isUpcoming && 
    t.status.toLowerCase() != AppConstants.statusOngoing.toLowerCase() && 
    t.status.toLowerCase() != AppConstants.statusOngoingEn.toLowerCase()
  ).toList();
});
