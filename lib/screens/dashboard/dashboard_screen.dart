import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/theme/app_theme.dart';
import '../../models/destination.dart';
import '../../providers/destination_provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/tour_provider.dart';

import '../destinations/destinations_screen.dart';
import '../notifications/notifications_screen.dart';
import '../tours/tour_detail_screen.dart';
import '../tours/tours_screen.dart';

import 'widgets/popular_destination_card.dart';
import 'widgets/recommended_tour_card.dart';
import 'widgets/travel_stories_section.dart';
import 'widgets/flight_banner.dart';
import 'widgets/category_tabs.dart';
import 'widgets/trending_section.dart';
import 'widgets/daily_tip.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final Function(Destination) onDestinationClick;

  const DashboardScreen({super.key, required this.onDestinationClick});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildHeader(),
                const SizedBox(height: 24),
                _buildSearchBar(),
                const SizedBox(height: 32),
                const CategoryTabs(),
                const SizedBox(height: 24),
                const FlightBanner(),
                const SizedBox(height: 32),
                _buildPopularDestinationsHeader(),
                const SizedBox(height: 8),
                _buildPopularDestinationsList(),
                const SizedBox(height: 32),
                _buildRecommendedToursHeader(),
                const SizedBox(height: 16),
                _buildRecommendedToursList(),
                const SizedBox(height: 32),
                _buildUpcomingTrip(),
                const DailyTip(),
                const SizedBox(height: 24),
                const TrendingSection(),
                const SizedBox(height: 32),
                const TravelStoriesSection(),
                const SizedBox(height: 64),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('home.hello'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  tr('home.search_hint'),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontSize: 32),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_none,
                color: AppTheme.primaryBlue,
                size: 30,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.backgroundGray,
          borderRadius: BorderRadius.circular(24),
        ),
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _searchController,
          builder: (context, value, child) {
            return TextField(
              controller: _searchController,
              onChanged: (text) =>
                  ref.read(searchQueryProvider.notifier).update(text),
              decoration: InputDecoration(
                icon: const Icon(Icons.search, color: Colors.grey, size: 20),
                hintText: tr('home.search_placeholder'),
                hintStyle: TextStyle(
                  color: Colors.grey.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                suffixIcon: value.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).update('');
                        },
                      )
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPopularDestinationsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            tr('home.popular_destinations'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const DestinationsScreen(initialCategory: 'Địa điểm'),
                ),
              );
            },
            child: Text(
              tr('home.view_all'),
              style: const TextStyle(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularDestinationsList() {
    return Consumer(
      builder: (context, ref, child) {
        if (ref.watch(filteredDestinationsProvider).isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(tr('home.no_destinations')),
            ),
          );
        }
        final displayList = ref
            .watch(filteredDestinationsProvider)
            .take(5)
            .toList();
        return SizedBox(
          height: 240,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: displayList.length,
            separatorBuilder: (_, _) => const SizedBox(width: 20),
            itemBuilder: (context, index) {
              if (index >= displayList.length) {
                return const SizedBox.shrink();
              }
              return PopularDestinationCard(
                destination: displayList[index],
                onFavoriteClick: () => ref
                    .read(destinationsProvider.notifier)
                    .toggleFavorite(displayList[index].id),
                onClick: () => widget.onDestinationClick(displayList[index]),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildRecommendedToursHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            tr('home.recommended_tours'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ToursScreen()),
              );
            },
            child: Text(
              tr('home.view_all'),
              style: const TextStyle(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedToursList() {
    return Consumer(
      builder: (context, ref, child) {
        if (ref.watch(toursProvider).isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(tr('home.no_tours')),
            ),
          );
        }
        final displayList = ref.watch(toursProvider).take(5).toList();
        return SizedBox(
          height: 200,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: displayList.length,
            separatorBuilder: (_, _) => const SizedBox(width: 20),
            itemBuilder: (context, index) {
              if (index >= displayList.length) {
                return const SizedBox.shrink();
              }
              final tour = displayList[index];
              return RecommendedTourCard(
                tour: tour,
                onClick: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TourDetailScreen(tour: tour),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildUpcomingTrip() {
    return Consumer(
      builder: (context, ref, _) {
        final trips = ref.watch(tripsProvider);
        if (trips.isEmpty) {
          return const SizedBox.shrink();
        }
        final upcomingTrip = trips.first;
        return Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: AppTheme.primaryBlue),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${tr('home.upcoming_trip')} ${upcomingTrip.destination}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        upcomingTrip.date,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
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
