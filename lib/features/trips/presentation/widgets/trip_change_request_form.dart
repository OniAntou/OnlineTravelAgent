import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/api_exception.dart';
import '../../../../data/services/api_provider.dart';
import '../../application/trip_change_request_provider.dart';
import '../../domain/trip.dart';
import '../../domain/trip_change_request.dart';

Future<void> showTripChangeRequestForm(
  BuildContext hostContext,
  WidgetRef ref, {
  required Trip trip,
  required TripChangeRequestType type,
}) async {
  final reasonController = TextEditingController();
  DateTime? selectedDate;
  var isSubmitting = false;
  String? errorMessage;

  try {
    await showModalBottomSheet<void>(
      context: hostContext,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            final isReschedule = type == TripChangeRequestType.reschedule;
            final dateLabel = selectedDate == null
                ? 'Chọn ngày mong muốn'
                : DateFormat('dd/MM/yyyy').format(selectedDate!);

            Future<void> selectDate() async {
              final now = DateTime.now();
              final firstDate = DateTime(
                now.year,
                now.month,
                now.day,
              ).add(const Duration(days: 1));
              final picked = await showDatePicker(
                context: modalContext,
                initialDate: selectedDate ?? firstDate,
                firstDate: firstDate,
                lastDate: DateTime(now.year + 5),
              );
              if (picked != null) {
                setModalState(() {
                  selectedDate = picked;
                  errorMessage = null;
                });
              }
            }

            Future<void> submit() async {
              final reason = reasonController.text.trim();
              if (reason.length < 5) {
                setModalState(
                  () =>
                      errorMessage = 'Vui lòng nhập lý do từ 5 ký tự trở lên.',
                );
                return;
              }
              if (isReschedule && selectedDate == null) {
                setModalState(
                  () => errorMessage = 'Vui lòng chọn ngày mong muốn.',
                );
                return;
              }

              setModalState(() {
                isSubmitting = true;
                errorMessage = null;
              });
              try {
                await ref
                    .read(apiProvider)
                    .createTripChangeRequest(
                      tripId: trip.id,
                      type: type,
                      reason: reason,
                      requestedDate: selectedDate == null
                          ? null
                          : DateFormat('dd/MM/yyyy').format(selectedDate!),
                    );
                ref.invalidate(tripChangeRequestsProvider(trip.id));
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                if (hostContext.mounted) {
                  ScaffoldMessenger.of(hostContext).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Đã gửi yêu cầu. Vui lòng chờ quản trị viên xử lý.',
                      ),
                      backgroundColor: Color(0xFF15803D),
                    ),
                  );
                }
              } catch (error) {
                if (modalContext.mounted) {
                  setModalState(() {
                    isSubmitting = false;
                    errorMessage = getErrorMessage(error);
                  });
                }
              }
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  MediaQuery.viewInsetsOf(modalContext).bottom + 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.displayLabel,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isReschedule
                            ? 'Gửi ngày đi mới để quản trị viên xem xét.'
                            : 'Gửi lý do để quản trị viên xem xét số tiền hoàn.',
                        style: const TextStyle(color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 20),
                      if (isReschedule) ...[
                        OutlinedButton.icon(
                          onPressed: isSubmitting ? null : selectDate,
                          icon: const Icon(Icons.calendar_month_outlined),
                          label: Text(dateLabel),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            alignment: Alignment.centerLeft,
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      TextField(
                        controller: reasonController,
                        enabled: !isSubmitting,
                        minLines: 3,
                        maxLines: 5,
                        maxLength: 500,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Lý do',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      if (errorMessage != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFFDC2626),
                            fontSize: 13,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            minimumSize: const Size.fromHeight(48),
                          ),
                          onPressed: isSubmitting ? null : submit,
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Gửi yêu cầu'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  } finally {
    reasonController.dispose();
  }
}
