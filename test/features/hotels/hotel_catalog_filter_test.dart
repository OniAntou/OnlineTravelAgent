import 'package:flutter_test/flutter_test.dart';
import 'package:online_travel_agent/features/hotels/application/hotel_catalog_filter.dart';
import 'package:online_travel_agent/features/hotels/domain/hotel.dart';
import 'package:online_travel_agent/features/hotels/domain/room.dart';

Hotel _hotel({
  required String id,
  required String location,
  String? name,
  String address = '',
  double priceFrom = 100,
  List<Room> rooms = const [],
}) {
  return Hotel(
    id: id,
    name: name ?? 'Hotel $id',
    location: location,
    latitude: 0,
    longitude: 0,
    rating: '0',
    imagePath: '',
    description: '',
    priceFrom: priceFrom,
    address: address,
    amenities: const [],
    rooms: rooms,
  );
}

const _room = Room(
  id: 'room-1',
  hotelId: 'hotel-1',
  name: 'Room',
  description: '',
  price: 100,
  capacity: 2,
  imagePath: '',
  amenities: [],
);

void main() {
  test('derives sorted unique non-empty location facets from the catalog', () {
    final locations = hotelLocations([
      _hotel(id: 'one', location: 'Da Nang, VN'),
      _hotel(id: 'two', location: 'Nha Trang, VN'),
      _hotel(id: 'three', location: 'Da Nang, VN'),
      _hotel(id: 'four', location: '   '),
    ]);

    expect(locations, ['Da Nang, VN', 'Nha Trang, VN']);
  });

  test('derives the price ceiling from the highest catalog price', () {
    expect(
      hotelMaximumPrice([
        _hotel(id: 'cheap', location: 'Da Nang, VN'),
        _hotel(id: 'expensive', location: 'Da Nang, VN', priceFrom: 900),
      ]),
      900,
    );
  });

  test('can clear a single active filter without resetting the others', () {
    const active = HotelCatalogFilter(
      location: 'Nha Trang, VN',
      maximumPrice: 500,
      onlyWithRooms: true,
    );

    final updated = active.copyWith(clearMaximumPrice: true);

    expect(updated.location, 'Nha Trang, VN');
    expect(updated.maximumPrice, isNull);
    expect(updated.onlyWithRooms, isTrue);
  });

  test('identifies the default filter state', () {
    expect(const HotelCatalogFilter().isDefault, isTrue);
    expect(const HotelCatalogFilter(onlyWithRooms: true).isDefault, isFalse);
  });

  test('filters hotels by the selected live location', () {
    final results = filterHotels(
      [
        _hotel(id: 'nha-trang', location: 'Nha Trang, VN'),
        _hotel(id: 'da-nang', location: 'Da Nang, VN'),
      ],
      query: '',
      filter: const HotelCatalogFilter(location: 'Nha Trang, VN'),
    );

    expect(results.map((hotel) => hotel.id), ['nha-trang']);
  });

  test('matches a text query against hotel name, location, or address', () {
    final results = filterHotels(
      [
        _hotel(
          id: 'beach',
          name: 'Beach Retreat',
          location: 'Nha Trang, VN',
          address: 'Tran Phu Street',
        ),
        _hotel(
          id: 'city',
          name: 'City Stay',
          location: 'Da Nang, VN',
          address: 'Bach Dang Street',
        ),
      ],
      query: 'tran phu',
      filter: const HotelCatalogFilter(),
    );

    expect(results.map((hotel) => hotel.id), ['beach']);
  });

  test('keeps hotels priced at or below the selected maximum', () {
    final results = filterHotels(
      [
        _hotel(id: 'included', location: 'Nha Trang, VN', priceFrom: 500),
        _hotel(id: 'excluded', location: 'Nha Trang, VN', priceFrom: 501),
      ],
      query: '',
      filter: const HotelCatalogFilter(maximumPrice: 500),
    );

    expect(results.map((hotel) => hotel.id), ['included']);
  });

  test('can require hotels that still expose at least one room', () {
    final results = filterHotels(
      [
        _hotel(id: 'available', location: 'Nha Trang, VN', rooms: [_room]),
        _hotel(id: 'empty', location: 'Nha Trang, VN'),
      ],
      query: '',
      filter: const HotelCatalogFilter(onlyWithRooms: true),
    );

    expect(results.map((hotel) => hotel.id), ['available']);
  });

  test('sorts the filtered hotels by price from low to high', () {
    final results = filterHotels(
      [
        _hotel(id: 'expensive', location: 'Nha Trang, VN', priceFrom: 900),
        _hotel(id: 'cheap', location: 'Nha Trang, VN'),
      ],
      query: '',
      filter: const HotelCatalogFilter(sort: HotelCatalogSort.priceAscending),
    );

    expect(results.map((hotel) => hotel.id), ['cheap', 'expensive']);
  });

  test('sorts the filtered hotels by price from high to low', () {
    final results = filterHotels(
      [
        _hotel(id: 'cheap', location: 'Nha Trang, VN'),
        _hotel(id: 'expensive', location: 'Nha Trang, VN', priceFrom: 900),
      ],
      query: '',
      filter: const HotelCatalogFilter(sort: HotelCatalogSort.priceDescending),
    );

    expect(results.map((hotel) => hotel.id), ['expensive', 'cheap']);
  });

  test('sorts the filtered hotels by available room count', () {
    final results = filterHotels(
      [
        _hotel(id: 'one-room', location: 'Nha Trang, VN', rooms: [_room]),
        _hotel(
          id: 'two-rooms',
          location: 'Nha Trang, VN',
          rooms: [_room, _room],
        ),
      ],
      query: '',
      filter: const HotelCatalogFilter(
        sort: HotelCatalogSort.roomCountDescending,
      ),
    );

    expect(results.map((hotel) => hotel.id), ['two-rooms', 'one-room']);
  });
}
