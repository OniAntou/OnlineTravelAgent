import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../models/destination.dart';
import '../models/hotel.dart';
import '../models/tour_package.dart';
import '../models/document_item.dart';
import '../models/trip.dart';
import '../models/trip_schedule.dart';
import '../services/travel_api_service.dart';
import '../providers/api_provider.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref);
});

class SyncService {
  final Ref _ref;
  Timer? _periodicTimer;
  AppDatabase? _db;

  static const _syncInterval = Duration(minutes: 5);
  bool _isSyncing = false;
  DateTime? _lastSync;

  SyncService(this._ref, {AppDatabase? db}) : _db = db;

  AppDatabase get db => _db ??= AppDatabase.instance();

  void startPeriodicSync() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(_syncInterval, (_) {
      syncAll();
    });
  }

  void stopPeriodicSync() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  Future<void> syncAll() async {
    if (_isSyncing) return;

    if (_lastSync != null && DateTime.now().difference(_lastSync!) < const Duration(minutes: 1)) {
      return;
    }

    _isSyncing = true;
    _lastSync = DateTime.now();

    try {
      await _flushOfflineQueue();

      final api = _ref.read(apiProvider);
      final data = await api.fetchBootstrap();

      await _syncDestinations(data.destinations, data.recommended);
      await _syncCategories(data.categories);
      await _syncHotels(data.hotels);
      await _syncTours(data.tourPackages);
      await _syncDocuments(data.documents);
      await _syncTrips(data.trips);

      // Sync schedules for each trip
      for (final trip in data.trips) {
        try {
          final schedule = await api.fetchTripSchedule(trip.id);
          await _syncSchedule(trip.id, schedule);
        } catch (e, st) {
          debugPrint('Sync schedule error: $e\n$st');
        }
      }
    } catch (e, st) {
      debugPrint('SyncAll error: $e\n$st');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _flushOfflineQueue() async {
    final queue = await db.offlineQueueDao.getAll();
    if (queue.isEmpty) return;

    final api = _ref.read(apiProvider);
    for (final item in queue) {
      try {
        final body = item.bodyJson != null ? jsonDecode(item.bodyJson!) as Map<String, dynamic> : null;
        await api.flushRequest(item.method, item.endpoint, body);
        await db.offlineQueueDao.deleteItem(item.id);
      } catch (e, st) {
        debugPrint('Failed to flush queue item ${item.id}: $e\n$st');
      }
    }
  }

  Future<void> _syncDestinations(
    List<Destination> destinations,
    List<Destination> recommended,
  ) async {
    final recommendedIds = recommended.map((d) => d.id).toSet();

    await db.destinationsDao.insertAll(
      destinations
          .map(
            (d) => DestinationsTableCompanion.insert(
              id: d.id,
              name: d.name,
              location: d.location,
              rating: Value(d.rating),
              duration: Value(d.duration),
              imagePath: Value(d.imagePath),
              isFavorite: Value(d.isFavorite),
              description: Value(d.description),
              price: Value(d.price),
              reviewsCount: Value(d.reviewsCount),
              category: Value(d.category),
              latitude: Value(d.latitude),
              longitude: Value(d.longitude),
              isRecommended: Value(recommendedIds.contains(d.id)),
            ),
          )
          .toList(),
    );
  }

  Future<void> _syncCategories(List<String> categories) async {
    await db.categoriesDao.insertAll(
      categories
          .map((c) => CategoriesTableCompanion.insert(id: c, name: Value(c)))
          .toList(),
    );
  }

  Future<void> _syncHotels(List<Hotel> hotels) async {
    final hotelCompanions = <HotelsTableCompanion>[];
    final roomCompanions = <RoomsTableCompanion>[];

    for (final h in hotels) {
      hotelCompanions.add(
        HotelsTableCompanion.insert(
          id: h.id,
          name: h.name,
          location: h.location,
          latitude: Value(h.latitude),
          longitude: Value(h.longitude),
          rating: Value(h.rating),
          imagePath: Value(h.imagePath),
          description: Value(h.description),
          priceFrom: Value(h.priceFrom),
          address: Value(h.address),
          amenities: Value(jsonEncode(h.amenities)),
        ),
      );

      for (final r in h.rooms) {
        roomCompanions.add(
          RoomsTableCompanion.insert(
            id: r.id,
            hotelId: h.id,
            name: r.name,
            description: Value(r.description),
            price: Value(r.price),
            capacity: Value(r.capacity),
            imagePath: Value(r.imagePath),
            amenities: Value(jsonEncode(r.amenities)),
          ),
        );
      }
    }

    await db.hotelsDao.insertAll(hotelCompanions, roomCompanions);
  }

  Future<void> _syncTours(List<TourPackage> tours) async {
    await db.tourPackagesDao.insertAll(
      tours
          .map(
            (t) => TourPackagesTableCompanion.insert(
              id: t.id,
              name: t.name,
              description: Value(t.description),
              imagePath: Value(t.imagePath),
              duration: Value(t.duration),
              price: Value(t.price),
              originalPrice: Value(t.originalPrice),
              destinations: Value(jsonEncode(t.destinations)),
              includes: Value(jsonEncode(t.includes)),
              departure: Value(t.departure),
              departureDate: Value(t.departureDate),
              isPopular: Value(t.isPopular),
              includesGuide: Value(t.includesGuide),
              guideFee: Value(t.guideFee),
            ),
          )
          .toList(),
    );
  }

  Future<void> _syncDocuments(List<DocumentItem> documents) async {
    await db.documentsDao.insertAll(
      documents
          .map(
            (d) => DocumentsTableCompanion.insert(
              id: d.id,
              title: d.title,
              description: Value(d.description),
              iconName: Value(d.iconName),
              colorHex: Value(d.colorHex),
            ),
          )
          .toList(),
    );
  }

  Future<void> _syncTrips(List<Trip> trips) async {
    await db.tripsDao.insertAll(
      trips
          .map(
            (t) => TripsTableCompanion.insert(
              id: t.id,
              destination: t.destination,
              location: Value(t.location),
              date: Value(t.date),
              guests: Value(t.guests),
              status: Value(t.status),
              imagePath: Value(t.imagePath),
              isUpcoming: Value(t.isUpcoming),
              flightId: Value(t.flightId),
              hotelId: Value(t.hotelId),
              roomId: Value(t.roomId),
              totalPrice: Value(t.totalPrice),
              isCustom: Value(t.isCustom),
              createdAt: const Value(''),
            ),
          )
          .toList(),
    );
  }

  Future<void> syncFavorite(String id, bool isFavorite) async {
    await db.destinationsDao.setFavorite(id, isFavorite);
  }

  Future<void> syncTrip(Trip trip) async {
    await db.tripsDao.insertTrip(
      TripsTableCompanion.insert(
        id: trip.id,
        destination: trip.destination,
        location: Value(trip.location),
        date: Value(trip.date),
        guests: Value(trip.guests),
        status: Value(trip.status),
        imagePath: Value(trip.imagePath),
        isUpcoming: Value(trip.isUpcoming),
        flightId: Value(trip.flightId),
        hotelId: Value(trip.hotelId),
        roomId: Value(trip.roomId),
        totalPrice: Value(trip.totalPrice),
        isCustom: Value(trip.isCustom),
        createdAt: const Value(''),
      ),
    );
  }

  Future<void> syncTripStatus(String id, String status) async {
    await db.tripsDao.updateStatus(id, status);
  }

  Future<void> _syncSchedule(String tripId, TripSchedule schedule) async {
    await db.transaction(() async {
      final existingDays = await db.tripScheduleDaysDao.getByTripId(tripId);
      for (final day in existingDays) {
        await db.tripScheduleItemsDao.deleteByDayId(day.id);
      }
      await db.tripScheduleDaysDao.deleteByTripId(tripId);
      await db.tripScheduleUpdatesDao.deleteByTripId(tripId);

      final dayCompanions = <TripScheduleDaysTableCompanion>[];
      for (final day in schedule.days) {
        dayCompanions.add(
          TripScheduleDaysTableCompanion.insert(
            id: day.id,
            tripId: tripId,
            dayNumber: Value(day.dayNumber),
            date: Value(day.date),
          ),
        );
      }
      await db.tripScheduleDaysDao.insertAll(dayCompanions);

      for (final day in schedule.days) {
        final itemCompanions = <TripScheduleItemsTableCompanion>[];
        for (int i = 0; i < day.items.length; i++) {
          final item = day.items[i];
          itemCompanions.add(
            TripScheduleItemsTableCompanion.insert(
              id: item.id,
              dayId: day.id,
              startTime: Value(item.startTime),
              endTime: Value(item.endTime),
              title: Value(item.title),
              description: Value(item.description),
              locationName: Value(item.location),
              latitude: Value(item.latitude),
              longitude: Value(item.longitude),
              sortOrder: Value(i),
              statusOverride: Value(item.statusOverride),
            ),
          );
        }
        await db.tripScheduleItemsDao.insertAll(itemCompanions);
      }

      final updateCompanions = <TripScheduleUpdatesTableCompanion>[];
      for (final update in schedule.updates) {
        updateCompanions.add(
          TripScheduleUpdatesTableCompanion.insert(
            id: update.id,
            tripId: tripId,
            message: update.message,
            createdAt: update.createdAt.toIso8601String(),
          ),
        );
      }
      await db.tripScheduleUpdatesDao.insertAll(updateCompanions);
    });
  }

  Future<BootstrapData> loadBootstrapFromSQLite() async {
    final destRows = await db.destinationsDao.getAll();
    final recommendedRows = await db.destinationsDao.getRecommended();
    final categoryRows = await db.categoriesDao.getAll();
    final hotelRows = await db.hotelsDao.getAll();
    final tourRows = await db.tourPackagesDao.getAll();
    final tripRows = await db.tripsDao.getAll();
    final docRows = await db.documentsDao.getAll();

    final destinations = destRows
        .map(
          (d) => Destination(
            id: d.id,
            name: d.name,
            location: d.location,
            rating: d.rating,
            duration: d.duration,
            imagePath: d.imagePath,
            isFavorite: d.isFavorite,
            description: d.description,
            price: d.price,
            reviewsCount: d.reviewsCount,
            category: d.category,
            latitude: d.latitude,
            longitude: d.longitude,
          ),
        )
        .toList();

    final recommended = recommendedRows
        .map(
          (d) => Destination(
            id: d.id,
            name: d.name,
            location: d.location,
            rating: d.rating,
            duration: d.duration,
            imagePath: d.imagePath,
          ),
        )
        .toList();

    final hotels = hotelRows.map((h) {
      return Hotel(
        id: h.id,
        name: h.name,
        location: h.location,
        latitude: h.latitude,
        longitude: h.longitude,
        rating: h.rating,
        imagePath: h.imagePath,
        description: h.description,
        priceFrom: h.priceFrom,
        address: h.address,
        amenities: List<String>.from(
          jsonDecode(h.amenities as String? ?? '[]'),
        ),
      );
    }).toList();

    final tours = tourRows
        .map(
          (t) => TourPackage(
            id: t.id,
            name: t.name,
            description: t.description,
            imagePath: t.imagePath,
            duration: t.duration,
            price: t.price,
            originalPrice: t.originalPrice,
            destinations: List<String>.from(
              jsonDecode(t.destinations as String? ?? '[]'),
            ),
            includes: List<String>.from(
              jsonDecode(t.includes as String? ?? '[]'),
            ),
            departure: t.departure,
            departureDate: t.departureDate,
            isPopular: t.isPopular,
            includesGuide: t.includesGuide,
            guideFee: t.guideFee,
          ),
        )
        .toList();

    final trips = tripRows
        .map(
          (t) => Trip(
            id: t.id,
            destination: t.destination,
            location: t.location,
            date: t.date,
            guests: t.guests,
            status: t.status,
            imagePath: t.imagePath,
            isUpcoming: t.isUpcoming,
            flightId: t.flightId,
            hotelId: t.hotelId,
            roomId: t.roomId,
            totalPrice: t.totalPrice,
            isCustom: t.isCustom,
          ),
        )
        .toList();

    final documents = docRows
        .map(
          (d) => DocumentItem(
            id: d.id,
            title: d.title,
            description: d.description,
            icon: Icons.description,
            color: Colors.blue,
            iconName: d.iconName,
            colorHex: d.colorHex,
          ),
        )
        .toList();

    return BootstrapData(
      categories: categoryRows.map((c) => c.name).toList(),
      destinations: destinations,
      recommended: recommended,
      trips: trips,
      documents: documents,
      hotels: hotels,
      tourPackages: tours,
    );
  }

  void dispose() {
    stopPeriodicSync();
    _db?.close();
  }
}
