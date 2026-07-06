import 'package:flutter/material.dart';
import '../../../models/trip.dart';
import '../../../utils/app_utils.dart';

class BookingInfoCard extends StatelessWidget {
  final Trip trip;
  const BookingInfoCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final hashStr = trip.id.toUpperCase().hashCode.abs().toString();
    final bookingCode =
        'BK-${hashStr.length >= 6 ? hashStr.substring(0, 6) : hashStr.padLeft(6, '0')}';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _row(Icons.calendar_today, 'Ngày đi', trip.date),
          const SizedBox(height: 14),
          _row(Icons.person, 'Hành khách', trip.guests),
          const SizedBox(height: 14),
          _row(Icons.confirmation_num_outlined, 'Mã đặt chỗ', bookingCode),
          if (trip.totalPrice != null) ...[
            const SizedBox(height: 14),
            _row(
              Icons.payments_outlined,
              'Tổng thanh toán',
              formatVND(trip.totalPrice!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF555555)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
