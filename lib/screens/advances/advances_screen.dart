import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/claim_provider.dart';
import '../../models/advance_model.dart';
import '../../models/claim_model.dart';
import '../../core/constants/status_constants.dart';
import '../../core/theme/color_scheme.dart';
import '../../core/utils/calculation_utils.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/confirmation_dialog.dart';
import 'advance_list_widget.dart';
import 'add_advance_dialog.dart';

class AdvancesScreen extends StatefulWidget {
  final String claimId;

  const AdvancesScreen({
    super.key,
    required this.claimId,
  });

  @override
  State<AdvancesScreen> createState() => _AdvancesScreenState();
}

class _AdvancesScreenState extends State<AdvancesScreen> {
  bool _isLoading = false;

  ClaimModel? get _claim {
    return context.read<ClaimProvider>().getClaimById(widget.claimId);
  }

  bool get _canModifyAdvances {
    final claim = _claim;
    if (claim == null) return false;
    return claim.status == ClaimStatus.draft ||
        claim.status == ClaimStatus.submitted ||
        claim.status == ClaimStatus.underReview ||
        claim.status == ClaimStatus.approved;
  }

  Future<void> _addAdvance() async {
    final result = await AddAdvanceDialog.show(
      context: context,
      claimId: widget.claimId,
    );

    if (result != null && mounted) {
      setState(() => _isLoading = true);
      try {
        await context.read<ClaimProvider>().addAdvanceToClaim(
              widget.claimId,
              result,
            );
        if (mounted) {
          SnackbarUtils.showSuccess(context, 'Advance added successfully');
        }
      } catch (e) {
        if (mounted) {
          SnackbarUtils.showError(context, 'Failed to add advance');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _editAdvance(AdvanceModel advance) async {
    final result = await AddAdvanceDialog.show(
      context: context,
      claimId: widget.claimId,
      advance: advance,
    );

    if (result != null && mounted) {
      setState(() => _isLoading = true);
      try {
        await context.read<ClaimProvider>().updateAdvanceInClaim(
              widget.claimId,
              result,
            );
        if (mounted) {
          SnackbarUtils.showSuccess(context, 'Advance updated successfully');
        }
      } catch (e) {
        if (mounted) {
          SnackbarUtils.showError(context, 'Failed to update advance');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _deleteAdvance(String advanceId) async {
    final advance = _claim?.advances.firstWhere((a) => a.id == advanceId);
    if (advance == null) return;

    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Advance',
      message:
          'Are you sure you want to delete advance ${advance.advanceNumber}? This action cannot be undone.',
      confirmText: 'Delete',
      type: DialogType.error,
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      try {
        await context.read<ClaimProvider>().removeAdvanceFromClaim(
              widget.claimId,
              advanceId,
            );
        if (mounted) {
          SnackbarUtils.showSuccess(context, 'Advance deleted successfully');
        }
      } catch (e) {
        if (mounted) {
          SnackbarUtils.showError(context, 'Failed to delete advance');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClaimProvider>(
      builder: (context, provider, child) {
        final claim = provider.getClaimById(widget.claimId);
        final advances = claim?.advances ?? [];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Advances'),
            elevation: 0,
          ),
          body: _isLoading || provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildSummaryCard(advances),
                    Expanded(
                      child: advances.isEmpty
                          ? _buildEmptyState()
                          : AdvanceListWidget(
                              advances: advances,
                              onEdit: _editAdvance,
                              onDelete: _deleteAdvance,
                              canModify: _canModifyAdvances,
                            ),
                    ),
                  ],
                ),
          floatingActionButton: _canModifyAdvances
              ? FloatingActionButton.extended(
                  onPressed: _addAdvance,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Advance'),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                )
              : null,
        );
      },
    );
  }

  Widget _buildSummaryCard(List<AdvanceModel> advances) {
    final totalAmount =
        advances.fold(0.0, (sum, advance) => sum + advance.amount);
    final disbursedAmount = advances
        .where((a) =>
            a.status == AdvanceStatus.disbursed ||
            a.status == AdvanceStatus.adjusted)
        .fold(0.0, (sum, advance) => sum + advance.amount);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary,
            AppColors.secondary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Advances Summary',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${advances.length} ${advances.length == 1 ? 'Advance' : 'Advances'}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CalculationUtils.formatCurrency(totalAmount),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Disbursed Amount',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CalculationUtils.formatCurrency(disbursedAmount),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 64,
                color: AppColors.secondary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Advances Added',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add advances to track payments for this claim',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
            if (_canModifyAdvances) ...[
              const SizedBox(height: 24),
              CustomButton(
                text: 'Add First Advance',
                leadingIcon: Icons.add,
                onPressed: _addAdvance,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
