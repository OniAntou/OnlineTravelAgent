import '../domain/hotel.dart';

enum HotelCatalogSort {
  recommended,
  priceAscending,
  priceDescending,
  roomCountDescending,
}

class HotelCatalogFilter {
  const HotelCatalogFilter({
    this.location,
    this.maximumPrice,
    this.onlyWithRooms = false,
    this.sort = HotelCatalogSort.recommended,
  });

  final String? location;
  final double? maximumPrice;
  final bool onlyWithRooms;
  final HotelCatalogSort sort;

  bool get isDefault =>
      location == null &&
      maximumPrice == null &&
      !onlyWithRooms &&
      sort == HotelCatalogSort.recommended;

  HotelCatalogFilter copyWith({
    String? location,
    bool clearLocation = false,
    double? maximumPrice,
    bool clearMaximumPrice = false,
    bool? onlyWithRooms,
    HotelCatalogSort? sort,
  }) {
    return HotelCatalogFilter(
      location: clearLocation ? null : location ?? this.location,
      maximumPrice: clearMaximumPrice
          ? null
          : maximumPrice ?? this.maximumPrice,
      onlyWithRooms: onlyWithRooms ?? this.onlyWithRooms,
      sort: sort ?? this.sort,
    );
  }
}

List<String> hotelLocations(Iterable<Hotel> hotels) {
  final locations = {
    for (final hotel in hotels)
      if (hotel.location.trim().isNotEmpty) hotel.location,
  }.toList();
  locations.sort();
  return locations;
}

double hotelMaximumPrice(Iterable<Hotel> hotels) {
  var maximum = 0.0;
  for (final hotel in hotels) {
    if (hotel.priceFrom > maximum) maximum = hotel.priceFrom;
  }
  return maximum;
}

List<Hotel> filterHotels(
  Iterable<Hotel> hotels, {
  required String query,
  required HotelCatalogFilter filter,
}) {
  final normalizedQuery = query.trim().toLowerCase();

  final filtered = <_IndexedHotel>[];
  for (var index = 0; index < hotels.length; index++) {
    final hotel = hotels.elementAt(index);
    final matchesLocation =
        filter.location == null || hotel.location == filter.location;
    final matchesPrice =
        filter.maximumPrice == null || hotel.priceFrom <= filter.maximumPrice!;
    final matchesAvailability = !filter.onlyWithRooms || hotel.rooms.isNotEmpty;
    final matchesQuery =
        normalizedQuery.isEmpty ||
        hotel.name.toLowerCase().contains(normalizedQuery) ||
        hotel.location.toLowerCase().contains(normalizedQuery) ||
        hotel.address.toLowerCase().contains(normalizedQuery);

    if (matchesLocation &&
        matchesPrice &&
        matchesAvailability &&
        matchesQuery) {
      filtered.add(_IndexedHotel(index, hotel));
    }
  }

  filtered.sort((left, right) {
    final result = switch (filter.sort) {
      HotelCatalogSort.recommended => 0,
      HotelCatalogSort.priceAscending => left.hotel.priceFrom.compareTo(
        right.hotel.priceFrom,
      ),
      HotelCatalogSort.priceDescending => right.hotel.priceFrom.compareTo(
        left.hotel.priceFrom,
      ),
      HotelCatalogSort.roomCountDescending =>
        right.hotel.rooms.length.compareTo(left.hotel.rooms.length),
    };
    return result != 0 ? result : left.index.compareTo(right.index);
  });

  return filtered.map((entry) => entry.hotel).toList();
}

class _IndexedHotel {
  const _IndexedHotel(this.index, this.hotel);

  final int index;
  final Hotel hotel;
}
