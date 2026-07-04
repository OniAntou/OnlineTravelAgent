import 'package:flutter_test/flutter_test.dart';
import 'package:online_travel_agent/models/destination.dart';
import 'package:online_travel_agent/models/trip.dart';
import 'package:online_travel_agent/models/hotel.dart';
import 'package:online_travel_agent/models/room.dart';
import 'package:online_travel_agent/models/tour_package.dart';
import 'package:online_travel_agent/models/document_item.dart';

void main() {
  group('Destination', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': '1',
        'name': 'Da Lat',
        'location': 'Lam Dong',
        'rating': '4.5',
        'duration': '3 ngày',
        'imagePath': 'https://example.com/image.jpg',
        'isFavorite': true,
        'description': 'Thành phố ngàn hoa',
        'price': '500000',
        'reviewsCount': '120',
        'category': 'Ẩm thực',
        'latitude': 11.94,
        'longitude': 108.44,
      };
      final dest = Destination.fromJson(json);
      expect(dest.id, '1');
      expect(dest.name, 'Da Lat');
      expect(dest.location, 'Lam Dong');
      expect(dest.rating, '4.5');
      expect(dest.duration, '3 ngày');
      expect(dest.isFavorite, true);
      expect(dest.description, 'Thành phố ngàn hoa');
      expect(dest.price, '500000');
      expect(dest.reviewsCount, '120');
      expect(dest.category, 'Ẩm thực');
      expect(dest.latitude, 11.94);
      expect(dest.longitude, 108.44);
    });

    test('fromJson handles null/missing fields with defaults', () {
      final dest = Destination.fromJson({});
      expect(dest.id, '');
      expect(dest.name, '');
      expect(dest.isFavorite, false);
      expect(dest.description, '');
      expect(dest.price, '');
      expect(dest.reviewsCount, '0');
      expect(dest.category, 'Địa điểm');
      expect(dest.latitude, 0.0);
      expect(dest.longitude, 0.0);
    });

    test('fromJson normalizes Bãi biển to Địa điểm', () {
      final dest = Destination.fromJson({'category': 'Bãi biển'});
      expect(dest.category, 'Địa điểm');
    });

    test('copyWith creates new instance with overrides', () {
      const dest = Destination(
        id: '1', name: 'Da Lat', location: 'Lam Dong',
        rating: '4.5', duration: '3 ngày', imagePath: '',
      );
      final updated = dest.copyWith(name: 'Ha Noi', isFavorite: true);
      expect(updated.name, 'Ha Noi');
      expect(updated.isFavorite, true);
      expect(updated.id, '1');
    });

    test('toJson returns correct map', () {
      const dest = Destination(
        id: '1', name: 'Da Lat', location: 'Lam Dong',
        rating: '4.5', duration: '3 ngày', imagePath: 'img.jpg',
        latitude: 11.94, longitude: 108.44,
      );
      final json = dest.toJson();
      expect(json['id'], '1');
      expect(json['name'], 'Da Lat');
      expect(json['latitude'], 11.94);
    });
  });

  group('Trip', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 't1',
        'destination': 'Da Lat',
        'location': 'Lam Dong',
        'date': '2026-08-01',
        'guests': '2',
        'status': 'Upcoming',
        'imagePath': 'img.jpg',
        'isUpcoming': true,
        'flightId': 'FL001',
        'hotelId': 'H001',
        'roomId': 'R001',
        'totalPrice': 1500000,
        'isCustom': true,
      };
      final trip = Trip.fromJson(json);
      expect(trip.id, 't1');
      expect(trip.destination, 'Da Lat');
      expect(trip.flightId, 'FL001');
      expect(trip.hotelId, 'H001');
      expect(trip.roomId, 'R001');
      expect(trip.totalPrice, 1500000);
      expect(trip.isCustom, true);
    });

    test('fromJson handles nullable fields', () {
      final trip = Trip.fromJson({
        'id': 't1',
        'destination': 'Test',
        'location': '',
        'date': '',
        'guests': '',
        'status': '',
        'imagePath': '',
      });
      expect(trip.flightId, isNull);
      expect(trip.hotelId, isNull);
      expect(trip.roomId, isNull);
      expect(trip.totalPrice, isNull);
      expect(trip.isUpcoming, false);
      expect(trip.isCustom, false);
    });
  });

  group('Hotel', () {
    test('fromJson parses all fields including rooms', () {
      final json = {
        'id': 'h1',
        'name': 'Luxury Hotel',
        'location': 'Da Nang',
        'latitude': 16.05,
        'longitude': 108.22,
        'rating': '4.8',
        'imagePath': 'hotel.jpg',
        'description': 'Beautiful hotel',
        'priceFrom': 1200000,
        'address': '123 Beach Road',
        'amenities': ['Pool', 'Spa', 'Gym'],
        'rooms': [
          {'id': 'r1', 'name': 'Deluxe', 'price': 2000000, 'capacity': 2},
        ],
      };
      final hotel = Hotel.fromJson(json);
      expect(hotel.id, 'h1');
      expect(hotel.name, 'Luxury Hotel');
      expect(hotel.amenities, ['Pool', 'Spa', 'Gym']);
      expect(hotel.rooms.length, 1);
      expect(hotel.rooms.first.name, 'Deluxe');
    });

    test('fromJson handles missing rooms and amenities', () {
      final hotel = Hotel.fromJson({'id': 'h1', 'name': 'Test'});
      expect(hotel.rooms, isEmpty);
      expect(hotel.amenities, isEmpty);
    });
  });

  group('Room', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 'r1',
        'name': 'Standard',
        'description': 'Cozy room',
        'price': 800000,
        'capacity': 2,
        'imagePath': 'room.jpg',
        'amenities': ['WiFi', 'AC'],
      };
      final room = Room.fromJson(json);
      expect(room.id, 'r1');
      expect(room.name, 'Standard');
      expect(room.price, 800000);
      expect(room.capacity, 2);
      expect(room.amenities, ['WiFi', 'AC']);
    });
  });

  group('TourPackage', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 'tp1',
        'name': 'Ha Giang Loop',
        'description': '4 ngày 3 đêm',
        'imagePath': 'tour.jpg',
        'duration': '4N3Đ',
        'price': 4500000,
        'originalPrice': 5000000,
        'destinations': ['Ha Giang', 'Dong Van'],
        'includes': ['Xe máy', 'Homestay'],
        'departure': 'Ha Noi',
        'departureDate': '2026-09-01',
        'isPopular': true,
        'includesGuide': true,
        'guideFee': 100,
      };
      final tour = TourPackage.fromJson(json);
      expect(tour.id, 'tp1');
      expect(tour.name, 'Ha Giang Loop');
      expect(tour.price, 4500000);
      expect(tour.originalPrice, 5000000);
      expect(tour.destinations, ['Ha Giang', 'Dong Van']);
      expect(tour.includes, ['Xe máy', 'Homestay']);
      expect(tour.isPopular, true);
      expect(tour.guideFee, 100);
    });

    test('fromJson handles defaults', () {
      final tour = TourPackage.fromJson({'id': 'tp1', 'name': 'Test'});
      expect(tour.originalPrice, isNull);
      expect(tour.departureDate, isNull);
      expect(tour.isPopular, false);
      expect(tour.includesGuide, true);
      expect(tour.guideFee, 50.0);
    });
  });

  group('DocumentItem', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 'd1',
        'title': 'Passport',
        'description': 'Hộ chiếu',
        'icon': 'flight_takeoff',
        'color': '#FF5722',
      };
      final doc = DocumentItem.fromJson(json);
      expect(doc.id, 'd1');
      expect(doc.title, 'Passport');
      expect(doc.iconName, 'flight_takeoff');
      expect(doc.colorHex, '#FF5722');
    });

    test('fromJson defaults for missing icon', () {
      final doc = DocumentItem.fromJson({'id': 'd1', 'title': 'Test'});
      expect(doc.iconName, 'description');
      expect(doc.colorHex, '#176FF2');
    });
  });
}
