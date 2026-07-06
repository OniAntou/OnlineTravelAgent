import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/document_item.dart';
import '../../models/trip.dart';
import '../../providers/profile_provider.dart';
import '../../providers/trip_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = _buildNotifications(
      trips: ref.watch(tripsProvider),
      documents: ref.watch(documentsProvider),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textBlack,
        elevation: 0,
      ),
      body: notifications.isEmpty
          ? const _EmptyNotifications()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _NotificationCard(notification: notifications[index]);
              },
            ),
    );
  }
}

List<_AppNotification> _buildNotifications({
  required List<Trip> trips,
  required List<DocumentItem> documents,
}) {
  if (trips.isEmpty && documents.isEmpty) return const [];

  final notifications = <_AppNotification>[];

  for (final trip in trips) {
    notifications.add(_notificationFromTrip(trip));
  }

  if (documents.isEmpty) {
    notifications.add(
      const _AppNotification(
        title: 'Hoàn thiện hồ sơ du lịch',
        message: 'Thêm giấy tờ cá nhân để quá trình làm thủ tục nhanh hơn.',
        timeLabel: 'Hồ sơ',
        icon: Icons.assignment_outlined,
        color: Colors.orange,
        priority: 70,
      ),
    );
  } else {
    notifications.add(
      _AppNotification(
        title: 'Hồ sơ du lịch đã sẵn sàng',
        message: 'Bạn đang lưu ${documents.length} giấy tờ trong hồ sơ.',
        timeLabel: 'Hồ sơ',
        icon: Icons.verified_user_outlined,
        color: Colors.green,
        priority: 20,
      ),
    );
  }

  notifications.sort((a, b) => b.priority.compareTo(a.priority));
  return notifications;
}

_AppNotification _notificationFromTrip(Trip trip) {
  final status = trip.status.toLowerCase();

  if (_containsAny(status, const ['cancel', 'hủy', 'huy'])) {
    return _AppNotification(
      title: 'Chuyến đi đã hủy',
      message: '${trip.destination} hiện không còn trong lịch trình sắp tới.',
      timeLabel: 'Cập nhật',
      icon: Icons.cancel_outlined,
      color: Colors.red,
      priority: 100,
    );
  }

  if (_containsAny(status, const [
    'pending',
    'payment',
    'thanh toán',
    'thanh toan',
  ])) {
    return _AppNotification(
      title: 'Chờ thanh toán',
      message: '${trip.destination} cần hoàn tất thanh toán để xác nhận.',
      timeLabel: 'Thanh toán',
      icon: Icons.payments_outlined,
      color: Colors.orange,
      priority: 90,
    );
  }

  if (_containsAny(status, const ['ongoing', 'đang', 'dang'])) {
    return _AppNotification(
      title: 'Chuyến đi đang diễn ra',
      message: '${trip.destination} đang trong lịch trình của bạn.',
      timeLabel: 'Hôm nay',
      icon: Icons.explore_outlined,
      color: AppTheme.primaryBlue,
      priority: 80,
    );
  }

  if (trip.isUpcoming) {
    return _AppNotification(
      title: 'Sắp tới: ${trip.destination}',
      message: 'Lịch trình ${trip.date} cho ${trip.guests} đã được lưu.',
      timeLabel: 'Sắp tới',
      icon: Icons.event_available_outlined,
      color: AppTheme.primaryBlue,
      priority: 60,
    );
  }

  return _AppNotification(
    title: 'Chuyến đi đã hoàn tất',
    message: '${trip.destination} đã được chuyển vào lịch sử chuyến đi.',
    timeLabel: 'Lịch sử',
    icon: Icons.check_circle_outline,
    color: Colors.green,
    priority: 40,
  );
}

bool _containsAny(String value, List<String> needles) {
  return needles.any(value.contains);
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});

  final _AppNotification notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: notification.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(notification.icon, color: notification.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  notification.message,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            notification.timeLabel,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none,
                color: AppTheme.primaryBlue,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có thông báo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Các cập nhật về chuyến đi và hồ sơ du lịch sẽ xuất hiện tại đây.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppNotification {
  const _AppNotification({
    required this.title,
    required this.message,
    required this.timeLabel,
    required this.icon,
    required this.color,
    required this.priority,
  });

  final String title;
  final String message;
  final String timeLabel;
  final IconData icon;
  final Color color;
  final int priority;
}
