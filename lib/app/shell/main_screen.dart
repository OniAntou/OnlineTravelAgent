import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../state/app_state_provider.dart';
import '../../features/destinations/application/destination_provider.dart';
import '../../shared/widgets/status/availability_state_view.dart';

import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/destinations/presentation/destination_detail_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/trips/presentation/my_trips_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'main_tab_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  // Track visited tabs and only build them after first selection.
  final Set<int> _visitedTabs = {0};

  final List<String> _titleKeys = [
    'bottom_nav.home',
    'bottom_nav.my_trips',
    'bottom_nav.favorites',
    'bottom_nav.profile',
  ];
  final List<IconData> _icons = [
    Icons.home,
    Icons.confirmation_number,
    Icons.favorite_border,
    Icons.person_outline,
  ];

  @override
  Widget build(BuildContext context) {
    final bootstrapAsync = ref.watch(bootstrapProvider);
    final selectedDestination = ref.watch(selectedDestinationProvider);
    final selectedIndex = ref.watch(mainTabIndexProvider);
    
    _visitedTabs.add(selectedIndex);

    // Lắng nghe lỗi favorite và hiển thị SnackBar
    ref.listen<String?>(destinationErrorProvider, (previous, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Reset state lỗi
        ref.read(destinationErrorProvider.notifier).setError(null);
      }
    });

    return bootstrapAsync.when(
      loading: () => const Scaffold(body: SafeArea(child: _SkeletonLoading())),
      error: (error, stack) => Scaffold(
        body: AvailabilityStateView(
          title: 'Không thể tải dữ liệu',
          message: 'Kiểm tra kết nối mạng rồi thử lại.',
          actionLabel: 'Thử lại',
          onRetry: () => ref.invalidate(bootstrapProvider),
        ),
      ),
      data: (_) => Scaffold(
        body: selectedDestination != null
            ? DestinationDetailScreen(
                destination: selectedDestination,
                onBackClick: () =>
                    ref.read(selectedDestinationProvider.notifier).update(null),
                onFavoriteClick: () => ref
                    .read(destinationsProvider.notifier)
                    .toggleFavorite(selectedDestination.id),
              )
            : _buildLazyIndexedStack(selectedIndex),
        bottomNavigationBar: selectedDestination == null
            ? _buildBottomNavigationBar(selectedIndex)
            : null,
      ),
    );
  }

  Widget _buildLazyIndexedStack(int selectedIndex) {
    return IndexedStack(
      index: selectedIndex,
      children: List.generate(4, (index) {
        if (!_visitedTabs.contains(index)) {
          return const SizedBox.shrink();
        }
        return _buildTabContent(index);
      }),
    );
  }

  Widget _buildTabContent(int index) {
    switch (index) {
      case 0:
        return DashboardScreen(
          onDestinationClick: (dest) =>
              ref.read(selectedDestinationProvider.notifier).update(dest),
        );
      case 1:
        return const MyTripsScreen();
      case 2:
        return FavoritesScreen(
          onDestinationClick: (dest) =>
              ref.read(selectedDestinationProvider.notifier).update(dest),
        );
      case 3:
        return const ProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomNavigationBar(int selectedIndex) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (index) {
              ref.read(mainTabIndexProvider.notifier).setIndex(index);
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppTheme.primaryBlue,
            unselectedItemColor: Colors.grey.withValues(alpha: 0.5),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            iconSize: 30,
            selectedLabelStyle: const TextStyle(fontSize: 14),
            unselectedLabelStyle: const TextStyle(fontSize: 14),
            elevation: 0,
            items: List.generate(
              _titleKeys.length,
              (index) => BottomNavigationBarItem(
                icon: Icon(_icons[index]),
                label: _titleKeys[index].tr(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonLoading extends StatelessWidget {
  const _SkeletonLoading();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 100, height: 14, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(width: 200, height: 32, color: Colors.white),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Search bar
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          const SizedBox(height: 32),
          // Categories
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                4,
                (index) => Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Container(
                    width: 80,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Flight banner
          Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 32),
          // Popular Destinations Title
          Container(width: 150, height: 24, color: Colors.white),
          const SizedBox(height: 16),
          // Destination Cards
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                2,
                (index) => Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Container(
                    width: 200,
                    height: 240,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
