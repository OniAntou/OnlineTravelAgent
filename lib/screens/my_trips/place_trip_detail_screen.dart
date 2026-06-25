import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/app_theme.dart';
import '../../models/trip.dart';
import '../../models/destination.dart';
import '../../providers/destination_provider.dart';
import 'widgets/booking_info_card.dart';
import 'widgets/booking_status_timeline.dart';
import 'widgets/trip_action_buttons.dart';
import 'widgets/trip_section_header.dart';
import 'widgets/trip_schedule_timeline.dart';
import '../../utils/app_utils.dart';

class PlaceTripDetailScreen extends ConsumerWidget {
  final Trip trip;

  const PlaceTripDetailScreen({super.key, required this.trip});

  Destination? _findDestination(WidgetRef ref) {
    final destinations = ref.watch(destinationsProvider);
    final name = trip.destination.toLowerCase().trim();
    try {
      return destinations.firstWhere(
        (d) => d.name.toLowerCase().trim() == name,
      );
    } catch (_) {
      return null;
    }
  }

  Color _statusColor() {
    final s = trip.status.toLowerCase();
    if (s == 'đang diễn ra' || s == 'ongoing') return const Color(0xFFFF9800);
    if (trip.isUpcoming) return AppTheme.primaryBlue;
    return Colors.grey;
  }

  Color _statusBgColor() {
    final s = trip.status.toLowerCase();
    if (s == 'đang diễn ra' || s == 'ongoing') {
      return const Color(0xFFFF9800).withValues(alpha: 0.1);
    }
    if (trip.isUpcoming) {
      return AppTheme.primaryBlue.withValues(alpha: 0.08);
    }
    return Colors.grey.withValues(alpha: 0.1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destination = _findDestination(ref);
    final screenHeight = MediaQuery.sizeOf(context).height;
    final heroCacheWidth =
        (MediaQuery.sizeOf(context).width * MediaQuery.devicePixelRatioOf(context)).round();

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
            child: Image.asset(
              trip.imagePath,
              fit: BoxFit.cover,
              cacheWidth: heroCacheWidth,
              filterQuality: FilterQuality.low,
              errorBuilder: (context, error, stackTrace) =>
                  ColoredBox(color: Colors.grey.shade300),
            ),
          ),

          // B. Back + Share buttons
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _floatingButton(
                    icon: Icons.chevron_left,
                    onTap: () => Navigator.pop(context),
                  ),
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
                                trip.destination,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      size: 16, color: AppTheme.primaryBlue),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      trip.location,
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 14),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _statusBgColor(),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            trip.status,
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
                    if (destination != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _infoItem(Icons.star, destination.rating,
                              '${destination.reviewsCount} Đánh giá'),
                          _infoItem(Icons.access_time, destination.duration,
                              'Thời lượng'),
                          _infoItem(Icons.wb_cloudy, '24°C', 'Thời tiết'),
                        ],
                      ),
                      const SizedBox(height: 28),
                    ],

                    // Booking Info Card
                    const TripSectionHeader(title: 'Thông tin đặt chỗ'),
                    BookingInfoCard(trip: trip),
                    const SizedBox(height: 28),

                    // Booking Status Timeline
                    const TripSectionHeader(title: 'Trạng thái đặt chỗ'),
                    BookingStatusTimeline(status: trip.status),
                    const SizedBox(height: 28),

                    // Lịch trình chi tiết (Real-time tracking)
                    TripScheduleTimeline(trip: trip),
                    const SizedBox(height: 28),

                    // Map
                    const TripSectionHeader(title: 'Vị trí trên bản đồ'),
                    _buildMap(destination),
                    const SizedBox(height: 28),

                    // Facilities
                    const TripSectionHeader(title: 'Tiện ích'),
                    _buildFacilities(),
                    const SizedBox(height: 28),

                    // Action Buttons
                    const TripSectionHeader(title: 'Hành động'),
                    TripActionButtons(trip: trip),
                    const SizedBox(height: 28),

                    // Reviews
                    const TripSectionHeader(title: 'Đánh giá & Nhận xét'),
                    _buildReviews(destination),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _floatingButton(
      {required IconData icon, required VoidCallback onTap}) {
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
          child: Icon(icon, size: 20, color: Colors.amber),
        ),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _buildMap(Destination? destination) {
    if (destination == null ||
        destination.latitude == 0.0 ||
        destination.longitude == 0.0) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text('Chưa có thông tin toạ độ',
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
              initialCenter:
                  LatLng(destination.latitude, destination.longitude),
              initialZoom: 13,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
          children: [
            TileLayer(
              urlTemplate: kOpenStreetMapTileUrl,
              userAgentPackageName: 'com.example.onlinetravelagent',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(
                      destination.latitude, destination.longitude),
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_on,
                      color: Colors.red, size: 40),
                ),
              ],
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildFacilities() {
    final facilities = [
      (Icons.wifi, 'Wifi'),
      (Icons.flatware, 'Bữa sáng'),
      (Icons.pool, 'Hồ bơi'),
      (Icons.local_parking, 'Gửi xe'),
      (Icons.fitness_center, 'Gym'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: facilities.map((f) {
          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundGray,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(f.$1, color: AppTheme.primaryBlue, size: 24),
                ),
                const SizedBox(height: 8),
                Text(f.$2,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviews(Destination? destination) {
    final reviews = _getSampleReviews(destination?.name ?? trip.destination);
    final double ratingVal =
        double.tryParse(destination?.rating ?? '4.8') ?? 4.8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rating summary
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Text(
                  destination?.rating ?? '4.8',
                  style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      Icons.star,
                      size: 16,
                      color: index < ratingVal.round()
                          ? Colors.amber
                          : Colors.grey.shade300,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  '${destination?.reviewsCount ?? '100'} nhận xét',
                  style:
                      const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                children: [
                  _ratingBar('5 sao', 0.85),
                  _ratingBar('4 sao', 0.10),
                  _ratingBar('3 sao', 0.03),
                  _ratingBar('2 sao', 0.01),
                  _ratingBar('1 sao', 0.01),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Review cards
        ...reviews.map(_buildReviewCard),
      ],
    );
  }

  Widget _ratingBar(String label, double pct) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: Colors.grey.shade100,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryBlue),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(pct * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, String> review) {
    final double rv = double.tryParse(review['rating'] ?? '5.0') ?? 5.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(review['avatar']!),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review['name']!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black87)),
                    const SizedBox(height: 2),
                    Text(review['date']!,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 10)),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star,
                    size: 12,
                    color: index < rv.round()
                        ? Colors.amber
                        : Colors.grey.shade200,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review['comment']!,
            style: TextStyle(
                color: Colors.grey.shade800, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _getSampleReviews(String name) {
    final clean = name.toLowerCase().trim();
    if (clean.contains('đà lạt')) {
      return [
        {'name': 'Trần Minh Quân', 'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&fit=crop', 'date': '3 ngày trước', 'rating': '5.0', 'comment': 'Đà Lạt mùa này lạnh tê tái rất thích hợp để nghỉ dưỡng. Khách sạn Mường Thanh ở vị trí trung tâm đi lại cực tiện!'},
        {'name': 'Nguyễn Thảo Nguyên', 'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=80&fit=crop', 'date': '1 tuần trước', 'rating': '4.5', 'comment': 'Đồ ăn đêm ở chợ Đà Lạt siêu ngon, bánh tráng nướng và sữa đậu nành nóng hổi giữa trời lạnh rất chill.'},
      ];
    } else if (clean.contains('phú quốc')) {
      return [
        {'name': 'Lê Hải Đăng', 'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=80&fit=crop', 'date': '2 ngày trước', 'rating': '5.0', 'comment': 'Đảo ngọc Phú Quốc biển trong xanh vắt ngắm rõ san hô. Tour đi cano 4 đảo xuất sắc!'},
        {'name': 'Phạm Khánh Linh', 'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=80&fit=crop', 'date': '1 tuần trước', 'rating': '4.9', 'comment': 'Resort 5 sao bãi biển riêng cát trắng mịn. Đồ ăn hải sản nướng thơm ngon!'},
      ];
    } else if (clean.contains('sapa') || clean.contains('sa pa')) {
      return [
        {'name': 'Nguyễn Tiến Đạt', 'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&fit=crop', 'date': '5 ngày trước', 'rating': '5.0', 'comment': 'Chinh phục đỉnh Fansipan 3.143m ngắm thung lũng mây trôi bồng bềnh hùng vĩ!'},
        {'name': 'Vũ Quỳnh Chi', 'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=80&fit=crop', 'date': '1 tuần trước', 'rating': '4.8', 'comment': 'Trải nghiệm đi bộ trekking xuyên qua bản Cát Cát và thung lũng Mường Hoa rất thú vị.'},
      ];
    } else if (clean.contains('hạ long') || clean.contains('halong')) {
      return [
        {'name': 'Đỗ Hoàng Long', 'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=80&fit=crop', 'date': '1 ngày trước', 'rating': '5.0', 'comment': 'Ngủ đêm trên du thuyền 5 sao lướt êm đềm giữa hàng ngàn đảo đá vôi là trải nghiệm thượng lưu.'},
      ];
    }
    return [
      {'name': 'Nguyễn Tuấn Kiệt', 'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&fit=crop', 'date': '4 ngày trước', 'rating': '4.9', 'comment': 'Địa điểm du lịch tuyệt vời mang đậm nét bản sắc văn hóa. Không gian phong cảnh lãng mạn!'},
      {'name': 'Mai Thu Trang', 'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=80&fit=crop', 'date': '1 tuần trước', 'rating': '4.8', 'comment': 'Chuyến đi tổ chức rất trọn vẹn và an toàn. Hướng dẫn viên nhiệt tình!'},
    ];
  }
}
