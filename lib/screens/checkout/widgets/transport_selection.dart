import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../utils/app_utils.dart';

class TransportSelection extends StatelessWidget {
  final String selectedTransport;
  final ValueChanged<String> onTransportSelected;

  const TransportSelection({
    super.key,
    required this.selectedTransport,
    required this.onTransportSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phương tiện di chuyển',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildTransportOption('Tự túc', Icons.directions_walk, 0),
        const SizedBox(height: 8),
        _buildTransportOption('Xe giường nằm', Icons.directions_bus, 20),
        const SizedBox(height: 8),
        _buildTransportOption('Tàu hoả', Icons.train, 35),
        const SizedBox(height: 8),
        _buildTransportOption('Máy bay', Icons.flight, 100),
      ],
    );
  }

  Widget _buildTransportOption(String title, IconData icon, int price) {
    final isSelected = selectedTransport == title;
    return InkWell(
      onTap: () => onTransportSelected(title),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue.withValues(alpha: 0.05)
              : Colors.white,
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppTheme.primaryBlue : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (price > 0)
              Text(
                '+${formatVND(price * 1000.0)}/người',
                style: const TextStyle(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
