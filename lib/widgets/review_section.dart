import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../models/review.dart';
import '../widgets/star_rating.dart';
import '../providers/auth_provider.dart';
import '../providers/api_provider.dart';
import '../utils/app_utils.dart';
import 'shimmer_loading.dart';
import '../utils/dialog_utils.dart';

/// A reusable review section widget that displays reviews and allows users
/// to submit new reviews. Used across tour, hotel, and destination detail screens.
class ReviewSection extends ConsumerStatefulWidget {
  final String targetType;
  final String targetId;
  final double fallbackRating;
  final int fallbackCount;
  final VoidCallback? onReviewSubmitted;

  const ReviewSection({
    super.key,
    required this.targetType,
    required this.targetId,
    this.fallbackRating = 4.5,
    this.fallbackCount = 0,
    this.onReviewSubmitted,
  });

  @override
  ConsumerState<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends ConsumerState<ReviewSection> {
  List<Review> _reviews = [];
  int _totalReviews = 0;
  double _avgRating = 0.0;
  bool _isLoadingReviews = true;
  bool _isSubmittingReview = false;
  int _selectedRating = 5;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoadingReviews = true);
    try {
      final apiService = ref.read(apiProvider);
      final response = await apiService.getReviews(
        targetType: widget.targetType,
        targetId: widget.targetId,
      );
      if (mounted) {
        setState(() {
          _reviews = response.reviews;
          _totalReviews = response.total;
          _avgRating = response.avgRating;
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingReviews = false);
    }
  }

  void _showReviewSheet() {
    if (!ref.read(authProvider).isLoggedIn) {
      showErrorSnackBar(context, 'Vui lòng đăng nhập để đánh giá!');
      Navigator.pushNamed(context, '/login');
      return;
    }
    _selectedRating = 5;
    _commentController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: _buildReviewFormSheet,
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayRating = _totalReviews > 0
        ? _avgRating
        : widget.fallbackRating;
    final displayCount = _totalReviews > 0
        ? _totalReviews
        : widget.fallbackCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Đánh giá & Nhận xét',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _showReviewSheet,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Viết đánh giá'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryBlue,
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              displayRating > 0 ? displayRating.toStringAsFixed(1) : '--',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StarRating(rating: displayRating.round(), size: 16),
                const SizedBox(height: 4),
                Text(
                  '$displayCount nhận xét',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (_isLoadingReviews)
          const Padding(padding: EdgeInsets.all(12), child: ReviewCardShimmer())
        else if (_reviews.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.backgroundGray,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.rate_review_outlined,
                  size: 40,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                Text(
                  'Chưa có đánh giá nào',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          )
        else
          Column(children: _reviews.map(_buildReviewCard).toList()),
      ],
    );
  }

  Widget _buildReviewCard(Review review) {
    final timeAgo = getTimeAgo(review.createdAt);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                radius: 16,
                backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeAgo,
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
              ),
              StarRating(rating: review.rating, size: 12),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.comment,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewFormSheet(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setSheetState) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Viết đánh giá',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Đánh giá của bạn',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                StarRating(
                  rating: _selectedRating,
                  size: 32,
                  interactive: true,
                  onRatingChanged: (rating) {
                    setSheetState(() => _selectedRating = rating);
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Nhận xét',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _commentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Chia sẻ trải nghiệm của bạn...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryBlue),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmittingReview
                        ? null
                        : () async {
                            if (_commentController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Vui lòng nhập nhận xét'),
                                ),
                              );
                              return;
                            }
                            setSheetState(() => _isSubmittingReview = true);
                            try {
                              final apiService = ref.read(apiProvider);
                              await apiService.createReview(
                                targetType: widget.targetType,
                                targetId: widget.targetId,
                                rating: _selectedRating,
                                comment: _commentController.text.trim(),
                              );
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã gửi đánh giá thành công!'),
                                ),
                              );
                              await _loadReviews();
                              widget.onReviewSubmitted?.call();
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Lỗi: $e')),
                              );
                            } finally {
                              if (context.mounted) {
                                setSheetState(
                                  () => _isSubmittingReview = false,
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmittingReview
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Gửi đánh giá',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
