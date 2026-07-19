import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/location/device_location_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../data/services/api_provider.dart';
import '../../application/trip_gps_progress.dart';
import '../../application/trip_schedule_provider.dart';
import '../../domain/trip.dart';

class TripGpsProgressPanel extends ConsumerStatefulWidget {
  const TripGpsProgressPanel({
    super.key,
    required this.trip,
    this.onLocationChanged,
    this.locationService,
  });

  final Trip trip;
  final ValueChanged<DeviceLocationFix?>? onLocationChanged;
  final DeviceLocationService? locationService;

  @override
  ConsumerState<TripGpsProgressPanel> createState() =>
      _TripGpsProgressPanelState();
}

class _TripGpsProgressPanelState extends ConsumerState<TripGpsProgressPanel>
    with WidgetsBindingObserver {
  late final DeviceLocationService _locationService =
      widget.locationService ??
      DeviceLocationService(const GeolocatorLocationPlatformGateway());
  StreamSubscription<DeviceLocationState>? _subscription;
  DeviceLocationState _state = const DeviceLocationState.locating();
  DeviceLocationFix? _fix;
  TripGpsTarget? _target;
  String? _dismissedTargetId;
  bool _confirming = false;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscription = _locationService.states.listen((state) {
      if (!mounted) return;
      setState(() {
        _state = state;
        if (state case DeviceLocationReady(:final fix)) {
          _fix = fix;
          widget.onLocationChanged?.call(fix);
        }
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _target != null) {
      _startLocation();
    } else if (state != AppLifecycleState.resumed) {
      _locationService.stop();
      _started = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.onLocationChanged?.call(null);
    _subscription?.cancel();
    _locationService.dispose();
    super.dispose();
  }

  Future<void> _startLocation() async {
    if (_started || _target == null) return;
    _started = true;
    final state = await _locationService.start();
    if (mounted) setState(() => _state = state);
  }

  Future<void> _openDirections(TripGpsTarget target) async {
    final nativeUri = buildPlatformDirectionsUri(target.coordinate);
    final opened = await launchUrl(
      nativeUri,
      mode: LaunchMode.externalApplication,
    );
    if (opened) return;
    final fallbackOpened = await launchUrl(
      buildBrowserDirectionsUri(target.coordinate),
      mode: LaunchMode.externalApplication,
    );
    if (!fallbackOpened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở ứng dụng bản đồ.')),
      );
    }
  }

  Future<void> _confirmArrival(TripGpsTarget target) async {
    setState(() => _confirming = true);
    try {
      await ref
          .read(apiProvider)
          .confirmTripScheduleItem(widget.trip.id, target.item.id);
      ref.invalidate(tripScheduleProvider(widget.trip.id));
      if (mounted) {
        setState(() => _dismissedTargetId = target.item.id);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chưa thể xác nhận. Vui lòng thử lại.')),
        );
      }
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final schedule = ref.watch(tripScheduleProvider(widget.trip.id));
    return schedule.when(
      loading: () => const _GpsPanelCard(
        icon: Icons.my_location_rounded,
        message: 'Đang tải điểm GPS của lịch trình...',
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (value) {
        final target = selectNextGpsTarget(
          tripStatus: widget.trip.status.storageValue,
          schedule: value,
        );
        if (target?.item.id != _target?.item.id) {
          _target = target;
          _started = false;
          _dismissedTargetId = null;
          if (target != null) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _startLocation(),
            );
          } else {
            _locationService.stop();
            widget.onLocationChanged?.call(null);
          }
        }
        if (target == null) {
          return const _GpsPanelCard(
            icon: Icons.flag_circle_outlined,
            message: 'Không còn điểm lịch trình có tọa độ để dẫn đường.',
          );
        }
        return _buildTargetCard(target);
      },
    );
  }

  Widget _buildTargetCard(TripGpsTarget target) {
    final distance = _fix == null
        ? null
        : distanceMetersBetween(
            GpsCoordinate(_fix!.latitude, _fix!.longitude),
            target.coordinate,
          );
    final isNear =
        distance != null &&
        isWithinArrivalRadius(distance) &&
        _dismissedTargetId != target.item.id;
    final unavailable = switch (_state) {
      DeviceLocationServiceDisabled() =>
        'Hãy bật Dịch vụ vị trí để theo dõi điểm đến.',
      DeviceLocationPermissionDenied() =>
        'Cần quyền vị trí khi dùng màn hình này.',
      DeviceLocationPermissionDeniedForever() =>
        'Quyền vị trí đã bị từ chối vĩnh viễn.',
      DeviceLocationUnavailable() => 'Không thể cập nhật vị trí hiện tại.',
      _ => null,
    };

    return Card(
      elevation: 0,
      color: AppTheme.primaryBlue.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Điểm tiếp theo: ${target.item.title}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              distance == null
                  ? 'Đang xác định vị trí hiện tại...'
                  : 'Cách ${distance.round()} m',
            ),
            if (_fix != null) ...[
              const SizedBox(height: 12),
              _buildGpsMap(target),
            ],
            if (unavailable != null) ...[
              const SizedBox(height: 8),
              Text(unavailable),
              TextButton(
                onPressed: _state is DeviceLocationPermissionDeniedForever
                    ? Geolocator.openAppSettings
                    : () {
                        _started = false;
                        _startLocation();
                      },
                child: Text(
                  _state is DeviceLocationPermissionDeniedForever
                      ? 'Mở cài đặt'
                      : 'Thử lại',
                ),
              ),
            ],
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => _openDirections(target),
              icon: const Icon(Icons.directions),
              label: const Text('Chỉ đường'),
            ),
            if (isNear) ...[
              const SizedBox(height: 12),
              const Text('Bạn đã ở gần điểm lịch trình này.'),
              FilledButton(
                onPressed: _confirming ? null : () => _confirmArrival(target),
                child: Text(
                  _confirming ? 'Đang xác nhận...' : 'Xác nhận đã đến',
                ),
              ),
              TextButton(
                onPressed: () =>
                    setState(() => _dismissedTargetId = target.item.id),
                child: const Text('Để sau'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGpsMap(TripGpsTarget target) {
    final current = LatLng(_fix!.latitude, _fix!.longitude);
    final destination = LatLng(
      target.coordinate.latitude,
      target.coordinate.longitude,
    );
    return SizedBox(
      height: 160,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          options: MapOptions(initialCenter: current, initialZoom: 15),
          children: [
            TileLayer(
              urlTemplate: kOpenStreetMapTileUrl,
              userAgentPackageName: 'vn.com.onlinetravelagent.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: current,
                  width: 36,
                  height: 36,
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.blue,
                    size: 32,
                  ),
                ),
                Marker(
                  point: destination,
                  width: 36,
                  height: 36,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 36,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GpsPanelCard extends StatelessWidget {
  const _GpsPanelCard({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    ),
  );
}
