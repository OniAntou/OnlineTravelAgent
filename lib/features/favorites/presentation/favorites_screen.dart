import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../app/shell/main_tab_provider.dart';
import '../../destinations/domain/destination.dart';
import '../../../app/state/app_state_provider.dart';
import '../../auth/application/auth_provider.dart';
import '../../destinations/application/destination_provider.dart';
import '../../../shared/widgets/app_placeholder_card.dart';
import 'widgets/favorite_destination_card.dart';

class FavoritesScreen extends ConsumerWidget {
  final Function(Destination) onDestinationClick;

  const FavoritesScreen({super.key, required this.onDestinationClick});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final isLoggedIn = ref.watch(
      authProvider.select((state) => state.isLoggedIn),
    );

    Future<void> onRefresh() async {
      ref.invalidate(bootstrapProvider);
      await ref.read(bootstrapProvider.future);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const Text(
                  'Địa điểm yêu thích',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                if (!isLoggedIn)
                  const Expanded(
                    child: RequireLoginPlaceholder(
                      subtitle:
                          'Lưu lại các địa điểm yêu thích\nđể lên kế hoạch dễ dàng hơn',
                    ),
                  )
                else if (favorites.isEmpty)
                  Expanded(
                    child: AppPlaceholderCard(
                      icon: Icons.favorite_border_rounded,
                      title: 'Chưa có địa điểm yêu thích nào',
                      subtitle:
                          'Hãy tìm kiếm và lưu lại các địa điểm\nbạn muốn ghé thăm trong tương lai.',
                      actionText: tr('dashboard.explore_now'),
                      actionIcon: Icons.arrow_forward_rounded,
                      onActionTap: () =>
                          ref.read(mainTabIndexProvider.notifier).setIndex(0),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: favorites.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      padding: const EdgeInsets.only(bottom: 24),
                      itemBuilder: (context, index) {
                        return FavoriteDestinationCard(
                          destination: favorites[index],
                          onFavoriteClick: () => ref
                              .read(destinationsProvider.notifier)
                              .toggleFavorite(favorites[index].id),
                          onClick: () => onDestinationClick(favorites[index]),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
