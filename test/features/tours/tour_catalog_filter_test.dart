import 'package:flutter_test/flutter_test.dart';
import 'package:online_travel_agent/features/tours/application/tour_catalog_filter.dart';
import 'package:online_travel_agent/features/tours/domain/tour_package.dart';

TourPackage _tour({
  required String id,
  required String duration,
  String? name,
  String departure = 'HAN',
  double price = 100,
  bool isPopular = false,
  List<String> destinations = const [],
}) {
  return TourPackage(
    id: id,
    name: name ?? 'Tour $id',
    description: '',
    imagePath: '',
    duration: duration,
    price: price,
    destinations: destinations,
    includes: const [],
    departure: departure,
    isPopular: isPopular,
  );
}

void main() {
  test('derives sorted unique non-empty departure facets from the catalog', () {
    final departures = tourDepartures([
      _tour(id: 'hanoi', duration: '3N/2D'),
      _tour(id: 'saigon', duration: '3N/2D', departure: 'SGN'),
      _tour(id: 'hanoi-again', duration: '3N/2D'),
      _tour(id: 'blank', duration: '3N/2D', departure: '  '),
    ]);

    expect(departures, ['HAN', 'SGN']);
  });

  test('derives the price ceiling from the highest catalog price', () {
    expect(
      tourMaximumPrice([
        _tour(id: 'cheap', duration: '3N/2D'),
        _tour(id: 'expensive', duration: '3N/2D', price: 900),
      ]),
      900,
    );
  });

  test(
    'can clear a single active tour filter without resetting the others',
    () {
      const active = TourCatalogFilter(
        departure: 'SGN',
        maximumPrice: 500,
        durationBucket: TourDurationBucket.fourDaysOrMore,
        popularOnly: true,
      );

      final updated = active.copyWith(clearMaximumPrice: true);

      expect(updated.departure, 'SGN');
      expect(updated.maximumPrice, isNull);
      expect(updated.durationBucket, TourDurationBucket.fourDaysOrMore);
      expect(updated.popularOnly, isTrue);
    },
  );

  test('identifies the default tour filter state', () {
    expect(const TourCatalogFilter().isDefault, isTrue);
    expect(
      const TourCatalogFilter(
        durationBucket: TourDurationBucket.twoToThreeDays,
      ).isDefault,
      isFalse,
    );
  });

  test('parses a leading tour day count and rejects malformed durations', () {
    expect(tourDurationDays('3N/2D'), 3);
    expect(tourDurationDays('N 3'), isNull);
  });

  test('filters tours to the selected duration bucket', () {
    final results = filterTours(
      [
        _tour(id: 'short', duration: '2N/1D'),
        _tour(id: 'long', duration: '4N/3D'),
      ],
      query: '',
      filter: const TourCatalogFilter(
        durationBucket: TourDurationBucket.twoToThreeDays,
      ),
    );

    expect(results.map((tour) => tour.id), ['short']);
  });

  test('filters tours by the selected departure', () {
    final results = filterTours(
      [
        _tour(id: 'from-hanoi', duration: '3N/2D'),
        _tour(id: 'from-saigon', duration: '3N/2D', departure: 'SGN'),
      ],
      query: '',
      filter: const TourCatalogFilter(departure: 'SGN'),
    );

    expect(results.map((tour) => tour.id), ['from-saigon']);
  });

  test('matches a text query against name, departure, or destinations', () {
    final results = filterTours(
      [
        _tour(
          id: 'bay',
          name: 'Northern escape',
          duration: '3N/2D',
          destinations: const ['Ha Long'],
        ),
        _tour(
          id: 'beach',
          name: 'Beach escape',
          duration: '3N/2D',
          destinations: const ['Nha Trang'],
        ),
      ],
      query: 'ha long',
      filter: const TourCatalogFilter(),
    );

    expect(results.map((tour) => tour.id), ['bay']);
  });

  test('keeps tours priced at or below the selected maximum', () {
    final results = filterTours(
      [
        _tour(id: 'included', duration: '3N/2D', price: 500),
        _tour(id: 'excluded', duration: '3N/2D', price: 501),
      ],
      query: '',
      filter: const TourCatalogFilter(maximumPrice: 500),
    );

    expect(results.map((tour) => tour.id), ['included']);
  });

  test('can require popular tours only', () {
    final results = filterTours(
      [
        _tour(id: 'popular', duration: '3N/2D', isPopular: true),
        _tour(id: 'regular', duration: '3N/2D'),
      ],
      query: '',
      filter: const TourCatalogFilter(popularOnly: true),
    );

    expect(results.map((tour) => tour.id), ['popular']);
  });

  test('recommended order promotes popular tours but keeps source order', () {
    final results = filterTours(
      [
        _tour(id: 'regular', duration: '3N/2D'),
        _tour(id: 'popular-first', duration: '3N/2D', isPopular: true),
        _tour(id: 'popular-second', duration: '3N/2D', isPopular: true),
      ],
      query: '',
      filter: const TourCatalogFilter(),
    );

    expect(results.map((tour) => tour.id), [
      'popular-first',
      'popular-second',
      'regular',
    ]);
  });

  test('sorts filtered tours by price from low to high', () {
    final results = filterTours(
      [
        _tour(id: 'expensive', duration: '3N/2D', price: 900),
        _tour(id: 'cheap', duration: '3N/2D'),
      ],
      query: '',
      filter: const TourCatalogFilter(sort: TourCatalogSort.priceAscending),
    );

    expect(results.map((tour) => tour.id), ['cheap', 'expensive']);
  });

  test('sorts filtered tours by price from high to low', () {
    final results = filterTours(
      [
        _tour(id: 'cheap', duration: '3N/2D'),
        _tour(id: 'expensive', duration: '3N/2D', price: 900),
      ],
      query: '',
      filter: const TourCatalogFilter(sort: TourCatalogSort.priceDescending),
    );

    expect(results.map((tour) => tour.id), ['expensive', 'cheap']);
  });

  test('sorts parseable durations before malformed durations', () {
    final results = filterTours(
      [
        _tour(id: 'long', duration: '5N/4D'),
        _tour(id: 'unknown', duration: 'contact us'),
        _tour(id: 'short', duration: '2N/1D'),
      ],
      query: '',
      filter: const TourCatalogFilter(sort: TourCatalogSort.durationAscending),
    );

    expect(results.map((tour) => tour.id), ['short', 'long', 'unknown']);
  });

  test('sorts durations from long to short without hiding malformed data', () {
    final results = filterTours(
      [
        _tour(id: 'short', duration: '2N/1D'),
        _tour(id: 'unknown', duration: 'contact us'),
        _tour(id: 'long', duration: '5N/4D'),
      ],
      query: '',
      filter: const TourCatalogFilter(sort: TourCatalogSort.durationDescending),
    );

    expect(results.map((tour) => tour.id), ['long', 'short', 'unknown']);
  });
}
