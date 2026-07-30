import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../application/trip_change_request_provider.dart';
import '../../domain/trip.dart';
import '../../domain/trip_change_request.dart';

bool canRequestTripChange(Trip trip, Iterable<TripChangeRequest> requests) {
  if (!trip.isUpcoming ||
      trip.status == TripStatus.completed ||
      trip.status == TripStatus.cancelled) {
    return false;
  }
  return !requests.any((request) => request.isPending);
}

class TripChangeRequestPanel extends ConsumerWidget {
  final Trip trip;

  const TripChangeRequestPanel({super.key, required this.trip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(tripChangeRequestsProvider(trip.id));

    return requests.when(
      loading: () => const _ChangeRequestStateCard(
        child: SizedBox(
          height: 44,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ),
      error: (error, stackTrace) => _ChangeRequestStateCard(
        child: Row(
          children: [
            const Expanded(
              child: Text('Không thể tải yêu cầu thay đổi. Vui lòng thử lại.'),
            ),
            TextButton(
              onPressed: () =>
                  ref.invalidate(tripChangeRequestsProvider(trip.id)),
              child: const Text('Tải lại'),
            ),
          ],
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const _ChangeRequestStateCard(
            child: Text('Chưa có yêu cầu thay đổi nào.'),
          );
        }
        return TripChangeRequestSummaryCard(request: items.first);
      },
    );
  }
}

class TripChangeRequestSummaryCard extends StatelessWidget {
  final TripChangeRequest request;

  const TripChangeRequestSummaryCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(request.status);
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_typeIcon(request.type), color: color, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          request.type.displayLabel,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _StatusPill(
                        label: request.status.displayLabel,
                        color: color,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _DetailLine(label: 'Lý do', value: request.reason),
                  if (request.requestedDate != null) ...[
                    const SizedBox(height: 6),
                    _DetailLine(
                      label: 'Ngày mong muốn',
                      value: request.requestedDate!,
                    ),
                  ],
                  if (request.refundAmount != null) ...[
                    const SizedBox(height: 6),
                    _DetailLine(
                      label: 'Số tiền hoàn',
                      value: formatter.format(request.refundAmount),
                    ),
                  ],
                  if (request.adminNote != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        request.adminNote!,
                        style: const TextStyle(fontSize: 13, height: 1.35),
                      ),
                    ),
                  ],
                  if (request.isPending) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Yêu cầu đang chờ quản trị viên xử lý.',
                      style: TextStyle(color: color, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _ChangeRequestStateCard extends StatelessWidget {
  final Widget child;

  const _ChangeRequestStateCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: child,
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _DetailLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            color: Color(0xFF4B5563),
            fontSize: 13,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

Color _statusColor(TripChangeRequestStatus status) {
  switch (status) {
    case TripChangeRequestStatus.pending:
      return const Color(0xFFD97706);
    case TripChangeRequestStatus.approved:
      return const Color(0xFF15803D);
    case TripChangeRequestStatus.rejected:
      return const Color(0xFFDC2626);
    case TripChangeRequestStatus.unknown:
      return const Color(0xFF64748B);
  }
}

IconData _typeIcon(TripChangeRequestType type) {
  switch (type) {
    case TripChangeRequestType.reschedule:
      return Icons.edit_calendar_outlined;
    case TripChangeRequestType.refund:
      return Icons.currency_exchange_outlined;
    case TripChangeRequestType.unknown:
      return Icons.change_circle_outlined;
  }
}
