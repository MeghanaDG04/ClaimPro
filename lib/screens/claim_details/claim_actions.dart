import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/claim_model.dart';
import '../../providers/claim_provider.dart';
import '../../core/constants/status_constants.dart';
import '../../core/utils/pdf_utils.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../widgets/confirmation_dialog.dart';

class ClaimActions {
  static Future<bool> submitClaim({
    required BuildContext context,
    required ClaimModel claim,
  }) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Submit Claim',
      message:
          'Are you sure you want to submit this claim? Once submitted, you will not be able to edit it.',
      confirmText: 'Submit',
      cancelText: 'Cancel',
      type: DialogType.info,
    );

    if (confirmed != true) return false;

    try {
      final provider = context.read<ClaimProvider>();
      await provider.submitClaim(claim.id);

      if (context.mounted) {
        SnackbarUtils.showSuccess(
          context,
          'Claim submitted successfully',
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        SnackbarUtils.showError(
          context,
          'Failed to submit claim: ${e.toString()}',
        );
      }
      return false;
    }
  }

  static Future<bool> deleteClaim({
    required BuildContext context,
    required ClaimModel claim,
  }) async {
    if (!claim.status.canDelete) {
      SnackbarUtils.showWarning(
        context,
        'Only draft claims can be deleted',
      );
      return false;
    }

    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Claim',
      message:
          'Are you sure you want to delete this claim? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      type: DialogType.error,
    );

    if (confirmed != true) return false;

    try {
      final provider = context.read<ClaimProvider>();
      await provider.deleteClaim(claim.id);

      if (context.mounted) {
        SnackbarUtils.showSuccess(
          context,
          'Claim deleted successfully',
        );
        Navigator.of(context).pop(true);
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        SnackbarUtils.showError(
          context,
          'Failed to delete claim: ${e.toString()}',
        );
      }
      return false;
    }
  }

  static void editClaim({
    required BuildContext context,
    required ClaimModel claim,
  }) {
    if (!claim.status.canEdit) {
      SnackbarUtils.showWarning(
        context,
        'This claim cannot be edited in its current status',
      );
      return;
    }

    Navigator.of(context).pushNamed(
      '/create-claim',
      arguments: {'claim': claim, 'isEditing': true},
    );
  }

  static Future<void> exportToPdf({
    required BuildContext context,
    required ClaimModel claim,
  }) async {
    try {
      _showLoadingDialog(context, 'Generating PDF...');

      final pdfBytes = await PdfUtils.generateClaimSummaryPdf(claim);
      final fileName = 'Claim_${claim.claimNumber}.pdf';

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      await PdfUtils.sharePdf(pdfBytes, fileName);

      if (context.mounted) {
        SnackbarUtils.showSuccess(
          context,
          'PDF generated successfully',
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        SnackbarUtils.showError(
          context,
          'Failed to generate PDF: ${e.toString()}',
        );
      }
    }
  }

  static Future<void> printPdf({
    required BuildContext context,
    required ClaimModel claim,
  }) async {
    try {
      _showLoadingDialog(context, 'Preparing print...');

      final pdfBytes = await PdfUtils.generateClaimSummaryPdf(claim);

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      await PdfUtils.printPdf(pdfBytes);
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        SnackbarUtils.showError(
          context,
          'Failed to print: ${e.toString()}',
        );
      }
    }
  }

  static Future<void> sharePdf({
    required BuildContext context,
    required ClaimModel claim,
  }) async {
    try {
      _showLoadingDialog(context, 'Preparing to share...');

      final pdfBytes = await PdfUtils.generateClaimSummaryPdf(claim);
      final fileName = 'Claim_${claim.claimNumber}.pdf';

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      await PdfUtils.sharePdf(pdfBytes, fileName);
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        SnackbarUtils.showError(
          context,
          'Failed to share: ${e.toString()}',
        );
      }
    }
  }

  static void navigateToAddSettlement({
    required BuildContext context,
    required ClaimModel claim,
  }) {
    if (!claim.status.canSettle) {
      SnackbarUtils.showWarning(
        context,
        'Cannot add settlement in current claim status',
      );
      return;
    }

    Navigator.of(context).pushNamed(
      '/add-settlement',
      arguments: {'claimId': claim.id},
    );
  }

  static void navigateToAddBill({
    required BuildContext context,
    required ClaimModel claim,
  }) {
    Navigator.of(context).pushNamed(
      '/add-bill',
      arguments: {'claimId': claim.id},
    );
  }

  static void navigateToAddAdvance({
    required BuildContext context,
    required ClaimModel claim,
  }) {
    Navigator.of(context).pushNamed(
      '/add-advance',
      arguments: {'claimId': claim.id},
    );
  }

  static void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(message),
            ],
          ),
        ),
      ),
    );
  }

  static List<PopupMenuEntry<String>> buildActionMenuItems(ClaimModel claim) {
    final items = <PopupMenuEntry<String>>[];

    if (claim.status.canEdit) {
      items.add(
        const PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 20),
              SizedBox(width: 12),
              Text('Edit Claim'),
            ],
          ),
        ),
      );
    }

    items.add(
      const PopupMenuItem<String>(
        value: 'export',
        child: Row(
          children: [
            Icon(Icons.picture_as_pdf_outlined, size: 20),
            SizedBox(width: 12),
            Text('Export PDF'),
          ],
        ),
      ),
    );

    items.add(
      const PopupMenuItem<String>(
        value: 'print',
        child: Row(
          children: [
            Icon(Icons.print_outlined, size: 20),
            SizedBox(width: 12),
            Text('Print'),
          ],
        ),
      ),
    );

    items.add(
      const PopupMenuItem<String>(
        value: 'share',
        child: Row(
          children: [
            Icon(Icons.share_outlined, size: 20),
            SizedBox(width: 12),
            Text('Share'),
          ],
        ),
      ),
    );

    if (claim.status.canDelete) {
      items.add(const PopupMenuDivider());
      items.add(
        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20, color: Colors.red),
              SizedBox(width: 12),
              Text('Delete Claim', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      );
    }

    return items;
  }

  static Future<void> handleMenuAction({
    required BuildContext context,
    required String action,
    required ClaimModel claim,
  }) async {
    switch (action) {
      case 'edit':
        editClaim(context: context, claim: claim);
        break;
      case 'export':
        await exportToPdf(context: context, claim: claim);
        break;
      case 'print':
        await printPdf(context: context, claim: claim);
        break;
      case 'share':
        await sharePdf(context: context, claim: claim);
        break;
      case 'delete':
        await deleteClaim(context: context, claim: claim);
        break;
    }
  }
}
