import '../domain/tour_package.dart';

enum TourDurationBucket { any, twoToThreeDays, fourDaysOrMore }

enum TourCatalogSort {
  recommended,
  priceAscending,
  priceDescending,
  durationAscending,
  durationDescending,
}

class TourCatalogFilter {
  const TourCatalogFilter({
    this.departure,
    this.maximumPrice,
    this.durationBucket = TourDurationBucket.any,
    this.popularOnly = false,
    this.sort = TourCatalogSort.recommended,
  });

  final String? departure;
  final double? maximumPrice;
  final TourDurationBucket durationBucket;
  final bool popularOnly;
  final TourCatalogSort sort;

  bool get isDefault =>
      departure == null &&
      maximumPrice == null &&
      durationBucket == TourDurationBucket.any &&
      !popularOnly &&
      sort == TourCatalogSort.recommended;

  TourCatalogFilter copyWith({
    String? departure,
    bool clearDeparture = false,
    double? maximumPrice,
    bool clearMaximumPrice = false,
    TourDurationBucket? durationBucket,
    bool? popularOnly,
    TourCatalogSort? sort,
  }) {
    return TourCatalogFilter(
      departure: clearDeparture ? null : departure ?? this.departure,
      maximumPrice: clearMaximumPrice
          ? null
          : maximumPrice ?? this.maximumPrice,
      durationBucket: durationBucket ?? this.durationBucket,
      popularOnly: popularOnly ?? this.popularOnly,
      sort: sort ?? this.sort,
    );
  }
}

List<String> tourDepartures(Iterable<TourPackage> tours) {
  final departures = {
    for (final tour in tours)
      if (tour.departure.trim().isNotEmpty) tour.departure,
  }.toList();
  departures.sort();
  return departures;
}

double tourMaximumPrice(Iterable<TourPackage> tours) {
  var maximum = 0.0;
  for (final tour in tours) {
    if (tour.price > maximum) maximum = tour.price;
  }
  return maximum;
}

int? tourDurationDays(String duration) {
  final match = RegExp(
    r'^\s*(\d+)\s*N',
    caseSensitive: false,
  ).firstMatch(duration);
  return match == null ? null : int.tryParse(match.group(1)!);
}

List<TourPackage> filterTours(
  Iterable<TourPackage> tours, {
  required String query,
  required TourCatalogFilter filter,
}) {
  final normalizedQuery = query.trim().toLowerCase();

  final filtered = <_IndexedTour>[];
  var index = 0;
  for (final tour in tours) {
    final days = tourDurationDays(tour.duration);
    final matchesDuration = switch (filter.durationBucket) {
      TourDurationBucket.any => true,
      TourDurationBucket.twoToThreeDays =>
        days != null && days >= 2 && days <= 3,
      TourDurationBucket.fourDaysOrMore => days != null && days >= 4,
    };
    final matchesDeparture =
        filter.departure == null || tour.departure == filter.departure;
    final matchesPrice =
        filter.maximumPrice == null || tour.price <= filter.maximumPrice!;
    final matchesPopularity = !filter.popularOnly || tour.isPopular;
    final matchesQuery =
        normalizedQuery.isEmpty ||
        tour.name.toLowerCase().contains(normalizedQuery) ||
        tour.departure.toLowerCase().contains(normalizedQuery) ||
        tour.destinations.any(
          (destination) => destination.toLowerCase().contains(normalizedQuery),
        );
    if (matchesDuration &&
        matchesDeparture &&
        matchesPrice &&
        matchesPopularity &&
        matchesQuery) {
      filtered.add(_IndexedTour(index, tour));
    }
    index++;
  }

  filtered.sort((left, right) {
    final result = switch (filter.sort) {
      TourCatalogSort.recommended => (right.tour.isPopular ? 1 : 0).compareTo(
        left.tour.isPopular ? 1 : 0,
      ),
      TourCatalogSort.priceAscending => left.tour.price.compareTo(
        right.tour.price,
      ),
      TourCatalogSort.priceDescending => right.tour.price.compareTo(
        left.tour.price,
      ),
      TourCatalogSort.durationAscending => _compareDurationAscending(
        left.tour,
        right.tour,
      ),
      TourCatalogSort.durationDescending => _compareDurationDescending(
        left.tour,
        right.tour,
      ),
    };
    return result != 0 ? result : left.index.compareTo(right.index);
  });

  return filtered.map((entry) => entry.tour).toList();
}

class _IndexedTour {
  const _IndexedTour(this.index, this.tour);

  final int index;
  final TourPackage tour;
}

int _compareDurationAscending(TourPackage left, TourPackage right) {
  final leftDays = tourDurationDays(left.duration);
  final rightDays = tourDurationDays(right.duration);
  if (leftDays == null && rightDays == null) return 0;
  if (leftDays == null) return 1;
  if (rightDays == null) return -1;
  return leftDays.compareTo(rightDays);
}

int _compareDurationDescending(TourPackage left, TourPackage right) {
  final leftDays = tourDurationDays(left.duration);
  final rightDays = tourDurationDays(right.duration);
  if (leftDays == null && rightDays == null) return 0;
  if (leftDays == null) return 1;
  if (rightDays == null) return -1;
  return rightDays.compareTo(leftDays);
}
