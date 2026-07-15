import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/destination.dart';
import '../../models/hotel.dart';
import '../../models/tour_package.dart';

import '../../providers/api_provider.dart';
import '../../utils/app_utils.dart';

import '../tours/tour_detail_screen.dart';
import '../destination_detail/destination_detail_screen.dart';
import '../hotels/hotel_detail_screen.dart';
import '../dashboard/widgets/popular_destination_card.dart';
import '../dashboard/widgets/recommended_tour_card.dart';
import '../../widgets/place_grid_card.dart';

// Search provider
class GlobalSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void update(String value) => state = value;
}

final globalSearchQueryProvider =
    NotifierProvider.autoDispose<GlobalSearchQueryNotifier, String>(
      GlobalSearchQueryNotifier.new,
    );

final globalSearchResultsProvider = FutureProvider.autoDispose<Map<String, List<dynamic>>>((ref) async {
  final query = ref.watch(globalSearchQueryProvider);
  if (query.trim().isEmpty) return {'hotels': [], 'tours': [], 'destinations': []};
  
  // Debounce logic
  await Future.delayed(const Duration(milliseconds: 300));
  
  final api = ref.watch(apiProvider);
  return api.globalSearch(query);
});

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm Điểm đến, Khách sạn, Tour...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, size: 20, color: Colors.grey),
              onPressed: () {
                _controller.clear();
                ref.read(globalSearchQueryProvider.notifier).update('');
              },
            ),
          ),
          onChanged: (val) {
            ref.read(globalSearchQueryProvider.notifier).update(val);
          },
        ),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final query = ref.watch(globalSearchQueryProvider);
          if (query.trim().isEmpty) {
            return Center(
              child: Text(
                'Nhập từ khoá để tìm kiếm\n(ví dụ: Đà Lạt, Khách sạn 5 sao...)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
              ),
            );
          }

          final resultsAsync = ref.watch(globalSearchResultsProvider);
          return resultsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Lỗi: $err')),
            data: (data) {
              final destinations = data['destinations']?.cast<Destination>() ?? [];
              final tours = data['tours']?.cast<TourPackage>() ?? [];
              final hotels = data['hotels']?.cast<Hotel>() ?? [];

              if (destinations.isEmpty && tours.isEmpty && hotels.isEmpty) {
                return Center(
                  child: Text(
                    'Không tìm thấy kết quả nào phù hợp.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                children: [
                  if (destinations.isNotEmpty) ...[
                    _buildSectionHeader('Địa điểm'),
                    _buildDestinationsList(destinations),
                    const SizedBox(height: 32),
                  ],
                  if (tours.isNotEmpty) ...[
                    _buildSectionHeader('Tour Du Lịch'),
                    _buildToursList(tours),
                    const SizedBox(height: 32),
                  ],
                  if (hotels.isNotEmpty) ...[
                    _buildSectionHeader('Khách sạn'),
                    _buildHotelsList(hotels),
                    const SizedBox(height: 32),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDestinationsList(List<Destination> destinations) {
    return SizedBox(
      height: 240,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: destinations.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final dest = destinations[index];
          return PopularDestinationCard(
            destination: dest,
            onFavoriteClick: () {}, // Optional to implement
            onClick: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DestinationDetailScreen(
                    destination: dest,
                    onBackClick: () => Navigator.pop(context),
                    onFavoriteClick: () {},
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildToursList(List<TourPackage> tours) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: tours.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final tour = tours[index];
          return RecommendedTourCard(
            tour: tour,
            onClick: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TourDetailScreen(tour: tour)),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHotelsList(List<Hotel> hotels) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: hotels.length,
      itemBuilder: (context, index) {
        final hotel = hotels[index];
        return PlaceGridCard(
          heroTag: 'global_hotel_${hotel.id}',
          imagePath: hotel.imagePath,
          priceTag: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatVND(hotel.priceFrom),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                '/đêm',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          name: hotel.name,
          location: hotel.location,
          rating: hotel.rating,
          trailingInfo: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Chi tiết',
              style: TextStyle(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 9,
              ),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HotelDetailScreen(hotel: hotel)),
            );
          },
        );
      },
    );
  }
}
