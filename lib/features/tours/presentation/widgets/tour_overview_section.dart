import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class TourOverviewItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const TourOverviewItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primaryBlue, size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppTheme.textBlack,
          ),
        ),
      ],
    );
  }
}

class TourOverviewDivider extends StatelessWidget {
  const TourOverviewDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 1,
      height: 40,
      child: ColoredBox(color: Color(0x339E9E9E)),
    );
  }
}
