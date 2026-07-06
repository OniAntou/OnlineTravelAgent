import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_travel_agent/models/trip.dart';
import 'package:online_travel_agent/providers/trip_provider.dart';
import 'package:online_travel_agent/providers/api_provider.dart';
import 'package:online_travel_agent/providers/app_state_provider.dart';
import 'package:online_travel_agent/services/travel_api_service.dart';
import 'package:online_travel_agent/utils/api_exception.dart';
import '../helpers/test_helpers.dart';

BootstrapData emptyBootstrap() => BootstrapData(
  categories: [],
  destinations: [],
  recommended: [],
  trips: [],
  documents: [],
  hotels: [],
  tourPackages: [],
);

void main() {
  group('TripNotifier', () {
    late FakeSecureStorage fakeStorage;
    late FakeTravelApiService fakeApi;
    late ProviderContainer container;

    setUp(() {
      fakeStorage = FakeSecureStorage();
      fakeApi = FakeTravelApiService(secureStorage: fakeStorage);
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is empty trips', () {
      container = ProviderContainer(
        overrides: [
          apiProvider.overrideWithValue(fakeApi),
          bootstrapProvider.overrideWithValue(AsyncData(emptyBootstrap())),
        ],
      );
      final state = container.read(tripsProvider);
      expect(state, isEmpty);
    });

    test('addTrip adds trip to state', () {
      container = ProviderContainer(
        overrides: [
          apiProvider.overrideWithValue(fakeApi),
          bootstrapProvider.overrideWithValue(AsyncData(emptyBootstrap())),
        ],
      );
      final notifier = container.read(tripsProvider.notifier);
      const trip = Trip(
        id: '1',
        destination: 'Da Lat',
        location: 'Lam Dong',
        date: '2026-07-01',
        guests: '2 Người',
        status: 'Ongoing',
        imagePath: 'assets/images/dalat_image.jpg',
      );
      notifier.addTrip(trip);
      final state = container.read(tripsProvider);
      expect(state.length, 1);
      expect(state.first.destination, 'Da Lat');
    });

    test('addTrip prepends trip to list', () {
      container = ProviderContainer(
        overrides: [
          apiProvider.overrideWithValue(fakeApi),
          bootstrapProvider.overrideWithValue(AsyncData(emptyBootstrap())),
        ],
      );
      final notifier = container.read(tripsProvider.notifier);
      const trip1 = Trip(
        id: '1',
        destination: 'Da Lat',
        location: 'Lam Dong',
        date: '2026-07-01',
        guests: '2 Người',
        status: 'Ongoing',
        imagePath: 'assets/images/dalat_image.jpg',
      );
      const trip2 = Trip(
        id: '2',
        destination: 'Ha Noi',
        location: 'Ha Noi',
        date: '2026-08-01',
        guests: '1 Người',
        status: 'Upcoming',
        imagePath: 'assets/images/hanoi_image.png',
      );
      notifier.addTrip(trip1);
      notifier.addTrip(trip2);
      final state = container.read(tripsProvider);
      expect(state.length, 2);
      expect(state.first.destination, 'Ha Noi');
    });

    test(
      'bookTrip throws ValidationException when destinationId is null',
      () async {
        container = ProviderContainer(
          overrides: [
            apiProvider.overrideWithValue(fakeApi),
            bootstrapProvider.overrideWithValue(AsyncData(emptyBootstrap())),
          ],
        );
        final notifier = container.read(tripsProvider.notifier);
        expect(notifier.bookTrip, throwsA(isA<ValidationException>()));
      },
    );

    test('bookTrip rejects blank date and invalid guests', () async {
      container = ProviderContainer(
        overrides: [
          apiProvider.overrideWithValue(fakeApi),
          bootstrapProvider.overrideWithValue(AsyncData(emptyBootstrap())),
        ],
      );
      final notifier = container.read(tripsProvider.notifier);

      expect(
        notifier.bookTrip(destinationId: 'dest1', date: ' ', guests: '2 Người'),
        throwsA(isA<ValidationException>()),
      );
      expect(
        notifier.bookTrip(
          destinationId: 'dest1',
          date: '2026-07-01',
          guests: '0 Người',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('bookFlight rejects blank flight id and guest count', () async {
      container = ProviderContainer(
        overrides: [
          apiProvider.overrideWithValue(fakeApi),
          bootstrapProvider.overrideWithValue(AsyncData(emptyBootstrap())),
        ],
      );
      final notifier = container.read(tripsProvider.notifier);

      expect(
        notifier.bookFlight(
          flightId: ' ',
          date: '2026-07-01',
          guests: '1 Người',
        ),
        throwsA(isA<ValidationException>()),
      );
      expect(
        notifier.bookFlight(
          flightId: 'flight1',
          date: '2026-07-01',
          guests: '0 Người',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('bookHotel rejects invalid stay dates', () async {
      container = ProviderContainer(
        overrides: [
          apiProvider.overrideWithValue(fakeApi),
          bootstrapProvider.overrideWithValue(AsyncData(emptyBootstrap())),
        ],
      );
      final notifier = container.read(tripsProvider.notifier);

      expect(
        notifier.bookHotel(
          roomId: 'room1',
          checkIn: '10/08/2026',
          checkOut: '10/08/2026',
          guests: '2 Người',
        ),
        throwsA(isA<ValidationException>()),
      );
      expect(
        notifier.bookHotel(
          roomId: 'room1',
          checkIn: '31/02/2026',
          checkOut: '02/03/2026',
          guests: '2 Người',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('createCustomTour rejects incomplete summary data', () async {
      container = ProviderContainer(
        overrides: [
          apiProvider.overrideWithValue(fakeApi),
          bootstrapProvider.overrideWithValue(AsyncData(emptyBootstrap())),
        ],
      );
      final notifier = container.read(tripsProvider.notifier);

      expect(
        notifier.createCustomTour(
          destination: '',
          location: 'Da Nang',
          date: '10/08/2026',
          guests: '2 Người',
          imagePath: 'assets/images/danang.jpg',
        ),
        throwsA(isA<ValidationException>()),
      );
      expect(
        notifier.createCustomTour(
          destination: 'Da Nang',
          location: 'Da Nang',
          date: '10/08/2026',
          guests: '0 Người',
          imagePath: 'assets/images/danang.jpg',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('bookTrip adds trip on success', () async {
      container = ProviderContainer(
        overrides: [
          apiProvider.overrideWithValue(fakeApi),
          bootstrapProvider.overrideWithValue(AsyncData(emptyBootstrap())),
        ],
      );
      final notifier = container.read(tripsProvider.notifier);
      final result = await notifier.bookTrip(
        destinationId: 'dest1',
        date: '2026-07-01',
        guests: '2 Người',
        totalPrice: 5000000,
      );
      expect(result, isA<String>());
    });

    test('derived ongoingTripsProvider filters correctly', () {
      container = ProviderContainer(
        overrides: [
          apiProvider.overrideWithValue(fakeApi),
          bootstrapProvider.overrideWithValue(AsyncData(emptyBootstrap())),
        ],
      );
      final notifier = container.read(tripsProvider.notifier);
      notifier.addTrip(
        const Trip(
          id: '1',
          destination: 'A',
          location: 'B',
          date: '2026-07-01',
          guests: '1',
          status: 'Ongoing',
          imagePath: '',
        ),
      );
      notifier.addTrip(
        const Trip(
          id: '2',
          destination: 'C',
          location: 'D',
          date: '2026-08-01',
          guests: '1',
          status: 'Upcoming',
          imagePath: '',
        ),
      );
      final ongoing = container.read(ongoingTripsProvider);
      expect(ongoing.length, 1);
      expect(ongoing.first.status, 'Ongoing');
    });

    test('derived historyTripsProvider filters correctly', () {
      container = ProviderContainer(
        overrides: [
          apiProvider.overrideWithValue(fakeApi),
          bootstrapProvider.overrideWithValue(AsyncData(emptyBootstrap())),
        ],
      );
      final notifier = container.read(tripsProvider.notifier);
      notifier.addTrip(
        const Trip(
          id: '1',
          destination: 'A',
          location: 'B',
          date: '2026-01-01',
          guests: '1',
          status: 'Completed',
          imagePath: '',
          isUpcoming: false,
        ),
      );
      notifier.addTrip(
        const Trip(
          id: '2',
          destination: 'C',
          location: 'D',
          date: '2026-08-01',
          guests: '1',
          status: 'Upcoming',
          imagePath: '',
        ),
      );
      final history = container.read(historyTripsProvider);
      expect(history.length, 1);
      expect(history.first.status, 'Completed');
    });
  });
}
