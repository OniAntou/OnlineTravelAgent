import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/trip.dart';
import '../../../providers/trip_provider.dart';

class TripActionButtons extends ConsumerWidget {
  final Trip trip;
  const TripActionButtons({super.key, required this.trip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _btn(context, Icons.support_agent, 'Hỗ trợ', () => _showNotImplemented(context, 'Hỗ trợ')),
        _btn(context, Icons.receipt_long, 'Hóa đơn', () => _showNotImplemented(context, 'Hóa đơn')),
        _btn(context, Icons.share_outlined, 'Chia sẻ', () => _showNotImplemented(context, 'Chia sẻ')),
        if (trip.status != 'Đã hủy' && trip.isUpcoming)
          _btn(context, Icons.cancel_outlined, 'Hủy vé', () => _confirmCancel(context, ref)),
      ],
    );
  }

  void _showNotImplemented(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — Tính năng đang phát triển'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hủy vé'),
        content: const Text('Bạn có chắc chắn muốn hủy chuyến đi này không? Thao tác này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hủy vé', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!context.mounted) return;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        await ref.read(tripsProvider.notifier).cancelTrip(trip.id);
        if (context.mounted) {
          Navigator.pop(context); // close loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã hủy chuyến đi thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // close loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Có lỗi xảy ra khi hủy chuyến đi'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _btn(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Icon(icon, color: label == 'Hủy vé' ? Colors.red : AppTheme.primaryBlue),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: label == 'Hủy vé' ? Colors.red : const Color(0xFF555555),
            ),
          ),
        ],
      ),
    );
  }
}
