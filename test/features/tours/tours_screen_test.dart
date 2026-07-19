import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:online_travel_agent/features/tours/application/tour_provider.dart';
import 'package:online_travel_agent/features/tours/domain/tour_package.dart';
import 'package:online_travel_agent/features/tours/presentation/tours_screen.dart';

TourPackage _tour({
  required String id,
  required String name,
  required String departure,
}) {
  return TourPackage(
    id: id,
    name: name,
    description: '',
    imagePath: '',
    duration: '3N/2D',
    price: 100,
    destinations: const [],
    includes: const [],
    departure: departure,
  );
}

void main() {
  testWidgets('applies and removes a tour departure filter from the catalog', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          toursProvider.overrideWithValue([
            _tour(id: 'hanoi', name: 'Hanoi Tour', departure: 'HAN'),
            _tour(id: 'saigon', name: 'Saigon Tour', departure: 'SGN'),
          ]),
        ],
        child: const MaterialApp(home: ToursScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('tour-filter-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'SGN'));
    await tester.tap(find.byKey(const Key('tour-filter-apply')));
    await tester.pumpAndSettle();

    expect(find.text('Saigon Tour'), findsOneWidget);
    expect(find.text('Hanoi Tour'), findsNothing);

    await tester.tap(find.byKey(const Key('tour-active-departure')));
    await tester.pumpAndSettle();

    expect(find.text('Saigon Tour'), findsOneWidget);
    expect(find.text('Hanoi Tour'), findsOneWidget);
  });
}
