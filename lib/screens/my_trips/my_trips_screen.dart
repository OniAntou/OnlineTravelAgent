import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/trip.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/auth_provider.dart';
import 'place_trip_detail_screen.dart';
import 'tour_trip_detail_screen.dart';
import 'widgets/trip_card.dart';
import '../../widgets/app_placeholder_card.dart';

class MyTripsScreen extends ConsumerStatefulWidget {
  const MyTripsScreen({super.key});

  @override
  ConsumerState<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends ConsumerState<MyTripsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _activeProductFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    ref.invalidate(bootstrapProvider);
    await ref.read(bootstrapProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: Consumer(
          builder: (context, ref, child) {
            final isLoggedIn = ref.watch(authProvider.select((state) => state.isLoggedIn));
            if (!isLoggedIn) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 24),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Chuyến đi của tôi',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textBlack,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: RequireLoginPlaceholder(
                      subtitle: 'Bạn cần đăng nhập để xem danh sách các chuyến đi và lịch sử đặt chỗ của mình.',
                    ),
                  ),
                ],
              );
            }

            final ongoing = ref.watch(ongoingTripsProvider);
            final upcoming = ref.watch(upcomingTripsProvider);
            final history = ref.watch(historyTripsProvider);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 24),
                  ),
                  const SliverToBoxAdapter(
                    child: Text(
                      'Chuyến đi của tôi',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textBlack,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey[500],
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(text: 'Đang diễn ra'),
                          Tab(text: 'Sắp tới'),
                          Tab(text: 'Lịch sử'),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 16),
                  ),
                  SliverFillRemaining(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _tripList(ongoing),
                        _tripList(upcoming),
                        _tripList(history),
                      ],
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

  List<Trip> _filterTripsByProduct(List<Trip> trips) {
    if (_activeProductFilter == 'all') {
      return trips;
    } else if (_activeProductFilter == 'tour') {
      return trips.where((t) => t.isCustom || t.id.startsWith('trip_tour_') || t.id.startsWith('trip_custom_')).toList();
    } else if (_activeProductFilter == 'place') {
      return trips.where((t) => 
        !t.isCustom && 
        !t.id.startsWith('trip_tour_') && 
        !t.id.startsWith('trip_custom_') && 
        t.hotelId == null && 
        !t.id.startsWith('trip-hotel-') && 
        t.flightId == null && 
        !t.id.startsWith('trip-fl-')
      ).toList();
    } else if (_activeProductFilter == 'hotel') {
      return trips.where((t) => t.hotelId != null || t.id.startsWith('trip-hotel-')).toList();
    } else if (_activeProductFilter == 'flight') {
      return trips.where((t) => t.flightId != null || t.id.startsWith('trip-fl-')).toList();
    }
    return trips;
  }

  Widget _buildFilterChips() {
    final filters = [
      {'id': 'all', 'label': 'Tất cả'},
      {'id': 'tour', 'label': 'Gói Tour'},
      {'id': 'place', 'label': 'Địa điểm'},
      {'id': 'hotel', 'label': 'Khách sạn'},
      {'id': 'flight', 'label': 'Vé máy bay'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: filters.map((f) {
          final isSelected = _activeProductFilter == f['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _activeProductFilter = f['id']!;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryBlue.withValues(alpha: 0.08)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? AppTheme.primaryBlue
                        : Colors.grey.withValues(alpha: 0.15),
                  ),
                ),
                child: Text(
                  f['label']!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppTheme.primaryBlue : Colors.grey[600],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _tripList(List<Trip> filteredTrips) {
    final finalTrips = _filterTripsByProduct(filteredTrips);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterChips(),
        const SizedBox(height: 4),
        Expanded(
          child: finalTrips.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  itemCount: finalTrips.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  padding: const EdgeInsets.only(bottom: 24, top: 4),
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final trip = finalTrips[index];
                    return GestureDetector(
                      onTap: () {
                        final isTour = trip.isCustom ||
                            trip.id.startsWith('trip_tour_') ||
                            trip.id.startsWith('trip_custom_') ||
                            trip.id.toLowerCase().contains('tour');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => isTour
                                ? TourTripDetailScreen(trip: trip)
                                : PlaceTripDetailScreen(trip: trip),
                          ),
                        );
                      },
                      child: TripCard(trip: trip),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return AppPlaceholderCard(
      icon: Icons.explore_rounded,
      title: 'Bắt đầu hành trình mới',
      subtitle: 'Bạn chưa có chuyến đi nào được lên lịch. Hãy bắt đầu lên kế hoạch cho hành trình tiếp theo của bạn ngay hôm nay để nhận những ưu đãi hấp dẫn nhất.',
      actionText: 'Khám phá ngay',
      actionIcon: Icons.arrow_forward_rounded,
      onActionTap: () {
        Navigator.pushReplacementNamed(context, '/main');
      },
    );
  }

}
