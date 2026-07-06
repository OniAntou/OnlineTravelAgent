import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/trip.dart';
import '../../../models/trip_schedule.dart';
import '../../../providers/trip_schedule_provider.dart';
import '../../../widgets/shimmer_loading.dart';

class TripScheduleTimeline extends ConsumerStatefulWidget {
  final Trip trip;

  const TripScheduleTimeline({super.key, required this.trip});

  @override
  ConsumerState<TripScheduleTimeline> createState() =>
      _TripScheduleTimelineState();
}

class _TripScheduleTimelineState extends ConsumerState<TripScheduleTimeline> {
  int _selectedDayIndex = 0;

  // Custom Time simulation for testing
  int? _simulatedHour;
  int? _simulatedMinute;
  bool _showSimulatePanel = false;

  Timer? _refreshTimer;
  int _lastUpdateMinute = -1;

  @override
  void initState() {
    super.initState();
    _startRefreshTimer();
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!mounted) return;
      final now = TimeOfDay.now();
      final currentMinute = now.hour * 60 + now.minute;
      // Only rebuild when minute changes (status might have changed)
      if (currentMinute != _lastUpdateMinute) {
        _lastUpdateMinute = currentMinute;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  int _timeToMinutes(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length != 2) return 0;
    final hr = int.tryParse(parts[0]) ?? 0;
    final mn = int.tryParse(parts[1]) ?? 0;
    return hr * 60 + mn;
  }

  String _getMilestoneStatus(List<TripScheduleItem> items, int index) {
    final item = items[index];
    if (item.statusOverride != null && item.statusOverride!.isNotEmpty) {
      return item.statusOverride!;
    }

    final statusLower = widget.trip.status.toLowerCase();
    if (statusLower == 'đã đi' ||
        statusLower == 'hoàn thành' ||
        statusLower == 'completed') {
      return 'completed';
    }
    if (statusLower == 'sắp tới' &&
        (_simulatedHour == null || _simulatedMinute == null)) {
      return 'upcoming';
    }

    // Process real-time or simulated tracking
    int currentMinutes;
    if (_simulatedHour != null && _simulatedMinute != null) {
      currentMinutes = _simulatedHour! * 60 + _simulatedMinute!;
    } else {
      final now = TimeOfDay.now();
      currentMinutes = now.hour * 60 + now.minute;
    }

    // Find the currently active index
    int activeIndex = -1;
    for (int i = 0; i < items.length; i++) {
      final mMin = _timeToMinutes(items[i].startTime);
      if (currentMinutes >= mMin) {
        activeIndex = i;
      }
    }

    if (index < activeIndex) {
      return 'completed';
    } else if (index == activeIndex) {
      return 'ongoing';
    } else {
      return 'upcoming';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(tripScheduleProvider(widget.trip.id));

    return scheduleAsync.when(
      data: (schedule) {
        if (schedule.days.isEmpty) {
          return const SizedBox.shrink();
        }

        final isOngoingTrip =
            widget.trip.status.toLowerCase() == 'đang diễn ra' ||
            widget.trip.status.toLowerCase() == 'ongoing';
        final totalDays = schedule.days.length;

        // Auto-select today if not specified
        if (_selectedDayIndex >= totalDays) {
          _selectedDayIndex = 0;
        }

        final currentDay = schedule.days[_selectedDayIndex];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lịch trình chi tiết',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textBlack,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showSimulatePanel = !_showSimulatePanel;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _showSimulatePanel
                          ? AppTheme.primaryBlue.withValues(alpha: 0.08)
                          : Colors.white,
                      border: Border.all(
                        color: _showSimulatePanel
                            ? AppTheme.primaryBlue
                            : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          size: 14,
                          color: _showSimulatePanel
                              ? AppTheme.primaryBlue
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Giả lập',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _showSimulatePanel
                                ? AppTheme.primaryBlue
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Admin Updates Banner
            if (schedule.updates.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.campaign_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thông báo từ HDV / Ban quản lý',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            schedule.updates.first.message,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Real-time tracking status banner if ongoing or simulated
            if (isOngoingTrip || _simulatedHour != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.flash_on_rounded,
                      color: Colors.green,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _simulatedHour != null
                            ? '⚡ Chế độ giả lập: Đang chạy ở lúc ${_simulatedHour.toString().padLeft(2, '0')}:${(_simulatedMinute ?? 0).toString().padLeft(2, '0')}'
                            : '⚡ Đang tự động theo dõi lịch trình theo thời gian thực tế',
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Time simulation control panel
            if (_showSimulatePanel) _buildSimulationControlPanel(),

            // Day Selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(totalDays, (index) {
                  final dayData = schedule.days[index];
                  final isSelected = _selectedDayIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8, bottom: 16),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedDayIndex = index;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryBlue
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryBlue
                                : Colors.grey.shade300,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppTheme.primaryBlue.withValues(
                                      alpha: 0.25,
                                    ),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          'Ngày ${dayData.dayNumber}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Timeline
            _buildMilestonesTimeline(currentDay.items),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: TimelineShimmer(),
      ),
      error: (e, st) => Center(child: Text('Lỗi khi tải lịch trình: $e')),
    );
  }

  Widget _buildSimulationControlPanel() {
    final List<Map<String, dynamic>> selectOptions = [
      {'label': 'Sáng sớm (07:00)', 'hour': 7, 'min': 0},
      {'label': 'Đón khách (08:45)', 'hour': 8, 'min': 45},
      {'label': 'Hoạt động sáng (10:30)', 'hour': 10, 'min': 30},
      {'label': 'Giờ ăn trưa (12:30)', 'hour': 12, 'min': 30},
      {'label': 'Hoạt động chiều (15:00)', 'hour': 15, 'min': 0},
      {'label': 'Bữa tối (19:00)', 'hour': 19, 'min': 0},
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chọn mốc giờ để thử nghiệm Real-Time Tracking:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.textBlack,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectOptions.map((opt) {
              final isCurrent =
                  _simulatedHour == opt['hour'] &&
                  _simulatedMinute == opt['min'];
              return ChoiceChip(
                label: Text(
                  opt['label'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    color: isCurrent ? Colors.white : Colors.black87,
                  ),
                ),
                selected: isCurrent,
                selectedColor: AppTheme.primaryBlue,
                backgroundColor: Colors.white,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _simulatedHour = opt['hour'] as int;
                      _simulatedMinute = opt['min'] as int;
                    } else {
                      _simulatedHour = null;
                      _simulatedMinute = null;
                    }
                  });
                },
              );
            }).toList(),
          ),
          if (_simulatedHour != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _simulatedHour = null;
                    _simulatedMinute = null;
                  });
                },
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 14,
                  color: Colors.red,
                ),
                label: const Text(
                  'Về thực tế',
                  style: TextStyle(fontSize: 12, color: Colors.red),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMilestonesTimeline(List<TripScheduleItem> items) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(30),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có dữ liệu lịch trình cho ngày này',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Column(
      children: List.generate(items.length, (index) {
        final item = items[index];
        final isLast = index == items.length - 1;
        final status = _getMilestoneStatus(items, index);

        Color dotColor;
        Color lineColor;
        double lineOpacity;
        IconData? iconData;

        if (status == 'completed') {
          dotColor = AppTheme.primaryBlue;
          lineColor = AppTheme.primaryBlue;
          lineOpacity = 1.0;
          iconData = Icons.check_circle_rounded;
        } else if (status == 'ongoing') {
          dotColor = const Color(0xFFFF9800);
          lineColor = Colors.grey.shade300;
          lineOpacity = 0.5;
          iconData = Icons.play_circle_filled_rounded;
        } else if (status == 'cancelled') {
          dotColor = Colors.red;
          lineColor = Colors.grey.shade300;
          lineOpacity = 0.5;
          iconData = Icons.cancel_rounded;
        } else {
          dotColor = Colors.grey.shade300;
          lineColor = Colors.grey.shade300;
          lineOpacity = 0.5;
          iconData = Icons.circle_outlined;
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timeline Column
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: status == 'ongoing'
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFFFF9800,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        iconData,
                        color: dotColor,
                        size: status == 'ongoing' ? 24 : 20,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: lineColor.withValues(alpha: lineOpacity),
                        ),
                      ),
                    if (isLast) const SizedBox(height: 20),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Content Column
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: status == 'ongoing'
                          ? const Color(0xFFFFF3E0)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: status == 'ongoing'
                            ? const Color(0xFFFFCC80)
                            : Colors.grey.shade200,
                      ),
                      boxShadow: status == 'ongoing'
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFFFF9800,
                                ).withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.startTime +
                                  (item.endTime.isNotEmpty
                                      ? ' - ${item.endTime}'
                                      : ''),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: status == 'completed'
                                    ? AppTheme.primaryBlue
                                    : (status == 'ongoing'
                                          ? const Color(0xFFE65100)
                                          : Colors.grey.shade500),
                              ),
                            ),
                            if (status == 'ongoing')
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF9800),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Đang diễn ra',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (status == 'cancelled')
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Đã huỷ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: status == 'cancelled'
                                ? Colors.grey
                                : AppTheme.textBlack,
                            decoration: status == 'cancelled'
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: status == 'cancelled'
                                ? Colors.grey
                                : Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                        if (item.location.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item.location,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
