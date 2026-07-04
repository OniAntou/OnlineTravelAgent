import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/destination.dart';
import '../checkout/checkout_screen.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_utils.dart';
import '../../utils/dialog_utils.dart';
import '../../widgets/review_section.dart';
import '../../providers/destination_provider.dart';
import '../../providers/app_state_provider.dart';

class DestinationDetailScreen extends ConsumerStatefulWidget {
  final Destination destination;
  final VoidCallback onBackClick;
  final VoidCallback onFavoriteClick;

  const DestinationDetailScreen({
    super.key,
    required this.destination,
    required this.onBackClick,
    required this.onFavoriteClick,
  });

  @override
  ConsumerState<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState
    extends ConsumerState<DestinationDetailScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _navigateToCheckout(BuildContext context, WidgetRef ref) {
    if (!ref.read(authProvider).isLoggedIn) {
      showErrorSnackBar(context, 'Vui lòng đăng nhập để đặt!');
      Navigator.pushNamed(context, '/login');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(destination: widget.destination),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final destinations = ref.watch(destinationsProvider);
    final d = destinations.firstWhere((e) => e.id == widget.destination.id, orElse: () => widget.destination);

    final heroCacheWidth = (MediaQuery.sizeOf(context).width *
            MediaQuery.devicePixelRatioOf(context))
        .round();
    final thumbCacheWidth =
        (100 * MediaQuery.devicePixelRatioOf(context)).round();

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            stretch: true,
            backgroundColor: AppTheme.primaryBlue,
            elevation: 0,
            leadingWidth: 70,
            leading: Center(
              child: GestureDetector(
                onTap: widget.onBackClick,
                child: Container(
                  margin: const EdgeInsets.only(left: 20),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.chevron_left, color: Colors.black),
                ),
              ),
            ),
            actions: [
              Center(
                child: GestureDetector(
                  onTap: widget.onFavoriteClick,
                  child: Container(
                    margin: const EdgeInsets.only(right: 20),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      d.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: d.isFavorite ? Colors.red : Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Hero(
                tag: 'dest_image_${d.name}',
                child: Image.asset(
                  d.imagePath,
                  fit: BoxFit.cover,
                  cacheWidth: heroCacheWidth,
                  filterQuality: FilterQuality.low,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.name,
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: AppTheme.primaryBlue),
                      const SizedBox(width: 4),
                      Text(
                        d.location,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoItem(Icons.star, d.rating, '(${d.reviewsCount} Đánh giá)'),
                      _infoItem(Icons.access_time, d.duration, 'Thời lượng'),
                      _infoItem(Icons.wb_cloudy, '24°C', 'Thời tiết'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Mô tả',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    d.description.isNotEmpty
                        ? d.description
                        : 'Khám phá vẻ đẹp tuyệt vời của ${d.name}. Một hành trình đáng nhớ đang chờ đợi bạn.',
                    style: const TextStyle(
                        color: Colors.black87, fontSize: 15, height: 1.6),
                  ),

                  const SizedBox(height: 32),
                  const Text(
                    'Trải nghiệm nổi bật',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 130,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      clipBehavior: Clip.none,
                      children: [
                        _highlightItem(Icons.camera_alt_outlined, 'Sống ảo', 'Góc check-in', const Color(0xFFE11D48)),
                        const SizedBox(width: 16),
                        _highlightItem(Icons.restaurant_outlined, 'Đặc sản', 'Khám phá ẩm thực', const Color(0xFFD97706)),
                        const SizedBox(width: 16),
                        _highlightItem(Icons.landscape_outlined, 'Ngắm cảnh', 'Hòa vào thiên nhiên', const Color(0xFF059669)),
                        const SizedBox(width: 16),
                        _highlightItem(Icons.water_drop_outlined, 'Thư giãn', 'Nghỉ dưỡng êm ái', const Color(0xFF0284C7)),
                        const SizedBox(width: 16),
                        _highlightItem(Icons.local_mall_outlined, 'Mua sắm', 'Quà lưu niệm', const Color(0xFF7C3AED)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Vị trí trên bản đồ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (d.latitude != 0.0 && d.longitude != 0.0)
                    Container(
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
                              initialCenter: LatLng(d.latitude, d.longitude),
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
                                    point: LatLng(d.latitude, d.longitude),
                                    width: 40,
                                    height: 40,
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 200,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text('Chưa có thông tin toạ độ', style: TextStyle(color: Colors.grey)),
                    ),
                  const SizedBox(height: 32),
                  const Text(
                    'Hình ảnh',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) => ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          d.imagePath,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          cacheWidth: thumbCacheWidth,
                          filterQuality: FilterQuality.low,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ReviewSection(
                    targetType: 'destination',
                    targetId: d.id,
                    fallbackRating: double.tryParse(d.rating) ?? 0.0,
                    fallbackCount: int.tryParse(d.reviewsCount) ?? 0,
                    onReviewSubmitted: () {
                      ref.invalidate(bootstrapProvider);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Giá từ',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(
                      formatVND(parsePrice(d.price)),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _navigateToCheckout(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Đặt ngay',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward,
                            color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _highlightItem(IconData icon, String title, String subtitle, Color color) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
