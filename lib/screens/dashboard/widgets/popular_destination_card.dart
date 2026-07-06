import 'package:flutter/material.dart';
import '../../../models/destination.dart';
import '../../../core/theme/app_theme.dart';

class PopularDestinationCard extends StatelessWidget {
  final Destination destination;
  final VoidCallback onFavoriteClick;
  final VoidCallback onClick;

  const PopularDestinationCard({
    super.key,
    required this.destination,
    required this.onFavoriteClick,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    final cacheWidth = (188 * MediaQuery.devicePixelRatioOf(context)).round();

    return GestureDetector(
      onTap: onClick,
      child: Container(
        width: 188,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Hero(
              tag: 'dest_image_${destination.name}',
              child: Image.asset(
                destination.imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                cacheWidth: cacheWidth,
                filterQuality: FilterQuality.low,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: GestureDetector(
                onTap: onFavoriteClick,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    destination.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    size: 16,
                    color: destination.isFavorite ? Colors.red : Colors.grey,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.darkGray.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      destination.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.darkGray.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          destination.rating,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
