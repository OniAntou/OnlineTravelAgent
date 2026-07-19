// ignore_for_file: cancel_subscriptions

import 'dart:async';

import 'package:geolocator/geolocator.dart';

enum DeviceLocationPermission { denied, deniedForever, whileInUse }

class DeviceLocationFix {
  const DeviceLocationFix({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  @override
  bool operator ==(Object other) =>
      other is DeviceLocationFix &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}

sealed class DeviceLocationState {
  const DeviceLocationState();

  const factory DeviceLocationState.locating() = DeviceLocationLocating;
  const factory DeviceLocationState.ready(DeviceLocationFix fix) =
      DeviceLocationReady;
  const factory DeviceLocationState.serviceDisabled() =
      DeviceLocationServiceDisabled;
  const factory DeviceLocationState.permissionDenied() =
      DeviceLocationPermissionDenied;
  const factory DeviceLocationState.permissionDeniedForever() =
      DeviceLocationPermissionDeniedForever;
  const factory DeviceLocationState.unavailable(String message) =
      DeviceLocationUnavailable;
}

class DeviceLocationLocating extends DeviceLocationState {
  const DeviceLocationLocating();

  @override
  bool operator ==(Object other) => other is DeviceLocationLocating;

  @override
  int get hashCode => runtimeType.hashCode;
}

class DeviceLocationReady extends DeviceLocationState {
  const DeviceLocationReady(this.fix);

  final DeviceLocationFix fix;

  @override
  bool operator ==(Object other) =>
      other is DeviceLocationReady && other.fix == fix;

  @override
  int get hashCode => fix.hashCode;
}

class DeviceLocationServiceDisabled extends DeviceLocationState {
  const DeviceLocationServiceDisabled();

  @override
  bool operator ==(Object other) => other is DeviceLocationServiceDisabled;

  @override
  int get hashCode => runtimeType.hashCode;
}

class DeviceLocationPermissionDenied extends DeviceLocationState {
  const DeviceLocationPermissionDenied();

  @override
  bool operator ==(Object other) => other is DeviceLocationPermissionDenied;

  @override
  int get hashCode => runtimeType.hashCode;
}

class DeviceLocationPermissionDeniedForever extends DeviceLocationState {
  const DeviceLocationPermissionDeniedForever();

  @override
  bool operator ==(Object other) =>
      other is DeviceLocationPermissionDeniedForever;

  @override
  int get hashCode => runtimeType.hashCode;
}

class DeviceLocationUnavailable extends DeviceLocationState {
  const DeviceLocationUnavailable(this.message);

  final String message;

  @override
  bool operator ==(Object other) =>
      other is DeviceLocationUnavailable && other.message == message;

  @override
  int get hashCode => message.hashCode;
}

abstract interface class LocationPlatformGateway {
  Future<bool> isLocationServiceEnabled();
  Future<DeviceLocationPermission> checkPermission();
  Future<DeviceLocationPermission> requestPermission();
  Stream<DeviceLocationFix> watchPosition();
}

class DeviceLocationService {
  DeviceLocationService(this._gateway);

  final LocationPlatformGateway _gateway;
  final StreamController<DeviceLocationState> _states =
      StreamController<DeviceLocationState>.broadcast();
  StreamSubscription<DeviceLocationFix>? _positionSubscription;

  Stream<DeviceLocationState> get states => _states.stream;

  Future<DeviceLocationState> start() async {
    await stop();
    if (!await _gateway.isLocationServiceEnabled()) {
      return _emit(const DeviceLocationState.serviceDisabled());
    }

    var permission = await _gateway.checkPermission();
    if (permission == DeviceLocationPermission.denied) {
      permission = await _gateway.requestPermission();
    }
    if (permission == DeviceLocationPermission.deniedForever) {
      return _emit(const DeviceLocationState.permissionDeniedForever());
    }
    if (permission != DeviceLocationPermission.whileInUse) {
      return _emit(const DeviceLocationState.permissionDenied());
    }

    final locating = _emit(const DeviceLocationState.locating());
    // The subscription is cancelled by stop(), which is called from dispose
    // and by the GPS panel whenever its screen becomes inactive.
    _positionSubscription = _gateway.watchPosition().listen(
      (fix) => _emit(DeviceLocationState.ready(fix)),
      onError: (_, _) => _emit(
        const DeviceLocationState.unavailable(
          'Không thể cập nhật vị trí hiện tại.',
        ),
      ),
    );
    return locating;
  }

  Future<void> stop() async {
    final subscription = _positionSubscription;
    _positionSubscription = null;
    await subscription?.cancel();
  }

  Future<void> dispose() async {
    await stop();
    _states.close();
  }

  DeviceLocationState _emit(DeviceLocationState state) {
    if (!_states.isClosed) _states.add(state);
    return state;
  }
}

class GeolocatorLocationPlatformGateway implements LocationPlatformGateway {
  const GeolocatorLocationPlatformGateway();

  @override
  Future<bool> isLocationServiceEnabled() =>
      Geolocator.isLocationServiceEnabled();

  @override
  Future<DeviceLocationPermission> checkPermission() async =>
      _mapPermission(await Geolocator.checkPermission());

  @override
  Future<DeviceLocationPermission> requestPermission() async =>
      _mapPermission(await Geolocator.requestPermission());

  @override
  Stream<DeviceLocationFix> watchPosition() =>
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 25,
        ),
      ).map(
        (position) => DeviceLocationFix(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );

  DeviceLocationPermission _mapPermission(LocationPermission permission) {
    if (permission == LocationPermission.deniedForever) {
      return DeviceLocationPermission.deniedForever;
    }
    if (permission == LocationPermission.denied) {
      return DeviceLocationPermission.denied;
    }
    return DeviceLocationPermission.whileInUse;
  }
}
