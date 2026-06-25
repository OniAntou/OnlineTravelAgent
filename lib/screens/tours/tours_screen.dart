import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/tour_package.dart';
import '../../providers/tour_provider.dart';
import '../../widgets/sort_bottom_sheet.dart';
import 'tour_detail_screen.dart';
import '../../providers/app_state_provider.dart';
import '../../utils/app_utils.dart';

class ToursScreen extends ConsumerStatefulWidget {
  const ToursScreen({super.key});

  @override
  ConsumerState<ToursScreen> createState() => _ToursScreenState();
}

class _ToursScreenState extends ConsumerState<ToursScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'Popular'; // 'Popular', 'PriceAsc', 'PriceDesc'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TourPackage> _getSortedAndFiltered(List<TourPackage> list) {
    var filtered = list;
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) {
        final lowerQuery = _searchQuery.toLowerCase();
        return t.name.toLowerCase().contains(lowerQuery) || 
               t.departure.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    final sorted = List<TourPackage>.from(filtered);
    if (_sortBy == 'PriceAsc') {
      sorted.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == 'PriceDesc') {
      sorted.sort((a, b) => b.price.compareTo(a.price));
    } else {
      // Popular
      sorted.sort((a, b) {
        if (a.isPopular && !b.isPopular) return -1;
        if (!a.isPopular && b.isPopular) return 1;
        return 0;
      });
    }
    return sorted;
  }

  String _getSortLabel() => getSortLabel(_sortBy);

  Future<void> _onRefresh() async {
    ref.invalidate(bootstrapProvider);
    await ref.read(bootstrapProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final allTours = ref.watch(toursProvider);
    final sortedList = _getSortedAndFiltered(allTours);

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
            icon: const Icon(Icons.tune, color: AppTheme.primaryBlue),
            onPressed: () => _showSortBottomSheet(context),
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
          // Elegant Search Input
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundGray,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (text) {
                  setState(() {
                    _searchQuery = text;
                  });
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
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),

          // Results and Sorter Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tìm thấy ${sortedList.length} gói tour',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showSortBottomSheet(context),
                  child: Row(
                    children: [
                      Text(
                        _getSortLabel(),
                        style: const TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: AppTheme.primaryBlue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Responsive Grid Layout
          Expanded(
            child: sortedList.isEmpty
                ? _buildEmptyState(context)
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 100), // extra padding for FAB
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: sortedList.length,
                    itemBuilder: (context, index) {
                      final tour = sortedList[index];
                      return _buildTourCard(context, tour);
                    },
                  ),
          ),
                  ],
      ),
          ),
      ),
      // Tạm thời ẩn nút Tự tạo tour
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => const CustomTourStepperScreen(),
      //       ),
      //     );
      //   },
      //   backgroundColor: AppTheme.primaryBlue,
      //   icon: const Icon(Icons.add_location_alt, color: Colors.white),
      //   label: const Text(
      //     'Tự Tạo Tour',
      //     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      //   ),
      // ),
    );
  }

  Widget _buildTourCard(BuildContext context, TourPackage tour) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TourDetailScreen(tour: tour),
          ),
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
            // Image with Overlays
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
                        child: Image.asset(
                          tour.imagePath,
                          fit: BoxFit.cover,
                          cacheWidth: (MediaQuery.sizeOf(context).width / 2 * MediaQuery.devicePixelRatioOf(context)).round(),
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
                  // Price tag overlay
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
            // Info text block
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
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

  Widget _buildEmptyState(BuildContext context) {
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
              'Chúng tôi không tìm thấy tour nào phù hợp với tìm kiếm của bạn. Vui lòng thử từ khóa khác.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _sortBy = 'Popular';
                });
              },
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
                'Đặt lại tìm kiếm',
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

  void _showSortBottomSheet(BuildContext context) {
    SortBottomSheet.show(context,
      currentSort: _sortBy,
      onSortChanged: (code) {
        if (code == 'Rating') return; // rating sorting not implemented for tours
        setState(() => _sortBy = code);
      },
      options: const [
        SortOption('Popular', 'Phổ biến nhất', Icons.insights),
        SortOption('PriceAsc', 'Giá từ thấp đến cao', Icons.trending_up),
        SortOption('PriceDesc', 'Giá từ cao đến thấp', Icons.trending_down),
      ],
    );
  }
}
