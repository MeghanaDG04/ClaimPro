import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../core/theme/color_scheme.dart';
import 'custom_button.dart';

class AppErrorWidget extends StatelessWidget {
  final String? title;
  final String message;
  final String? retryLabel;
  final VoidCallback? onRetry;
  final IconData icon;
  final bool showIcon;
  final bool animate;
  final bool compact;

  const AppErrorWidget({
    super.key,
    this.title,
    required this.message,
    this.retryLabel = 'Retry',
    this.onRetry,
    this.icon = Icons.error_outline,
    this.showIcon = true,
    this.animate = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = compact ? _buildCompactContent() : _buildFullContent();

    if (animate) {
      return FadeIn(
        duration: const Duration(milliseconds: 300),
        child: ShakeX(
          duration: const Duration(milliseconds: 500),
          child: content,
        ),
      );
    }

    return content;
  }

  Widget _buildFullContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showIcon)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: AppColors.error,
                ),
              ),
            if (showIcon) const SizedBox(height: 24),
            if (title != null) ...[
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              CustomButton(
                text: retryLabel!,
                onPressed: onRetry,
                leadingIcon: Icons.refresh,
                variant: ButtonVariant.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          if (showIcon) ...[
            Icon(
              icon,
              size: 24,
              color: AppColors.error,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.errorDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.errorDark.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: onRetry,
              color: AppColors.error,
              iconSize: 22,
            ),
          ],
        ],
      ),
    );
  }
}
