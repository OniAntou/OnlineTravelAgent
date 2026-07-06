import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class GuestCounter extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const GuestCounter({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 100,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.remove_circle_outline,
            color: value > min ? AppTheme.primaryBlue : Colors.grey,
          ),
          onPressed: value > min ? () => onChanged(value - 1) : null,
        ),
        Text(
          '$value',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(
            Icons.add_circle_outline,
            color: AppTheme.primaryBlue,
          ),
          onPressed: value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}
