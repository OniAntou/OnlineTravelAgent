import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../utils/app_utils.dart';

class GuideOption extends StatelessWidget {
  final bool includeGuide;
  final double guideFee;
  final ValueChanged<bool> onGuideToggled;

  const GuideOption({
    super.key,
    required this.includeGuide,
    required this.guideFee,
    required this.onGuideToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hướng dẫn viên',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Bao gồm hướng dẫn viên (phí cố định)',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              Switch(
                value: includeGuide,
                onChanged: onGuideToggled,
                activeThumbColor: AppTheme.primaryBlue,
              ),
              const SizedBox(width: 8),
              Text(
                formatVND(guideFee),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
