import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final int rating;
  final int maxRating;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final bool interactive;
  final ValueChanged<int>? onRatingChanged;

  const StarRating({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 20,
    this.activeColor = Colors.amber,
    this.inactiveColor = const Color(0xFFD0D0D0),
    this.interactive = false,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        return GestureDetector(
          onTap: interactive && onRatingChanged != null
              ? () => onRatingChanged!(index + 1)
              : null,
          child: Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Icon(
              index < rating ? Icons.star_rounded : Icons.star_border_rounded,
              size: size,
              color: index < rating ? activeColor : inactiveColor,
            ),
          ),
        );
      }),
    );
  }
}

class StarRatingBar extends StatelessWidget {
  final Map<int, int> distribution;
  final int totalReviews;
  final double barWidth;

  const StarRatingBar({
    super.key,
    required this.distribution,
    required this.totalReviews,
    this.barWidth = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(5, (index) {
        final stars = 5 - index;
        final count = distribution[stars] ?? 0;
        final percentage = totalReviews > 0 ? count / totalReviews : 0.0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              SizedBox(
                width: 14,
                child: Text(
                  '$stars',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
              const SizedBox(width: 6),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: SizedBox(
                    height: 6,
                    width: barWidth,
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: const Color(0xFFE8E8E8),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 24,
                child: Text(
                  '$count',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
