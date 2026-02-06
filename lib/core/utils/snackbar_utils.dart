import 'package:flutter/material.dart';

class SnackbarUtils {
  static const Duration defaultDuration = Duration(seconds: 3);
  static const Duration longDuration = Duration(seconds: 5);
  static const Duration shortDuration = Duration(seconds: 2);

  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = defaultDuration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _showSnackbar(
      context,
      message: message,
      backgroundColor: Colors.green.shade600,
      icon: Icons.check_circle,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    Duration duration = longDuration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _showSnackbar(
      context,
      message: message,
      backgroundColor: Colors.red.shade600,
      icon: Icons.error,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = defaultDuration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _showSnackbar(
      context,
      message: message,
      backgroundColor: Colors.orange.shade700,
      icon: Icons.warning,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = defaultDuration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _showSnackbar(
      context,
      message: message,
      backgroundColor: Colors.blue.shade600,
      icon: Icons.info,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void showCustom(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration duration = defaultDuration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _showSnackbar(
      context,
      message: message,
      backgroundColor: backgroundColor,
      icon: icon,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void _showSnackbar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
    required Duration duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.all(16),
      action: actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: onAction ?? () {},
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  static void hideAll(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }

  static void showWithUndo(
    BuildContext context,
    String message, {
    required VoidCallback onUndo,
    Duration duration = longDuration,
  }) {
    _showSnackbar(
      context,
      message: message,
      backgroundColor: Colors.grey.shade800,
      icon: Icons.delete_outline,
      duration: duration,
      actionLabel: 'UNDO',
      onAction: onUndo,
    );
  }

  static void showLoading(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade800,
      duration: const Duration(days: 1),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.all(16),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showNetworkError(BuildContext context, {VoidCallback? onRetry}) {
    showError(
      context,
      'Network error. Please check your connection.',
      actionLabel: onRetry != null ? 'RETRY' : null,
      onAction: onRetry,
      duration: longDuration,
    );
  }

  static void showSaved(BuildContext context, [String? itemName]) {
    showSuccess(
      context,
      itemName != null ? '$itemName saved successfully' : 'Saved successfully',
    );
  }

  static void showDeleted(
    BuildContext context, {
    String? itemName,
    VoidCallback? onUndo,
  }) {
    if (onUndo != null) {
      showWithUndo(
        context,
        itemName != null ? '$itemName deleted' : 'Item deleted',
        onUndo: onUndo,
      );
    } else {
      showSuccess(
        context,
        itemName != null ? '$itemName deleted successfully' : 'Deleted successfully',
      );
    }
  }
}
