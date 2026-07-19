import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:online_travel_agent/features/hotels/application/hotel_provider.dart';
import 'package:online_travel_agent/features/hotels/domain/hotel.dart';
import 'package:online_travel_agent/features/hotels/presentation/hotels_screen.dart';

Hotel _hotel({
  required String id,
  required String name,
  required String location,
}) {
  return Hotel(
    id: id,
    name: name,
    location: location,
    latitude: 0,
    longitude: 0,
    rating: '0',
    imagePath: '',
    description: '',
    priceFrom: 100,
    address: '',
    amenities: const [],
  );
}

void main() {
  testWidgets('applies and removes a hotel location filter from the catalog', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hotelsProvider.overrideWithValue([
            _hotel(id: 'beach', name: 'Beach Hotel', location: 'Nha Trang, VN'),
            _hotel(id: 'city', name: 'City Hotel', location: 'Da Nang, VN'),
          ]),
        ],
        child: const MaterialApp(home: HotelsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('hotel-filter-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Nha Trang, VN'));
    await tester.tap(find.byKey(const Key('hotel-filter-apply')));
    await tester.pumpAndSettle();

    expect(find.text('Beach Hotel'), findsOneWidget);
    expect(find.text('City Hotel'), findsNothing);

    await tester.tap(find.byKey(const Key('hotel-active-location')));
    await tester.pumpAndSettle();

    expect(find.text('Beach Hotel'), findsOneWidget);
    expect(find.text('City Hotel'), findsOneWidget);
  });
}
