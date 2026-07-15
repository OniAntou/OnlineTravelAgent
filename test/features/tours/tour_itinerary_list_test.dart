import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:online_travel_agent/features/tours/presentation/widgets/tour_itinerary_list.dart';

void main() {
  group('TourItineraryList', () {
    testWidgets('renders itinerary correctly', (WidgetTester tester) async {
      final itinerary = [
        {
          'day': 'Ngày 1',
          'title': 'Chuyến đi bắt đầu',
          'desc': 'Mô tả ngày 1',
          'milestones': [
            {'time': '08:00', 'event': 'Bắt đầu chuyến đi'},
            {'time': '12:00', 'event': 'Ăn trưa'},
          ]
        },
        {
          'day': 'Ngày 2',
          'title': 'Kết thúc',
          'desc': '',
          'milestones': [
            {'time': '09:00', 'event': 'Trả phòng'},
          ]
        }
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TourItineraryList(itinerary: itinerary),
            ),
          ),
        ),
      );

      // Verify that days are rendered
      expect(find.text('Ngày 1'), findsOneWidget);
      expect(find.text('Ngày 2'), findsOneWidget);
      
      // Verify titles are rendered
      expect(find.text('Chuyến đi bắt đầu'), findsOneWidget);
      expect(find.text('Kết thúc'), findsOneWidget);

      // Verify desc is rendered
      expect(find.text('Mô tả ngày 1'), findsOneWidget);

      // Verify milestones are rendered
      expect(find.text('08:00'), findsOneWidget);
      expect(find.text('Bắt đầu chuyến đi'), findsOneWidget);
      expect(find.text('12:00'), findsOneWidget);
      expect(find.text('Ăn trưa'), findsOneWidget);
      expect(find.text('09:00'), findsOneWidget);
      expect(find.text('Trả phòng'), findsOneWidget);
    });

    testWidgets('renders without crashing when milestones are empty', (WidgetTester tester) async {
      final itinerary = [
        {
          'day': 'Ngày 1',
          'title': 'No milestones',
          'desc': 'Day without milestones',
          'milestones': <Map<String, dynamic>>[]
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TourItineraryList(itinerary: itinerary),
            ),
          ),
        ),
      );

      // Verify title is rendered
      expect(find.text('No milestones'), findsOneWidget);
      // No crash
    });
  });
}
