import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';

class ClaimActions extends StatelessWidget {
  final VoidCallback? onSaveDraft;
  final VoidCallback? onSubmit;
  final VoidCallback? onCancel;
  final bool isLoading;

  const ClaimActions({
    super.key,
    this.onSaveDraft,
    this.onSubmit,
    this.onCancel,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Save Draft',
                    variant: ButtonVariant.outline,
                    onPressed: isLoading ? null : onSaveDraft,
                    leadingIcon: Icons.save_outlined,
                    fullWidth: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Submit Claim',
                    variant: ButtonVariant.primary,
                    onPressed: isLoading ? null : onSubmit,
                    isLoading: isLoading,
                    leadingIcon: Icons.send_outlined,
                    fullWidth: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Cancel',
              variant: ButtonVariant.text,
              onPressed: isLoading ? null : onCancel,
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
