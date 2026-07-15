import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:online_travel_agent/features/tours/presentation/widgets/tour_overview_section.dart';

void main() {
  group('TourOverviewSection Widget Tests', () {
    testWidgets('TourOverviewItem renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TourOverviewItem(
              icon: Icons.access_time,
              title: 'Duration',
              value: '3 Days',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.access_time), findsOneWidget);
      expect(find.text('Duration'), findsOneWidget);
      expect(find.text('3 Days'), findsOneWidget);
    });

    testWidgets('TourOverviewDivider renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TourOverviewDivider(),
          ),
        ),
      );

      expect(find.byType(TourOverviewDivider), findsOneWidget);
    });
  });
}
