import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/trip_change_request_provider.dart';
import '../../domain/trip.dart';
import '../../domain/trip_change_request.dart';
import 'trip_change_request_form.dart';
import 'trip_change_request_panel.dart';

class TripActionButtons extends ConsumerWidget {
  final Trip trip;

  const TripActionButtons({super.key, required this.trip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestState = ref.watch(tripChangeRequestsProvider(trip.id));
    final List<TripChangeRequest>? loadedRequests = requestState.when(
      data: (items) => items,
      loading: () => null,
      error: (error, stackTrace) => null,
    );
    final requests = loadedRequests ?? const <TripChangeRequest>[];
    final canSubmitChange =
        loadedRequests != null && canRequestTripChange(trip, requests);
    final hasPendingRequest = requests.any((request) => request.isPending);
    final disabledMessage = requestState.when(
      data: (_) => hasPendingRequest
          ? 'Yêu cầu hiện tại đang chờ xử lý'
          : 'Chuyến đi này chưa thể gửi yêu cầu thay đổi',
      loading: () => 'Đang tải trạng thái yêu cầu',
      error: (error, stackTrace) => 'Không thể tải trạng thái yêu cầu',
    );

    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      spacing: 16,
      runSpacing: 16,
      children: [
        _btn(
          icon: Icons.support_agent,
          label: 'Hỗ trợ',
          color: AppTheme.primaryBlue,
          onTap: () => _showNotImplemented(context, 'Hỗ trợ'),
        ),
        _btn(
          icon: Icons.receipt_long,
          label: 'Hóa đơn',
          color: AppTheme.primaryBlue,
          onTap: () => _showNotImplemented(context, 'Hóa đơn'),
        ),
        _btn(
          icon: Icons.share_outlined,
          label: 'Chia sẻ',
          color: AppTheme.primaryBlue,
          onTap: () => _showNotImplemented(context, 'Chia sẻ'),
        ),
        if (trip.isUpcoming &&
            trip.status != TripStatus.completed &&
            trip.status != TripStatus.cancelled) ...[
          _btn(
            icon: Icons.edit_calendar_outlined,
            label: 'Đổi lịch',
            color: AppTheme.primaryBlue,
            tooltip: canSubmitChange ? null : disabledMessage,
            onTap: canSubmitChange
                ? () => showTripChangeRequestForm(
                    context,
                    ref,
                    trip: trip,
                    type: TripChangeRequestType.reschedule,
                  )
                : null,
          ),
          _btn(
            icon: Icons.currency_exchange_outlined,
            label: 'Yêu cầu hoàn tiền',
            color: const Color(0xFFD97706),
            tooltip: canSubmitChange ? null : disabledMessage,
            onTap: canSubmitChange
                ? () => showTripChangeRequestForm(
                    context,
                    ref,
                    trip: trip,
                    type: TripChangeRequestType.refund,
                  )
                : null,
          ),
        ],
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

  Widget _btn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
    String? tooltip,
  }) {
    final enabled = onTap != null;
    final foreground = enabled ? color : const Color(0xFF9CA3AF);
    final action = Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 92,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: enabled
                      ? const Color(0xFFF5F7FA)
                      : const Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: Icon(icon, color: foreground),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: enabled ? const Color(0xFF555555) : foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return tooltip == null ? action : Tooltip(message: tooltip, child: action);
  }
}
