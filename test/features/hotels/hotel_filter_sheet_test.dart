import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:online_travel_agent/features/hotels/application/hotel_catalog_filter.dart';
import 'package:online_travel_agent/features/hotels/presentation/widgets/hotel_filter_sheet.dart';

void main() {
  testWidgets('keeps hotel filter changes in the draft until Apply', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: _HotelSheetHarness()));

    await tester.tap(find.byKey(const Key('open-hotel-filter')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nha Trang, VN'));
    await tester.pump();
    expect(find.text('Applied: none'), findsOneWidget);

    await tester.tap(find.byKey(const Key('hotel-filter-apply')));
    await tester.pumpAndSettle();

    expect(find.text('Applied: Nha Trang, VN'), findsOneWidget);
  });

  testWidgets('resets the hotel draft before it is applied', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: _HotelSheetHarness(
          initialFilter: HotelCatalogFilter(
            location: 'Nha Trang, VN',
            maximumPrice: 500,
            onlyWithRooms: true,
            sort: HotelCatalogSort.priceDescending,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('open-hotel-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hotel-filter-reset')));
    await tester.tap(find.byKey(const Key('hotel-filter-apply')));
    await tester.pumpAndSettle();

    expect(find.text('Applied: none'), findsOneWidget);
    expect(find.text('Available: false'), findsOneWidget);
    expect(find.text('Price capped: false'), findsOneWidget);
    expect(find.text('Sort: recommended'), findsOneWidget);
  });

  testWidgets('applies the hotel availability toggle only after Apply', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: _HotelSheetHarness()));

    await tester.tap(find.byKey(const Key('open-hotel-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hotel-availability')));
    await tester.pump();
    expect(find.text('Available: false'), findsOneWidget);

    await tester.tap(find.byKey(const Key('hotel-filter-apply')));
    await tester.pumpAndSettle();

    expect(find.text('Available: true'), findsOneWidget);
  });

  testWidgets('turns a draft price selection into an applied price cap', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: _HotelSheetHarness()));

    await tester.tap(find.byKey(const Key('open-hotel-filter')));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('hotel-price-slider')),
      const Offset(-100, 0),
    );
    await tester.pump();
    expect(find.text('Price capped: false'), findsOneWidget);

    await tester.tap(find.byKey(const Key('hotel-filter-apply')));
    await tester.pumpAndSettle();

    expect(find.text('Price capped: true'), findsOneWidget);
  });

  testWidgets('applies the selected hotel sort only after Apply', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: _HotelSheetHarness()));

    await tester.tap(find.byKey(const Key('open-hotel-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hotel-sort-price-ascending')));
    await tester.pump();
    expect(find.text('Sort: none'), findsOneWidget);

    await tester.tap(find.byKey(const Key('hotel-filter-apply')));
    await tester.pumpAndSettle();

    expect(find.text('Sort: priceAscending'), findsOneWidget);
  });

  testWidgets('keeps the hotel Apply action reachable on a short screen', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 500));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: _HotelSheetHarness(
          initialFilter: HotelCatalogFilter(location: 'Nha Trang, VN'),
          locations: [
            'Very long location 1',
            'Very long location 2',
            'Very long location 3',
            'Very long location 4',
            'Very long location 5',
            'Very long location 6',
            'Nha Trang, VN',
          ],
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('open-hotel-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hotel-filter-apply')));
    await tester.pumpAndSettle();

    expect(find.text('Applied: Nha Trang, VN'), findsOneWidget);
  });
}

class _HotelSheetHarness extends StatefulWidget {
  const _HotelSheetHarness({
    this.initialFilter = const HotelCatalogFilter(),
    this.locations = const ['Da Nang, VN', 'Nha Trang, VN'],
  });

  final HotelCatalogFilter initialFilter;
  final List<String> locations;

  @override
  State<_HotelSheetHarness> createState() => _HotelSheetHarnessState();
}

class _HotelSheetHarnessState extends State<_HotelSheetHarness> {
  HotelCatalogFilter? _applied;

  Future<void> _openFilter() async {
    final result = await showHotelFilterSheet(
      context,
      initialFilter: widget.initialFilter,
      locations: widget.locations,
      catalogMaximumPrice: 1000,
    );
    if (!mounted || result == null) return;
    setState(() => _applied = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('Applied: ${_applied?.location ?? 'none'}'),
          Text('Available: ${_applied?.onlyWithRooms ?? false}'),
          Text('Price capped: ${_applied?.maximumPrice != null}'),
          Text('Sort: ${_applied?.sort.name ?? 'none'}'),
          ElevatedButton(
            key: const Key('open-hotel-filter'),
            onPressed: _openFilter,
            child: const Text('Open filter'),
          ),
        ],
      ),
    );
  }
}
