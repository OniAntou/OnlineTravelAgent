import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/app_theme.dart';
import '../../models/trip.dart';
import '../../utils/app_utils.dart';
import '../../models/tour_package.dart';
import '../../providers/destination_provider.dart';
import '../../providers/tour_provider.dart';
import 'widgets/booking_info_card.dart';
import 'widgets/booking_status_timeline.dart';
import 'widgets/trip_action_buttons.dart';
import 'widgets/trip_section_header.dart';
import 'widgets/trip_schedule_timeline.dart';

class TourTripDetailScreen extends ConsumerStatefulWidget {
  final Trip trip;

  const TourTripDetailScreen({super.key, required this.trip});

  @override
  ConsumerState<TourTripDetailScreen> createState() => _TourTripDetailScreenState();
}

class _TourTripDetailScreenState extends ConsumerState<TourTripDetailScreen> {
  TourPackage? _findTourPackage(WidgetRef ref) {
    final tourPackages = ref.watch(toursProvider);
    final name = widget.trip.destination.toLowerCase().trim();
    try {
      return tourPackages.firstWhere(
        (t) => t.name.toLowerCase().trim() == name,
      );
    } catch (_) {
      return null;
    }
  }

  Color _statusColor() {
    final s = widget.trip.status.toLowerCase();
    if (s == 'đang diễn ra' || s == 'ongoing') return const Color(0xFFFF9800);
    if (widget.trip.isUpcoming) return AppTheme.primaryBlue;
    return Colors.grey;
  }

  Color _statusBgColor() {
    final s = widget.trip.status.toLowerCase();
    if (s == 'đang diễn ra' || s == 'ongoing') {
      return const Color(0xFFFF9800).withValues(alpha: 0.1);
    }
    if (widget.trip.isUpcoming) {
      return AppTheme.primaryBlue.withValues(alpha: 0.08);
    }
    return Colors.grey.withValues(alpha: 0.1);
  }

  @override
  Widget build(BuildContext context) {
    final tourPackage = _findTourPackage(ref);
    final destinations = ref.watch(destinationsProvider);
    final screenHeight = MediaQuery.sizeOf(context).height;
    final heroCacheWidth =
        (MediaQuery.sizeOf(context).width * MediaQuery.devicePixelRatioOf(context)).round();

    // Map Route Processing
    final List<LatLng> points = [];
    final List<Marker> markers = [];
    if (tourPackage != null) {
      for (final destName in tourPackage.destinations) {
        try {
          final d = destinations.firstWhere(
            (dest) => dest.name.toLowerCase().trim().contains(destName.toLowerCase().trim()) ||
                destName.toLowerCase().trim().contains(dest.name.toLowerCase().trim())
          );
          if (d.latitude != 0.0 && d.longitude != 0.0) {
            final latLng = LatLng(d.latitude, d.longitude);
            points.add(latLng);
            markers.add(
              Marker(
                point: latLng,
                width: 40,
                height: 40,
                child: const Icon(Icons.location_on, color: Colors.red, size: 36),
              ),
            );
          }
        } catch (e) {
          debugPrint('Error parsing schedule coordinates: $e');
        }
      }
    } else {
      try {
        final d = destinations.firstWhere(
          (dest) => dest.name.toLowerCase().trim() == widget.trip.destination.toLowerCase().trim()
        );
        if (d.latitude != 0.0 && d.longitude != 0.0) {
          final latLng = LatLng(d.latitude, d.longitude);
          points.add(latLng);
          markers.add(
            Marker(
              point: latLng,
              width: 40,
              height: 40,
              child: const Icon(Icons.location_on, color: Colors.red, size: 36),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error parsing destination coordinates: $e');
      }
    }

    final LatLng centerPoint;
    if (points.isNotEmpty) {
      double sumLat = 0;
      double sumLng = 0;
      for (final p in points) {
        sumLat += p.latitude;
        sumLng += p.longitude;
      }
      centerPoint = LatLng(sumLat / points.length, sumLng / points.length);
    } else {
      centerPoint = const LatLng(10.7769, 106.7009); // HCMC
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // A. Hero Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.45,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  widget.trip.imagePath,
                  fit: BoxFit.cover,
                  cacheWidth: heroCacheWidth,
                  filterQuality: FilterQuality.low,
                  errorBuilder: (context, error, stackTrace) =>
                      ColoredBox(color: Colors.grey.shade300),
                ),
                // Premium overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 80,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // B. Back + Share buttons & Floating Classification Badge
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _floatingButton(
                        icon: Icons.chevron_left,
                        onTap: () => Navigator.pop(context),
                      ),
                      Row(
                        children: [

                          _floatingButton(
                            icon: Icons.share_outlined,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Chia sẻ — Tính năng đang phát triển'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // C. DraggableScrollableSheet
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.6,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Header: destination name + status badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.trip.destination,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textBlack,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.flight_takeoff_rounded,
                                      size: 16, color: AppTheme.primaryBlue),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Khởi hành từ: ${tourPackage?.departure ?? "SGN"}',
                                      style: const TextStyle(
                                        color: AppTheme.primaryBlue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _statusBgColor(),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.trip.status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _statusColor(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Quick stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _infoItem(
                          Icons.access_time_rounded,
                          tourPackage?.duration ?? '3N/2Đ',
                          'Thời lượng',
                        ),
                        _infoItem(
                          Icons.flight_takeoff_rounded,
                          tourPackage?.departure ?? 'SGN',
                          'Khởi hành',
                        ),
                        _infoItem(
                          Icons.map_rounded,
                          '${tourPackage?.destinations.length ?? 1} Điểm đến',
                          'Lộ trình',
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Booking Info Card
                    const TripSectionHeader(title: 'Thông tin đặt chỗ'),
                    BookingInfoCard(trip: widget.trip),
                    const SizedBox(height: 28),

                    // Booking Status Timeline
                    const TripSectionHeader(title: 'Trạng thái đặt chỗ'),
                    BookingStatusTimeline(status: widget.trip.status),
                    const SizedBox(height: 28),

                    // Lịch trình Tour (Itinerary Timeline with Real-Time Tracking)
                    TripScheduleTimeline(trip: widget.trip),
                    const SizedBox(height: 28),

                    // Bản đồ lộ trình
                    const TripSectionHeader(title: 'Bản đồ lộ trình'),
                    _buildRouteMap(points, markers, centerPoint),
                    const SizedBox(height: 28),

                    // Dịch vụ bao gồm
                    const TripSectionHeader(title: 'Dịch vụ bao gồm'),
                    _buildInclusionsGrid(tourPackage),
                    const SizedBox(height: 28),

                    // Thông tin giá
                    const TripSectionHeader(title: 'Thông tin giá'),
                    _buildPriceCard(tourPackage),
                    const SizedBox(height: 28),

                    // Action Buttons
                    const TripSectionHeader(title: 'Hành động'),
                    TripActionButtons(trip: widget.trip),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _floatingButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black87),
      ),
    );
  }

  Widget _infoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.backgroundGray,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: AppTheme.primaryBlue),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
      ],
    );
  }



  Widget _buildRouteMap(List<LatLng> points, List<Marker> markers, LatLng centerPoint) {
    if (points.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text('Chưa có thông tin toạ độ lộ trình',
            style: TextStyle(color: Colors.grey)),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: RepaintBoundary(
          child: FlutterMap(
            options: MapOptions(
              initialCenter: centerPoint,
              initialZoom: points.length >= 2 ? 8 : 12,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
          children: [
            TileLayer(
              urlTemplate: kOpenStreetMapTileUrl,
              userAgentPackageName: 'com.example.onlinetravelagent',
            ),
            if (points.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: points,
                    color: AppTheme.primaryBlue,
                    strokeWidth: 4,
                  ),
                ],
              ),
            MarkerLayer(markers: markers),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildInclusionsGrid(TourPackage? tourPackage) {
    final List<String> inclusions = tourPackage?.includes ?? [
      'Khách sạn 4 sao',
      'Ăn uống trọn gói',
      'Xe đưa đón hiện đại',
      'Vé tham quan các điểm',
      'Bảo hiểm du lịch',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: inclusions.length,
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 64,
      ),
      itemBuilder: (context, index) {
        final item = inclusions[index];
        IconData icon = Icons.check_circle_outline_rounded;
        final lower = item.toLowerCase();
        if (lower.contains('khách sạn') || lower.contains('resort') || lower.contains('bungalow') || lower.contains('cabin') || lower.contains('ks')) {
          icon = Icons.hotel_rounded;
        } else if (lower.contains('ăn') || lower.contains('bữa') || lower.contains('buffet') || lower.contains('uống')) {
          icon = Icons.restaurant_rounded;
        } else if (lower.contains('xe') || lower.contains('bus') || lower.contains('limousine') || lower.contains('cano') || lower.contains('đưa đón')) {
          icon = Icons.directions_bus_rounded;
        } else if (lower.contains('vé') || lower.contains('đò') || lower.contains('cáp treo')) {
          icon = Icons.confirmation_num_rounded;
        } else if (lower.contains('bảo hiểm') || lower.contains('tắm') || lower.contains('y tế')) {
          icon = Icons.health_and_safety_rounded;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppTheme.primaryBlue, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textBlack,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriceCard(TourPackage? tourPackage) {
    final double price = tourPackage?.price ?? (widget.trip.totalPrice ?? 150.0);
    final double? originalPrice = tourPackage?.originalPrice;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGray,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (originalPrice != null && originalPrice > price) ...[
            Row(
              children: [
                Text(
                  formatVND(originalPrice),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    decoration: TextDecoration.lineThrough,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '-${((originalPrice - price) / originalPrice * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Giá vé người lớn',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                formatVND(price),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
          if (widget.trip.totalPrice != null) ...[
            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng cộng thanh toán',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textBlack,
                  ),
                ),
                Text(
                  formatVND(widget.trip.totalPrice!),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// Glowing Pulsing bolt indicator for ongoing events
class PulsingIndicator extends StatefulWidget {
  const PulsingIndicator({super.key});

  @override
  State<PulsingIndicator> createState() => _PulsingIndicatorState();
}

class _PulsingIndicatorState extends State<PulsingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1.0 + (_controller.value * 0.35);
        return Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFF9800),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF9800).withValues(alpha: 0.6 - (_controller.value * 0.4)),
                blurRadius: 8 * scale,
                spreadRadius: 3 * _controller.value,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.bolt, size: 10, color: Colors.white),
        );
      },
    );
  }
}
