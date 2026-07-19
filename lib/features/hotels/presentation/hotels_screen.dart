import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/state/app_state_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../shared/widgets/app_placeholder_card.dart';
import '../../../shared/widgets/place_grid_card.dart';
import '../application/hotel_catalog_filter.dart';
import '../application/hotel_provider.dart';
import '../domain/hotel.dart';
import 'hotel_detail_screen.dart';
import 'widgets/hotel_filter_sheet.dart';

class HotelsScreen extends ConsumerStatefulWidget {
  const HotelsScreen({super.key});

  @override
  ConsumerState<HotelsScreen> createState() => _HotelsScreenState();
}

class _HotelsScreenState extends ConsumerState<HotelsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  HotelCatalogFilter _filter = const HotelCatalogFilter();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    ref.invalidate(bootstrapProvider);
    await ref.read(bootstrapProvider.future);
  }

  Future<void> _openFilter(List<Hotel> hotels) async {
    final selected = await showHotelFilterSheet(
      context,
      initialFilter: _filter,
      locations: hotelLocations(hotels),
      catalogMaximumPrice: hotelMaximumPrice(hotels),
    );
    if (!mounted || selected == null) return;
    setState(() => _filter = selected);
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _filter = const HotelCatalogFilter();
    });
  }

  String _sortLabel(HotelCatalogSort sort) {
    return switch (sort) {
      HotelCatalogSort.recommended => 'Đề xuất',
      HotelCatalogSort.priceAscending => 'Giá tăng dần',
      HotelCatalogSort.priceDescending => 'Giá giảm dần',
      HotelCatalogSort.roomCountDescending => 'Nhiều phòng nhất',
    };
  }

  @override
  Widget build(BuildContext context) {
    final hotels = ref.watch(hotelsProvider);
    final visibleHotels = filterHotels(
      hotels,
      query: _searchQuery,
      filter: _filter,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Khách Sạn Nổi Bật',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            key: const Key('hotel-filter-button'),
            icon: const Icon(Icons.tune, color: AppTheme.primaryBlue),
            tooltip: 'Bộ lọc & sắp xếp',
            onPressed: () => _openFilter(hotels),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundGray,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    key: const Key('hotel-search-input'),
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    decoration: InputDecoration(
                      icon: const Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: 20,
                      ),
                      hintText: 'Tìm khách sạn, địa điểm...',
                      hintStyle: TextStyle(
                        color: Colors.grey.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      suffixIcon: _searchQuery.isNotEmpty || !_filter.isDefault
                          ? IconButton(
                              key: const Key('hotel-catalog-clear'),
                              icon: const Icon(Icons.clear, size: 18),
                              tooltip: 'Xóa tìm kiếm và bộ lọc',
                              onPressed: _resetFilters,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Tìm thấy ${visibleHotels.length} khách sạn',
                      key: const Key('hotel-catalog-result-count'),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    if (_filter.location != null)
                      _activeChip(
                        key: const Key('hotel-active-location'),
                        label: _filter.location!,
                        onDeleted: () {
                          setState(() {
                            _filter = _filter.copyWith(clearLocation: true);
                          });
                        },
                      ),
                    if (_filter.maximumPrice != null)
                      _activeChip(
                        key: const Key('hotel-active-price'),
                        label: 'Tối đa ${formatVND(_filter.maximumPrice!)}',
                        onDeleted: () {
                          setState(() {
                            _filter = _filter.copyWith(clearMaximumPrice: true);
                          });
                        },
                      ),
                    if (_filter.onlyWithRooms)
                      _activeChip(
                        key: const Key('hotel-active-availability'),
                        label: 'Còn phòng',
                        onDeleted: () {
                          setState(() {
                            _filter = _filter.copyWith(onlyWithRooms: false);
                          });
                        },
                      ),
                    if (_filter.sort != HotelCatalogSort.recommended)
                      _activeChip(
                        key: const Key('hotel-active-sort'),
                        label: _sortLabel(_filter.sort),
                        onDeleted: () {
                          setState(() {
                            _filter = _filter.copyWith(
                              sort: HotelCatalogSort.recommended,
                            );
                          });
                        },
                      ),
                  ],
                ),
              ),
              Expanded(
                child: visibleHotels.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.72,
                            ),
                        itemCount: visibleHotels.length,
                        itemBuilder: (context, index) {
                          return _buildHotelGridCard(
                            context,
                            visibleHotels[index],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activeChip({
    required Key key,
    required String label,
    required VoidCallback onDeleted,
  }) {
    return InputChip(
      key: key,
      label: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 170),
        child: Text(label, overflow: TextOverflow.ellipsis),
      ),
      onPressed: onDeleted,
      onDeleted: onDeleted,
      deleteIconColor: AppTheme.primaryBlue,
      backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.08),
      side: BorderSide.none,
    );
  }

  Widget _buildHotelGridCard(BuildContext context, Hotel hotel) {
    return PlaceGridCard(
      heroTag: 'hotel_image_${hotel.id}',
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
          MaterialPageRoute(
            builder: (context) => HotelDetailScreen(hotel: hotel),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return AppPlaceholderCard(
      icon: Icons.hotel_outlined,
      title: 'Không tìm thấy khách sạn',
      subtitle: 'Không có khách sạn phù hợp với tìm kiếm và bộ lọc hiện tại.',
      actionText: 'Đặt lại bộ lọc',
      onActionTap: _resetFilters,
    );
  }
}
