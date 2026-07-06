import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class BookingStatusTimeline extends StatelessWidget {
  final String status;
  const BookingStatusTimeline({super.key, required this.status});

  int get _activeStep {
    final s = status.toLowerCase();
    if (s == 'đã đi' || s == 'hoàn thành' || s == 'completed') return 4;
    if (s == 'đang diễn ra' || s == 'ongoing') return 3;
    if (s == 'đã xác nhận' || s == 'confirmed' || s == 'sắp tới') return 2;
    return 1; // Đã đặt
  }

  @override
  Widget build(BuildContext context) {
    const labels = ['Đã đặt', 'Xác nhận', 'Diễn ra', 'Hoàn thành'];
    final active = _activeStep;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: List.generate(labels.length * 2 - 1, (index) {
          // Even indices are nodes, odd indices are connectors
          if (index.isEven) {
            final step = index ~/ 2;
            final isActive = (step + 1) <= active;
            return Expanded(
              flex: 2,
              child: Column(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? AppTheme.primaryBlue
                          : Colors.grey.shade300,
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryBlue.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: isActive
                        ? const Icon(Icons.check, size: 9, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    labels[step],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isActive ? AppTheme.primaryBlue : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else {
            final step = index ~/ 2;
            final isActive = (step + 1) < active;
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 22),
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.primaryBlue : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            );
          }
        }),
      ),
    );
  }
}
