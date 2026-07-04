import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class AppPlaceholderCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onActionTap;
  final IconData? actionIcon;
  final bool isOutlinedButton;

  const AppPlaceholderCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onActionTap,
    this.actionIcon,
    this.isOutlinedButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textBlack,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onActionTap != null) ...[
              const SizedBox(height: 32),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: isOutlinedButton
                    ? OutlinedButton.icon(
                        onPressed: onActionTap,
                        icon: actionIcon != null ? Icon(actionIcon, size: 20) : const SizedBox.shrink(),
                        label: Text(
                          actionText!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryBlue,
                          side: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: onActionTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              actionText!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (actionIcon != null) ...[
                              const SizedBox(width: 8),
                              Icon(actionIcon, color: Colors.white, size: 18),
                            ],
                          ],
                        ),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class RequireLoginPlaceholder extends StatelessWidget {
  final String title;
  final String subtitle;

  const RequireLoginPlaceholder({
    super.key,
    this.title = 'Đăng nhập để tiếp tục',
    this.subtitle = 'Vui lòng đăng nhập để sử dụng tính năng này.',
  });

  @override
  Widget build(BuildContext context) {
    return AppPlaceholderCard(
      icon: Icons.lock_person_rounded,
      title: title,
      subtitle: subtitle,
      actionText: 'Đăng nhập ngay',
      actionIcon: Icons.login_rounded,
      onActionTap: () => Navigator.pushNamed(context, '/login'),
    );
  }
}
