import 'package:flutter_test/flutter_test.dart';
import 'package:online_travel_agent/features/flights/domain/flight.dart';
import 'package:online_travel_agent/features/hotels/domain/hotel.dart';
import 'package:online_travel_agent/features/hotels/domain/room.dart';
import 'package:online_travel_agent/features/tours/domain/tour_package.dart';
import 'package:online_travel_agent/features/trips/domain/trip.dart';

void main() {
  group('Decimal JSON parsing', () {
    test('parses Decimal strings from the bootstrap response', () {
      final hotel = Hotel.fromJson({
        'priceFrom': '1250000.50',
        'rooms': [
          {'price': '1500000.00', 'capacity': '2'},
        ],
      });
      final tour = TourPackage.fromJson({
        'price': '2500000.00',
        'originalPrice': '3000000.00',
        'guideFee': '50.00',
      });
      final flight = Flight.fromJson({'price': '1750000.00'});
      final trip = Trip.fromJson({'totalPrice': '4250000.00'});

      expect(hotel.priceFrom, 1250000.5);
      expect(hotel.rooms.single.price, 1500000.0);
      expect(hotel.rooms.single.capacity, 2);
      expect(tour.price, 2500000.0);
      expect(tour.originalPrice, 3000000.0);
      expect(tour.guideFee, 50.0);
      expect(flight.price, 1750000);
      expect(trip.totalPrice, 4250000.0);
    });

    test('keeps numeric payload compatibility', () {
      final room = Room.fromJson({'price': 500000, 'capacity': 3});

      expect(room.price, 500000.0);
      expect(room.capacity, 3);
    });
  });
}
