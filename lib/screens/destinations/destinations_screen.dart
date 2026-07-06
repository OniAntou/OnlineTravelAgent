import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/destination.dart';
import '../../providers/destination_provider.dart';
import '../../widgets/sort_bottom_sheet.dart';
import '../destination_detail/destination_detail_screen.dart';
import '../../providers/app_state_provider.dart';
import '../../utils/app_utils.dart';
import '../../widgets/app_placeholder_card.dart';
import '../../widgets/place_grid_card.dart';

class DestinationsScreen extends ConsumerStatefulWidget {
  final String? initialCategory;

  const DestinationsScreen({super.key, this.initialCategory});

  @override
  ConsumerState<DestinationsScreen> createState() => _DestinationsScreenState();
}

class _DestinationsScreenState extends ConsumerState<DestinationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'Popular'; // 'Popular', 'PriceAsc', 'PriceDesc', 'Rating'

  @override
  void initState() {
    super.initState();
    // Initialize provider search/category from widget fields or keep synchronized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialCategory != null) {
        ref
            .read(selectedCategoryProvider.notifier)
            .update(widget.initialCategory!);
      }
      _searchController.text = ref.watch(searchQueryProvider);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    ref.invalidate(bootstrapProvider);
    await ref.read(bootstrapProvider.future);
  }

  double _parseReviewsCount(String reviewsCount) =>
      parseReviewsCount(reviewsCount);

  List<Destination> _getSortedAndFiltered(List<Destination> list) {
    final sorted = List<Destination>.from(list);
    if (_sortBy == 'PriceAsc') {
      sorted.sort((a, b) {
        final priceA =
            double.tryParse(a.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
        final priceB =
            double.tryParse(b.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
        return priceA.compareTo(priceB);
      });
    } else if (_sortBy == 'PriceDesc') {
      sorted.sort((a, b) {
        final priceA =
            double.tryParse(a.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
        final priceB =
            double.tryParse(b.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
        return priceB.compareTo(priceA);
      });
    } else if (_sortBy == 'Rating') {
      sorted.sort((a, b) {
        final ratingA = double.tryParse(a.rating) ?? 0.0;
        final ratingB = double.tryParse(b.rating) ?? 0.0;
        return ratingB.compareTo(ratingA);
      });
    } else {
      // Popular (by reviews count)
      sorted.sort((a, b) {
        final countA = _parseReviewsCount(a.reviewsCount);
        final countB = _parseReviewsCount(b.reviewsCount);
        return countB.compareTo(countA);
      });
    }
    return sorted;
  }

  String _getSortLabel() => getSortLabel(_sortBy);

  void _resetFiltersOnExit() {
    ref.read(searchQueryProvider.notifier).update('');
    ref.read(selectedCategoryProvider.notifier).update('Tất cả');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _resetFiltersOnExit();
        }
      },
      child: Scaffold(
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
            onPressed: () {
              _resetFiltersOnExit();
              Navigator.pop(context);
            },
          ),
          title: const Text(
            'Khám Phá Địa Điểm',
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
          child: Consumer(
            builder: (context, ref, _) {
              final sortedList = _getSortedAndFiltered(
                ref.watch(filteredDestinationsProvider),
              );
              return RefreshIndicator(
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
                          onChanged: (text) => ref
                              .read(searchQueryProvider.notifier)
                              .update(text),
                          decoration: InputDecoration(
                            icon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                              size: 20,
                            ),
                            hintText: 'Tìm kiếm địa điểm du lịch...',
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
                                      ref
                                          .read(searchQueryProvider.notifier)
                                          .update('');
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
                            'Tìm thấy ${sortedList.length} địa điểm',
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
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                10,
                                20,
                                24,
                              ),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 20,
                                    crossAxisSpacing: 16,
                                    childAspectRatio: 0.72,
                                  ),
                              itemCount: sortedList.length,
                              itemBuilder: (context, index) {
                                final destination = sortedList[index];
                                return _buildDestinationCard(
                                  context,
                                  destination,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationCard(BuildContext context, Destination destination) {
    return PlaceGridCard(
      heroTag: 'dest_image_${destination.name}',
      imagePath: destination.imagePath,
      priceTag: Text(
        formatVND(parsePrice(destination.price)),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
      topAction: GestureDetector(
        onTap: () {
          ref
              .read(destinationsProvider.notifier)
              .toggleFavorite(destination.id);
        },
        child: CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          child: Icon(
            destination.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: destination.isFavorite ? Colors.red : Colors.black87,
            size: 18,
          ),
        ),
      ),
      name: destination.name,
      location: destination.location,
      rating: destination.rating,
      trailingInfo: Text(
        destination.duration,
        style: TextStyle(color: Colors.grey[500], fontSize: 11),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DestinationDetailScreen(
              destination: destination,
              onBackClick: () => Navigator.pop(context),
              onFavoriteClick: () => ref
                  .read(destinationsProvider.notifier)
                  .toggleFavorite(destination.id),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: AppPlaceholderCard(
        icon: Icons.map_outlined,
        title: 'Không tìm thấy địa điểm',
        subtitle:
            'Chúng tôi không tìm thấy địa điểm nào phù hợp với bộ lọc hiện tại. Vui lòng thử tìm kiếm khác.',
        actionText: 'Đặt lại bộ lọc',
        onActionTap: () {
          ref.read(searchQueryProvider.notifier).update('');
          ref.read(selectedCategoryProvider.notifier).update('Tất cả');
          _searchController.clear();
          setState(() {
            _sortBy = 'Popular';
          });
        },
      ),
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    SortBottomSheet.show(
      context,
      currentSort: _sortBy,
      onSortChanged: (code) => setState(() => _sortBy = code),
      options: const [
        SortOption('Popular', 'Phổ biến nhất', Icons.insights),
        SortOption('Rating', 'Đánh giá tốt nhất', Icons.star),
        SortOption('PriceAsc', 'Giá từ thấp đến cao', Icons.trending_up),
        SortOption('PriceDesc', 'Giá từ cao đến thấp', Icons.trending_down),
      ],
    );
  }
}
