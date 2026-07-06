import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class SortOption {
  final String code;
  final String label;
  final IconData icon;

  const SortOption(this.code, this.label, this.icon);
}

class SortBottomSheet extends StatelessWidget {
  final String currentSort;
  final ValueChanged<String> onSortChanged;
  final List<SortOption> options;

  const SortBottomSheet({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
    required this.options,
  });

  static void show(
    BuildContext context, {
    required String currentSort,
    required ValueChanged<String> onSortChanged,
    required List<SortOption> options,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sắp xếp theo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              ...options.map(
                (option) => _SortOptionTile(
                  option: option,
                  isSelected: currentSort == option.code,
                  onTap: () {
                    onSortChanged(option.code);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _SortOptionTile extends StatelessWidget {
  final SortOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue.withValues(alpha: 0.05)
              : AppTheme.backgroundGray,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              option.icon,
              color: isSelected ? AppTheme.primaryBlue : Colors.grey[700],
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option.label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppTheme.primaryBlue : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryBlue,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
