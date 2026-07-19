import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:online_travel_agent/features/tours/application/tour_catalog_filter.dart';
import 'package:online_travel_agent/features/tours/presentation/widgets/tour_filter_sheet.dart';

void main() {
  testWidgets('keeps tour filter changes in the draft until Apply', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: _TourSheetHarness()));

    await tester.tap(find.byKey(const Key('open-tour-filter')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('SGN'));
    await tester.pump();
    expect(find.text('Applied: none'), findsOneWidget);

    await tester.tap(find.byKey(const Key('tour-filter-apply')));
    await tester.pumpAndSettle();

    expect(find.text('Applied: SGN'), findsOneWidget);
  });

  testWidgets('resets the tour draft before it is applied', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: _TourSheetHarness(
          initialFilter: TourCatalogFilter(
            departure: 'SGN',
            maximumPrice: 500,
            durationBucket: TourDurationBucket.fourDaysOrMore,
            popularOnly: true,
            sort: TourCatalogSort.durationDescending,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('open-tour-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tour-filter-reset')));
    await tester.tap(find.byKey(const Key('tour-filter-apply')));
    await tester.pumpAndSettle();

    expect(find.text('Applied: none'), findsOneWidget);
    expect(find.text('Duration: none'), findsOneWidget);
    expect(find.text('Popular only: false'), findsOneWidget);
    expect(find.text('Price capped: false'), findsOneWidget);
    expect(find.text('Sort: recommended'), findsOneWidget);
  });

  testWidgets('applies the selected duration bucket only after Apply', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: _TourSheetHarness()));

    await tester.tap(find.byKey(const Key('open-tour-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tour-duration-long')));
    await tester.pump();
    expect(find.text('Duration: none'), findsOneWidget);

    await tester.tap(find.byKey(const Key('tour-filter-apply')));
    await tester.pumpAndSettle();

    expect(find.text('Duration: fourDaysOrMore'), findsOneWidget);
  });

  testWidgets('applies the popular-only toggle only after Apply', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: _TourSheetHarness()));

    await tester.tap(find.byKey(const Key('open-tour-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tour-popular-only')));
    await tester.pump();
    expect(find.text('Popular only: false'), findsOneWidget);

    await tester.tap(find.byKey(const Key('tour-filter-apply')));
    await tester.pumpAndSettle();

    expect(find.text('Popular only: true'), findsOneWidget);
  });

  testWidgets('turns a draft price selection into an applied tour price cap', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: _TourSheetHarness()));

    await tester.tap(find.byKey(const Key('open-tour-filter')));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('tour-price-slider')),
      const Offset(-100, 0),
    );
    await tester.pump();
    expect(find.text('Price capped: false'), findsOneWidget);

    await tester.tap(find.byKey(const Key('tour-filter-apply')));
    await tester.pumpAndSettle();

    expect(find.text('Price capped: true'), findsOneWidget);
  });

  testWidgets('applies the selected tour sort only after Apply', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: _TourSheetHarness()));

    await tester.tap(find.byKey(const Key('open-tour-filter')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('tour-sort-duration-ascending')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('tour-sort-duration-ascending')));
    await tester.pump();
    expect(find.text('Sort: none'), findsOneWidget);

    await tester.tap(find.byKey(const Key('tour-filter-apply')));
    await tester.pumpAndSettle();

    expect(find.text('Sort: durationAscending'), findsOneWidget);
  });

  testWidgets('keeps the tour Apply action reachable on a short screen', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 500));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MaterialApp(
        home: _TourSheetHarness(
          initialFilter: TourCatalogFilter(departure: 'SGN'),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('open-tour-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tour-filter-apply')));
    await tester.pumpAndSettle();

    expect(find.text('Applied: SGN'), findsOneWidget);
  });
}

class _TourSheetHarness extends StatefulWidget {
  const _TourSheetHarness({this.initialFilter = const TourCatalogFilter()});

  final TourCatalogFilter initialFilter;

  @override
  State<_TourSheetHarness> createState() => _TourSheetHarnessState();
}

class _TourSheetHarnessState extends State<_TourSheetHarness> {
  TourCatalogFilter? _applied;

  Future<void> _openFilter() async {
    final result = await showTourFilterSheet(
      context,
      initialFilter: widget.initialFilter,
      departures: const ['HAN', 'SGN'],
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
          Text('Applied: ${_applied?.departure ?? 'none'}'),
          Text(
            "Duration: ${_applied == null || _applied!.durationBucket == TourDurationBucket.any ? 'none' : _applied!.durationBucket.name}",
          ),
          Text('Popular only: ${_applied?.popularOnly ?? false}'),
          Text('Price capped: ${_applied?.maximumPrice != null}'),
          Text('Sort: ${_applied?.sort.name ?? 'none'}'),
          ElevatedButton(
            key: const Key('open-tour-filter'),
            onPressed: _openFilter,
            child: const Text('Open filter'),
          ),
        ],
      ),
    );
  }
}
