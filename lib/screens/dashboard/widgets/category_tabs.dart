import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/destination_provider.dart';
import '../../destinations/destinations_screen.dart';
import '../../food/food_screen.dart';
import '../../hotels/hotels_screen.dart';

class CategoryTabs extends StatelessWidget {
  const CategoryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final visibleCategories = AppConstants.defaultCategories
        .where((category) => category != AppConstants.categoryFlights)
        .toList();

    return SizedBox(
      height: 48,
      child: Consumer(
        builder: (context, ref, child) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: visibleCategories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final category = visibleCategories[index];
              final isSelected =
                  ref.watch(selectedCategoryProvider) == category;
              return InkWell(
                onTap: () {
                  if (category == AppConstants.categoryHotels) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HotelsScreen(),
                      ),
                    );
                  } else if (category == AppConstants.categoryDestinations) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DestinationsScreen(initialCategory: category),
                      ),
                    );
                  } else if (category == AppConstants.categoryFood) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FoodScreen(),
                      ),
                    );
                  } else {
                    ref
                        .read(selectedCategoryProvider.notifier)
                        .update(category);
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.backgroundGray
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? AppTheme.primaryBlue : Colors.grey,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
