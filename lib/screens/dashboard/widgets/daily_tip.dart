import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../core/theme/app_theme.dart';

class DailyTip extends StatelessWidget {
  const DailyTip({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.synchronized(
      child: FadeInAnimation(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEAF2FF), Color(0xFFF7FAFF)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD8E6FF)),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Mẹo hôm nay: Đặt chuyến trước 2-3 tuần để có giá tốt hơn và nhiều khung giờ đẹp.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF3B4A66)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
