import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/state/app_state_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../shared/widgets/app_image.dart';
import '../application/tour_catalog_filter.dart';
import '../application/tour_provider.dart';
import '../domain/tour_package.dart';
import 'tour_detail_screen.dart';
import 'widgets/tour_filter_sheet.dart';

class ToursScreen extends ConsumerStatefulWidget {
  const ToursScreen({super.key});

  @override
  ConsumerState<ToursScreen> createState() => _ToursScreenState();
}

class _ToursScreenState extends ConsumerState<ToursScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  TourCatalogFilter _filter = const TourCatalogFilter();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    ref.invalidate(bootstrapProvider);
    await ref.read(bootstrapProvider.future);
  }

  Future<void> _openFilter(List<TourPackage> tours) async {
    final selected = await showTourFilterSheet(
      context,
      initialFilter: _filter,
      departures: tourDepartures(tours),
      catalogMaximumPrice: tourMaximumPrice(tours),
    );
    if (!mounted || selected == null) return;
    setState(() => _filter = selected);
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _filter = const TourCatalogFilter();
    });
  }

  String _sortLabel(TourCatalogSort sort) {
    return switch (sort) {
      TourCatalogSort.recommended => 'Đề xuất',
      TourCatalogSort.priceAscending => 'Giá tăng dần',
      TourCatalogSort.priceDescending => 'Giá giảm dần',
      TourCatalogSort.durationAscending => 'Ngắn nhất',
      TourCatalogSort.durationDescending => 'Dài nhất',
    };
  }

  String _durationLabel(TourDurationBucket bucket) {
    return switch (bucket) {
      TourDurationBucket.any => 'Tất cả',
      TourDurationBucket.twoToThreeDays => '2–3 ngày',
      TourDurationBucket.fourDaysOrMore => 'Từ 4 ngày',
    };
  }

  @override
  Widget build(BuildContext context) {
    final tours = ref.watch(toursProvider);
    final visibleTours = filterTours(
      tours,
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
          'Các gói Tour',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            key: const Key('tour-filter-button'),
            icon: const Icon(Icons.tune, color: AppTheme.primaryBlue),
            tooltip: 'Bộ lọc & sắp xếp',
            onPressed: () => _openFilter(tours),
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
                    key: const Key('tour-search-input'),
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
                      hintText: 'Tìm kiếm gói tour, điểm đi...',
                      hintStyle: TextStyle(
                        color: Colors.grey.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      suffixIcon: _searchQuery.isNotEmpty || !_filter.isDefault
                          ? IconButton(
                              key: const Key('tour-catalog-clear'),
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
                      'Tìm thấy ${visibleTours.length} gói tour',
                      key: const Key('tour-catalog-result-count'),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    if (_filter.departure != null)
                      _activeChip(
                        key: const Key('tour-active-departure'),
                        label: _filter.departure!,
                        onDeleted: () {
                          setState(() {
                            _filter = _filter.copyWith(clearDeparture: true);
                          });
                        },
                      ),
                    if (_filter.durationBucket != TourDurationBucket.any)
                      _activeChip(
                        key: const Key('tour-active-duration'),
                        label: _durationLabel(_filter.durationBucket),
                        onDeleted: () {
                          setState(() {
                            _filter = _filter.copyWith(
                              durationBucket: TourDurationBucket.any,
                            );
                          });
                        },
                      ),
                    if (_filter.maximumPrice != null)
                      _activeChip(
                        key: const Key('tour-active-price'),
                        label: 'Tối đa ${formatVND(_filter.maximumPrice!)}',
                        onDeleted: () {
                          setState(() {
                            _filter = _filter.copyWith(clearMaximumPrice: true);
                          });
                        },
                      ),
                    if (_filter.popularOnly)
                      _activeChip(
                        key: const Key('tour-active-popular'),
                        label: 'Tour nổi bật',
                        onDeleted: () {
                          setState(() {
                            _filter = _filter.copyWith(popularOnly: false);
                          });
                        },
                      ),
                    if (_filter.sort != TourCatalogSort.recommended)
                      _activeChip(
                        key: const Key('tour-active-sort'),
                        label: _sortLabel(_filter.sort),
                        onDeleted: () {
                          setState(() {
                            _filter = _filter.copyWith(
                              sort: TourCatalogSort.recommended,
                            );
                          });
                        },
                      ),
                  ],
                ),
              ),
              Expanded(
                child: visibleTours.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.68,
                            ),
                        itemCount: visibleTours.length,
                        itemBuilder: (context, index) {
                          return _buildTourCard(context, visibleTours[index]);
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

  Widget _buildTourCard(BuildContext context, TourPackage tour) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TourDetailScreen(tour: tour)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      child: Hero(
                        tag: 'tour_image_${tour.name}',
                        child: AppImage(
                          tour.imagePath,
                          fit: BoxFit.cover,
                          cacheWidth:
                              (MediaQuery.sizeOf(context).width /
                                      2 *
                                      MediaQuery.devicePixelRatioOf(context))
                                  .round(),
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        formatVND(tour.price),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tour.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.flight_takeoff,
                          size: 12,
                          color: AppTheme.primaryBlue,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Từ ${tour.departure}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tour.duration,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.card_travel,
                size: 64,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Không tìm thấy gói tour',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Không có tour phù hợp với tìm kiếm và bộ lọc hiện tại.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _resetFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Đặt lại bộ lọc',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
