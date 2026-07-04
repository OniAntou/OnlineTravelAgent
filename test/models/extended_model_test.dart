import 'package:flutter_test/flutter_test.dart';
import 'package:online_travel_agent/models/flight.dart';
import 'package:online_travel_agent/models/review.dart';
import 'package:online_travel_agent/models/trip_schedule.dart';

void main() {
  group('Flight', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 'f1',
        'airline': 'VietJet',
        'airlineLogo': 'vietjet.png',
        'departure': 'HAN',
        'arrival': 'SGN',
        'departureTime': '08:00',
        'arrivalTime': '10:00',
        'price': 1500000,
        'duration': '2h',
      };
      final flight = Flight.fromJson(json);
      expect(flight.id, 'f1');
      expect(flight.airline, 'VietJet');
      expect(flight.airlineLogo, 'vietjet.png');
      expect(flight.departure, 'HAN');
      expect(flight.arrival, 'SGN');
      expect(flight.departureTime, '08:00');
      expect(flight.arrivalTime, '10:00');
      expect(flight.price, 1500000);
      expect(flight.duration, '2h');
    });

    test('fromJson handles null/missing fields with defaults', () {
      final flight = Flight.fromJson({});
      expect(flight.id, '');
      expect(flight.airline, '');
      expect(flight.price, 0);
      expect(flight.duration, '');
    });

    test('fromJson parses price as num', () {
      final flight = Flight.fromJson({'price': 1500000.5});
      expect(flight.price, 1500000);
    });
  });

  group('Review', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 'r1',
        'userId': 'u1',
        'user': {'name': 'Test User'},
        'targetType': 'destination',
        'targetId': 'd1',
        'rating': 4,
        'comment': 'Great place!',
        'createdAt': '2026-07-01T10:00:00.000Z',
      };
      final review = Review.fromJson(json);
      expect(review.id, 'r1');
      expect(review.userId, 'u1');
      expect(review.userName, 'Test User');
      expect(review.targetType, 'destination');
      expect(review.targetId, 'd1');
      expect(review.rating, 4);
      expect(review.comment, 'Great place!');
      expect(review.createdAt.year, 2026);
    });

    test('fromJson defaults for missing user', () {
      final review = Review.fromJson({'id': 'r1'});
      expect(review.userName, 'Ẩn danh');
      expect(review.rating, 5);
    });

    test('fromJson defaults for invalid date', () {
      final review = Review.fromJson({
        'id': 'r1',
        'createdAt': 'invalid-date',
      });
      expect(review.createdAt, isA<DateTime>());
    });
  });

  group('ReviewResponse', () {
    test('fromJson parses reviews list', () {
      final json = {
        'reviews': [
          {'id': 'r1', 'rating': 5, 'comment': 'Good'},
          {'id': 'r2', 'rating': 3, 'comment': 'OK'},
        ],
        'total': 2,
        'avgRating': 4.0,
      };
      final response = ReviewResponse.fromJson(json);
      expect(response.reviews.length, 2);
      expect(response.total, 2);
      expect(response.avgRating, 4.0);
    });

    test('fromJson handles empty reviews', () {
      final response = ReviewResponse.fromJson({});
      expect(response.reviews, isEmpty);
      expect(response.total, 0);
      expect(response.avgRating, 0.0);
    });
  });

  group('TripScheduleUpdate', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 'u1',
        'message': 'Flight delayed',
        'createdAt': '2026-07-01T10:00:00.000Z',
      };
      final update = TripScheduleUpdate.fromJson(json);
      expect(update.id, 'u1');
      expect(update.message, 'Flight delayed');
      expect(update.createdAt.year, 2026);
    });
  });

  group('TripScheduleItem', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 'i1',
        'title': 'Visit temple',
        'description': 'Temple of Literature',
        'startTime': '09:00',
        'endTime': '11:00',
        'location': 'Ha Noi',
        'latitude': 21.03,
        'longitude': 105.84,
        'statusOverride': 'completed',
      };
      final item = TripScheduleItem.fromJson(json);
      expect(item.id, 'i1');
      expect(item.title, 'Visit temple');
      expect(item.description, 'Temple of Literature');
      expect(item.startTime, '09:00');
      expect(item.endTime, '11:00');
      expect(item.location, 'Ha Noi');
      expect(item.latitude, 21.03);
      expect(item.longitude, 105.84);
      expect(item.statusOverride, 'completed');
    });

    test('fromJson handles nullable fields', () {
      final item = TripScheduleItem.fromJson({
        'id': 'i1',
        'title': 'Test',
        'startTime': '09:00',
      });
      expect(item.description, '');
      expect(item.endTime, '');
      expect(item.location, '');
      expect(item.latitude, isNull);
      expect(item.longitude, isNull);
      expect(item.statusOverride, isNull);
    });

    test('fromJson uses locationName as fallback', () {
      final item = TripScheduleItem.fromJson({
        'id': 'i1',
        'title': 'Test',
        'startTime': '09:00',
        'locationName': 'Fallback Location',
      });
      expect(item.location, 'Fallback Location');
    });
  });

  group('TripScheduleDay', () {
    test('fromJson parses all fields with items', () {
      final json = {
        'id': 'day1',
        'dayNumber': 1,
        'date': '2026-08-01',
        'items': [
          {'id': 'i1', 'title': 'Activity 1', 'startTime': '09:00'},
        ],
      };
      final day = TripScheduleDay.fromJson(json);
      expect(day.id, 'day1');
      expect(day.dayNumber, 1);
      expect(day.date, '2026-08-01');
      expect(day.items.length, 1);
      expect(day.items.first.title, 'Activity 1');
    });

    test('fromJson handles null items', () {
      final day = TripScheduleDay.fromJson({
        'id': 'day1',
        'dayNumber': 1,
      });
      expect(day.items, isEmpty);
      expect(day.date, isNull);
    });
  });

  group('TripSchedule', () {
    test('fromJson parses all fields', () {
      final json = {
        'tripId': 't1',
        'days': [
          {'id': 'day1', 'dayNumber': 1, 'items': []},
        ],
        'updates': [
          {'id': 'u1', 'message': 'Update', 'createdAt': '2026-07-01T10:00:00.000Z'},
        ],
      };
      final schedule = TripSchedule.fromJson(json);
      expect(schedule.tripId, 't1');
      expect(schedule.days.length, 1);
      expect(schedule.updates.length, 1);
    });

    test('fromJson handles null days and updates', () {
      final schedule = TripSchedule.fromJson({'tripId': 't1'});
      expect(schedule.days, isEmpty);
      expect(schedule.updates, isEmpty);
    });
  });
}
