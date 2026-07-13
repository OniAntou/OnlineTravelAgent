import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class AvailabilityStateView extends StatelessWidget {
  const AvailabilityStateView({
    super.key,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onRetry,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 56, color: colors.primary),
              const SizedBox(height: AppTheme.spacingLarge),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: AppTheme.spacingXLarge),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(actionLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
