import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/destination.dart';
import '../../providers/destination_provider.dart';
import '../../widgets/sort_bottom_sheet.dart';
import '../destination_detail/destination_detail_screen.dart';
import '../../utils/app_utils.dart';
import '../../widgets/app_placeholder_card.dart';
import '../../widgets/place_grid_card.dart';

class FoodScreen extends ConsumerStatefulWidget {
  const FoodScreen({super.key});

  @override
  ConsumerState<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends ConsumerState<FoodScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'Popular';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double _parseReviewsCount(String reviewsCount) =>
      parseReviewsCount(reviewsCount);

  List<Destination> _getFilteredAndSorted(
    List<Destination> list,
    String query,
  ) {
    final List<Destination> filtered = list.where((d) {
      final nameMatches = d.name.toLowerCase().contains(query.toLowerCase());
      final locationMatches = d.location.toLowerCase().contains(
        query.toLowerCase(),
      );
      return nameMatches || locationMatches;
    }).toList();

    if (_sortBy == 'PriceAsc') {
      filtered.sort((a, b) {
        final priceA =
            double.tryParse(a.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
        final priceB =
            double.tryParse(b.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
        return priceA.compareTo(priceB);
      });
    } else if (_sortBy == 'PriceDesc') {
      filtered.sort((a, b) {
        final priceA =
            double.tryParse(a.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
        final priceB =
            double.tryParse(b.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
        return priceB.compareTo(priceA);
      });
    } else if (_sortBy == 'Rating') {
      filtered.sort((a, b) {
        final ratingA = double.tryParse(a.rating) ?? 0.0;
        final ratingB = double.tryParse(b.rating) ?? 0.0;
        return ratingB.compareTo(ratingA);
      });
    } else {
      filtered.sort((a, b) {
        final countA = _parseReviewsCount(a.reviewsCount);
        final countB = _parseReviewsCount(b.reviewsCount);
        return countB.compareTo(countA);
      });
    }
    return filtered;
  }

  String _getSortLabel() => getSortLabel(_sortBy);

  @override
  Widget build(BuildContext context) {
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Khám Phá Ẩm Thực',
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
            final searchQuery = ref.watch(searchQueryProvider);
            final foods = _getFilteredAndSorted(
              ref.watch(foodDestinationsProvider),
              searchQuery,
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      onChanged: (text) =>
                          ref.read(searchQueryProvider.notifier).update(text),
                      decoration: InputDecoration(
                        icon: const Icon(
                          Icons.restaurant,
                          color: Colors.grey,
                          size: 20,
                        ),
                        hintText: 'Tìm món ăn, địa điểm...',
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

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tìm thấy ${foods.length} món ăn',
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

                Expanded(
                  child: foods.isEmpty
                      ? _buildEmptyState(context)
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.72,
                              ),
                          itemCount: foods.length,
                          itemBuilder: (context, index) {
                            return _buildFoodCard(context, foods[index]);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFoodCard(BuildContext context, Destination destination) {
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
        icon: Icons.restaurant_outlined,
        title: 'Không tìm thấy món ăn',
        subtitle:
            'Chúng tôi không tìm thấy món ăn nào phù hợp. Vui lòng thử tìm kiếm với từ khóa khác.',
        actionText: 'Đặt lại bộ lọc',
        onActionTap: () {
          _searchController.clear();
          ref.read(searchQueryProvider.notifier).update('');
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
