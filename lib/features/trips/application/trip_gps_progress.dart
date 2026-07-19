import 'dart:io';

import 'package:latlong2/latlong.dart';

import '../../../core/utils/trip_schedule_status.dart';
import '../domain/trip_schedule.dart';

const arrivalRadiusMeters = 150.0;

class GpsCoordinate {
  const GpsCoordinate(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  @override
  bool operator ==(Object other) =>
      other is GpsCoordinate &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}

class TripGpsTarget {
  const TripGpsTarget({required this.item, required this.coordinate});

  final TripScheduleItem item;
  final GpsCoordinate coordinate;
}

bool isValidGpsCoordinate({
  required double? latitude,
  required double? longitude,
}) =>
    latitude != null &&
    longitude != null &&
    latitude.isFinite &&
    longitude.isFinite &&
    latitude >= -90 &&
    latitude <= 90 &&
    longitude >= -180 &&
    longitude <= 180;

bool isWithinArrivalRadius(double distanceMeters) =>
    distanceMeters.isFinite && distanceMeters <= arrivalRadiusMeters;

double distanceMetersBetween(GpsCoordinate from, GpsCoordinate to) =>
    const Distance().as(
      LengthUnit.Meter,
      LatLng(from.latitude, from.longitude),
      LatLng(to.latitude, to.longitude),
    );

TripGpsTarget? selectNextGpsTarget({
  required String tripStatus,
  required TripSchedule schedule,
  DateTime? now,
}) {
  final ordered = <({TripScheduleDay day, TripScheduleItem item})>[];
  for (final day in schedule.days) {
    for (final item in day.items) {
      ordered.add((day: day, item: item));
    }
  }

  for (var index = 0; index < ordered.length; index++) {
    final current = ordered[index];
    final nextItem = index + 1 < ordered.length
        ? ordered[index + 1].item
        : null;
    final status = deriveTripScheduleMilestoneStatus(
      tripStatus: tripStatus,
      scheduleDate: current.day.date,
      startTime: current.item.startTime,
      endTime: current.item.endTime,
      nextStartTime: nextItem?.startTime,
      statusOverride: current.item.statusOverride,
      now: now,
    );
    if (status == 'completed' || status == 'cancelled') continue;
    if (!isValidGpsCoordinate(
      latitude: current.item.latitude,
      longitude: current.item.longitude,
    )) {
      continue;
    }
    return TripGpsTarget(
      item: current.item,
      coordinate: GpsCoordinate(
        current.item.latitude!,
        current.item.longitude!,
      ),
    );
  }
  return null;
}

Uri buildBrowserDirectionsUri(GpsCoordinate target) => Uri.https(
  'www.google.com',
  '/maps/dir/',
  {'api': '1', 'destination': '${target.latitude},${target.longitude}'},
);

Uri buildPlatformDirectionsUri(GpsCoordinate target) {
  final destination = '${target.latitude},${target.longitude}';
  if (Platform.isIOS) {
    return Uri.parse('http://maps.apple.com/?daddr=$destination&dirflg=d');
  }
  return Uri.parse('google.navigation:q=$destination');
}
