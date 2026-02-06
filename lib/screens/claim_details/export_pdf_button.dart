import 'package:flutter/material.dart';
import '../../models/claim_model.dart';
import '../../core/utils/pdf_utils.dart';
import '../../core/theme/color_scheme.dart';

enum ExportButtonStyle { icon, text, full }

class ExportPdfButton extends StatefulWidget {
  final ClaimModel claim;
  final ExportButtonStyle buttonStyle;
  final VoidCallback? onExportComplete;
  final VoidCallback? onError;

  const ExportPdfButton({
    super.key,
    required this.claim,
    this.buttonStyle = ExportButtonStyle.full,
    this.onExportComplete,
    this.onError,
  });

  @override
  State<ExportPdfButton> createState() => _ExportPdfButtonState();
}

class _ExportPdfButtonState extends State<ExportPdfButton> {
  bool _isLoading = false;

  Future<void> _exportPdf() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final pdfBytes = await PdfUtils.generateClaimSummaryPdf(widget.claim);
      final fileName = 'claim_${widget.claim.claimNumber}.pdf';
      await PdfUtils.sharePdf(pdfBytes, fileName);
      widget.onExportComplete?.call();
    } catch (e) {
      widget.onError?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export PDF: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _printPdf() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final pdfBytes = await PdfUtils.generateClaimSummaryPdf(widget.claim);
      await PdfUtils.printPdf(pdfBytes);
      widget.onExportComplete?.call();
    } catch (e) {
      widget.onError?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to print PDF: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.share, color: AppColors.primary),
                title: const Text('Share PDF'),
                subtitle: const Text('Share claim summary as PDF'),
                onTap: () {
                  Navigator.pop(context);
                  _exportPdf();
                },
              ),
              ListTile(
                leading: const Icon(Icons.print, color: AppColors.primary),
                title: const Text('Print PDF'),
                subtitle: const Text('Print claim summary'),
                onTap: () {
                  Navigator.pop(context);
                  _printPdf();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.buttonStyle) {
      case ExportButtonStyle.icon:
        return _buildIconButton();
      case ExportButtonStyle.text:
        return _buildTextButton();
      case ExportButtonStyle.full:
        return _buildFullButton();
    }
  }

  Widget _buildIconButton() {
    return IconButton(
      onPressed: _isLoading ? null : _showExportOptions,
      icon: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.picture_as_pdf),
      tooltip: 'Export PDF',
      color: AppColors.primary,
    );
  }

  Widget _buildTextButton() {
    return TextButton.icon(
      onPressed: _isLoading ? null : _showExportOptions,
      icon: _isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.picture_as_pdf, size: 18),
      label: Text(_isLoading ? 'Exporting...' : 'Export PDF'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildFullButton() {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _showExportOptions,
      icon: _isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.picture_as_pdf),
      label: Text(_isLoading ? 'Generating...' : 'Export PDF'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
