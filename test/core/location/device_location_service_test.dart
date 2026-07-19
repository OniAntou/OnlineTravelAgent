import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:online_travel_agent/core/location/device_location_service.dart';

class FakeLocationPlatformGateway implements LocationPlatformGateway {
  FakeLocationPlatformGateway({
    required this.serviceEnabled,
    required this.permission,
  });

  bool serviceEnabled;
  DeviceLocationPermission permission;
  // The tests close this controller after every subscription scenario.
  // ignore: close_sinks
  final controller = StreamController<DeviceLocationFix>();
  var listenCount = 0;
  var cancelCount = 0;

  @override
  Future<bool> isLocationServiceEnabled() async => serviceEnabled;

  @override
  Future<DeviceLocationPermission> checkPermission() async => permission;

  @override
  Future<DeviceLocationPermission> requestPermission() async => permission;

  @override
  Stream<DeviceLocationFix> watchPosition() => Stream.multi((listener) {
    listenCount++;
    final subscription = controller.stream.listen(
      listener.add,
      onError: listener.addError,
      onDone: listener.close,
    );
    listener.onCancel = () {
      cancelCount++;
      return subscription.cancel();
    };
  });
}

void main() {
  test('does not subscribe when location permission is denied', () async {
    final gateway = FakeLocationPlatformGateway(
      serviceEnabled: true,
      permission: DeviceLocationPermission.denied,
    );
    final service = DeviceLocationService(gateway);

    final state = await service.start();

    expect(state, const DeviceLocationState.permissionDenied());
    expect(gateway.listenCount, 0);
    await service.dispose();
    unawaited(gateway.controller.close());
  });

  test('forwards a foreground position and cancels it when stopped', () async {
    final gateway = FakeLocationPlatformGateway(
      serviceEnabled: true,
      permission: DeviceLocationPermission.whileInUse,
    );
    final service = DeviceLocationService(gateway);
    final states = <DeviceLocationState>[];
    final subscription = service.states.listen(states.add);

    expect(await service.start(), const DeviceLocationState.locating());
    gateway.controller.add(
      const DeviceLocationFix(latitude: 10, longitude: 106),
    );
    await Future<void>.delayed(Duration.zero);

    expect(
      states,
      contains(
        const DeviceLocationState.ready(
          DeviceLocationFix(latitude: 10, longitude: 106),
        ),
      ),
    );
    await service.stop();
    expect(gateway.cancelCount, 1);

    await subscription.cancel();
    unawaited(gateway.controller.close());
    await service.dispose();
  });
}
