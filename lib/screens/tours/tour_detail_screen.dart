import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../models/tour_package.dart';
import '../../providers/trip_provider.dart';
import '../../providers/tour_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/app_utils.dart';
import '../../widgets/review_section.dart';
import '../../widgets/app_image.dart';
import '../../widgets/shimmer_loading.dart';
import '../../providers/app_state_provider.dart';
import '../checkout/payment_method_screen.dart';
import 'widgets/tour_detail_helpers.dart';
import 'widgets/tour_overview_section.dart';
import 'widgets/tour_itinerary_list.dart';
import 'widgets/tour_map_section.dart';
import 'widgets/tour_booking_bottom_bar.dart';

class TourDetailScreen extends ConsumerStatefulWidget {
  final TourPackage tour;

  const TourDetailScreen({super.key, required this.tour});

  @override
  ConsumerState<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends ConsumerState<TourDetailScreen> {
  late DateTime _selectedDate;
  int _guestsCount = 1;
  late bool _guideToggle;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 7));
    _guideToggle = widget.tour.includesGuide;
  }

  @override
  void dispose() {
    super.dispose();
  }

  double get _totalPrice {
    double singlePrice = widget.tour.price;
    if (_guideToggle && widget.tour.includesGuide) {
      singlePrice += widget.tour.guideFee;
    }
    return singlePrice * _guestsCount;
  }

  @override
  Widget build(BuildContext context) {
    final tours = ref.watch(bootstrapProvider).value?.tourPackages ?? [];
    final t = tours.firstWhere(
      (e) => e.id == widget.tour.id,
      orElse: () => widget.tour,
    );

    final coordinates = TourDetailHelpers.getCoordinates(widget.tour);
    final center = coordinates.first;
    final fallbackItinerary = TourDetailHelpers.generateItinerary(widget.tour);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Parallax Header Image
              SliverAppBar(
                expandedHeight: 340,
                pinned: true,
                stretch: true,
                backgroundColor: AppTheme.primaryBlue,
                elevation: 0,
                leadingWidth: 70,
                leading: Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      margin: const EdgeInsets.only(left: 20),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                actions: [
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        ref.read(tourFavoritesProvider.notifier).toggle(t.id);
                        final isFav = ref
                            .read(tourFavoritesProvider)
                            .contains(t.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isFav
                                  ? 'tour_detail.saved_to_favorites'.tr()
                                  : 'tour_detail.removed_from_favorites'.tr(),
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Builder(
                        builder: (context) {
                          final isFav = ref
                              .watch(tourFavoritesProvider)
                              .contains(t.id);
                          return Container(
                            margin: const EdgeInsets.only(right: 20),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                  ],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'tour_image_${t.name}',
                        child: AppImage(
                          t.imagePath,
                          fit: BoxFit.cover,
                          cacheWidth:
                              (MediaQuery.sizeOf(context).width *
                                      MediaQuery.devicePixelRatioOf(context))
                                  .round(),
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      ),
                      // Clean background without overlay texts
                    ],
                  ),
                ),
              ),

              // 2. Main Content Body
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // B. Title and Badge
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (t.isPopular)
                              Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFFF9800,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.stars,
                                      color: Color(0xFFFF9800),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'tour_detail.best_seller'.tr(),
                                      style: const TextStyle(
                                        color: Color(0xFFFF9800),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Text(
                              t.name,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // A. Overview Info Row
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TourOverviewItem(
                              icon: Icons.access_time_filled_rounded,
                              title: 'tour_detail.duration'.tr(),
                              value: t.duration,
                            ),
                            const TourOverviewDivider(),
                            TourOverviewItem(
                              icon: Icons.flight_takeoff_rounded,
                              title: 'tour_detail.departure'.tr(),
                              value: t.departure,
                            ),
                            const TourOverviewDivider(),
                            TourOverviewItem(
                              icon: Icons.map_rounded,
                              title: 'tour_detail.destination'.tr(),
                              value: 'tour_detail.destinations_count'.tr(
                                args: [t.destinations.length.toString()],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Divider(
                          height: 1,
                          color: AppTheme.backgroundGray,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Content Container inside body
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // B. Selection Section: Dates & Guests
                            Text(
                              'tour_detail.itinerary_and_booking'.tr(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textBlack,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                // Date Picker Card
                                Expanded(
                                  flex: 5,
                                  child: InkWell(
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: _selectedDate,
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now().add(
                                          const Duration(days: 365),
                                        ),
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme:
                                                  const ColorScheme.light(
                                                    primary:
                                                        AppTheme.primaryBlue,
                                                    onSurface:
                                                        AppTheme.textBlack,
                                                  ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          _selectedDate = picked;
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.grey.withValues(
                                            alpha: 0.15,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_today_rounded,
                                            color: AppTheme.primaryBlue,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'tour_detail.departure_date'
                                                      .tr(),
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  DateFormat(
                                                    'dd/MM/yyyy',
                                                  ).format(_selectedDate),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Guests Stepper Card
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.grey.withValues(
                                          alpha: 0.15,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Decrement
                                        InkWell(
                                          onTap: () {
                                            if (_guestsCount > 1) {
                                              setState(() {
                                                _guestsCount--;
                                              });
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: AppTheme.backgroundGray,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.remove,
                                              size: 16,
                                              color: AppTheme.darkGray,
                                            ),
                                          ),
                                        ),
                                        // Value
                                        Column(
                                          children: [
                                            Text(
                                              'tour_detail.guests_count'.tr(),
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 10,
                                              ),
                                            ),
                                            Text(
                                              '$_guestsCount',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Increment
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              _guestsCount++;
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: AppTheme.backgroundGray,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.add,
                                              size: 16,
                                              color: AppTheme.darkGray,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // C. Description Section
                            Text(
                              'tour_detail.introduction'.tr(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textBlack,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              t.description,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                height: 1.6,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // D. Guide Switch (If tour package includes dynamic guides)
                            if (t.includesGuide) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppTheme.primaryBlue.withValues(
                                      alpha: 0.1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(
                                        color: AppTheme.backgroundGray,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.supervisor_account_rounded,
                                        color: AppTheme.primaryBlue,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'tour_detail.tour_guide'.tr(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'tour_detail.guide_fee'.tr(
                                              args: [formatVND(t.guideFee)],
                                            ),
                                            style: const TextStyle(
                                              color: AppTheme.primaryBlue,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch.adaptive(
                                      value: _guideToggle,
                                      activeTrackColor: AppTheme.primaryBlue
                                          .withValues(alpha: 0.5),
                                      activeThumbColor: AppTheme.primaryBlue,
                                      onChanged: (val) {
                                        setState(() {
                                          _guideToggle = val;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            // E. Inclusions Grid (Dịch vụ bao gồm)
                            Text(
                              'tour_detail.inclusions'.tr(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textBlack,
                              ),
                            ),
                            const SizedBox(height: 12),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 2.8,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                  ),
                              itemCount: t.includes.length,
                              itemBuilder: (context, index) {
                                final item = t.includes[index];
                                return Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.withValues(alpha: 0.1),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryBlue
                                              .withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          TourDetailHelpers.getInclusionIcon(
                                            item,
                                          ),
                                          color: AppTheme.primaryBlue,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          item,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textBlack,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 28),

                            // F. Detailed Daily Itinerary
                            ref
                                .watch(tourScheduleProvider(widget.tour.id))
                                .when(
                                  data: (schedule) {
                                    final bool hasValidSchedule =
                                        schedule.days.isNotEmpty &&
                                        schedule.days.any(
                                          (day) => day.items.isNotEmpty,
                                        );
                                    final List<Map<String, dynamic>>
                                    finalItinerary = hasValidSchedule
                                        ? schedule.days
                                              .map(
                                                (day) => {
                                                  'day': 'tour_detail.day'.tr(
                                                    args: [
                                                      day.dayNumber.toString(),
                                                    ],
                                                  ),
                                                  'title':
                                                      'tour_detail.activity_day'
                                                          .tr(
                                                            args: [
                                                              day.dayNumber
                                                                  .toString(),
                                                            ],
                                                          ),
                                                  'desc': '',
                                                  'milestones': day.items
                                                      .map(
                                                        (item) => {
                                                          'time':
                                                              item.startTime +
                                                              (item
                                                                      .endTime
                                                                      .isNotEmpty
                                                                  ? ' - ${item.endTime}'
                                                                  : ''),
                                                          'event':
                                                              item.title +
                                                              (item
                                                                      .description
                                                                      .isNotEmpty
                                                                  ? ' - ${item.description}'
                                                                  : ''),
                                                        },
                                                      )
                                                      .toList(),
                                                },
                                              )
                                              .toList()
                                        : fallbackItinerary;
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'tour_detail.detailed_itinerary'.tr(),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textBlack,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        TourItineraryList(
                                          itinerary: finalItinerary,
                                        ),
                                      ],
                                    );
                                  },
                                  loading: () => const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: TimelineShimmer(),
                                  ),
                                  error: (e, st) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'tour_detail.detailed_itinerary'.tr(),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textBlack,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      TourItineraryList(
                                        itinerary: fallbackItinerary,
                                      ),
                                    ],
                                  ),
                                ),
                            const SizedBox(height: 12),

                            // G. Route Map
                            TourMapSection(
                              coordinates: coordinates,
                              center: center,
                            ),
                            const SizedBox(height: 28),

                            // I. Reviews Section
                            ReviewSection(
                              targetType: 'tour',
                              targetId: t.id,
                              fallbackRating: 0.0,
                              onReviewSubmitted: () {
                                ref.invalidate(bootstrapProvider);
                              },
                            ),
                            const SizedBox(
                              height: 120,
                            ), // Bottom padding for sheet
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 3. Floating Bottom Purchase Sheet
          TourBookingBottomBar(
            originalPrice: widget.tour.price,
            guestsCount: _guestsCount,
            totalPrice: _totalPrice,
            onBookPressed: _bookTour,
          ),
        ],
      ),
    );
  }

  void _bookTour() {
    if (!ref.read(authProvider).isLoggedIn) {
      showErrorSnackBar(context, 'tour_detail.login_to_book'.tr());
      context.push(AppRoutes.login);
      return;
    }

    final String formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate);
    final String guestsLabel = '$_guestsCount Người';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentMethodScreen(
          totalPrice: _totalPrice,
          onPaymentSuccess: () async {
            if (!mounted) return null;
            final success = await ref
                .read(tripsProvider.notifier)
                .bookTour(
                  tourId: widget.tour.id,
                  date: formattedDate,
                  guests: guestsLabel,
                  totalPrice: _totalPrice,
                );
            return success;
          },
        ),
      ),
    );
  }
}
