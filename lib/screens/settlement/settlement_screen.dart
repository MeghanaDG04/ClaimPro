import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/claim_model.dart';
import '../../models/settlement_model.dart';
import '../../models/advance_model.dart';
import '../../providers/claim_provider.dart';
import '../../core/theme/color_scheme.dart';
import '../../core/utils/calculation_utils.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/snackbar_utils.dart';
import 'settlement_summary.dart';
import 'settlement_form.dart';

class SettlementScreen extends StatefulWidget {
  final String claimId;

  const SettlementScreen({
    super.key,
    required this.claimId,
  });

  @override
  State<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends State<SettlementScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ClaimProvider>(
      builder: (context, claimProvider, child) {
        final claim = claimProvider.getClaimById(widget.claimId);

        if (claim == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Settlement')),
            body: const Center(
              child: Text('Claim not found'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Settlement'),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildClaimHeader(claim),
                const SizedBox(height: 16),
                SettlementSummary(claim: claim),
                const SizedBox(height: 24),
                if (claim.settlements.isNotEmpty) ...[
                  _buildExistingSettlements(claim),
                  const SizedBox(height: 24),
                ],
                _buildFormSection(claim),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildClaimHeader(ClaimModel claim) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.receipt_long,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    claim.claimNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    claim.patientName,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingSettlements(ClaimModel claim) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Previous Settlements',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: claim.settlements.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final settlement = claim.settlements[index];
            return _buildSettlementCard(settlement);
          },
        ),
      ],
    );
  }

  Widget _buildSettlementCard(SettlementModel settlement) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  settlement.settlementNumber,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: settlement.settlementType == SettlementType.final_
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    settlement.settlementType.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: settlement.settlementType == SettlementType.final_
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSettlementDetail(
                    'Date',
                    AppDateUtils.formatToDisplay(settlement.settlementDate),
                  ),
                ),
                Expanded(
                  child: _buildSettlementDetail(
                    'Net Amount',
                    CalculationUtils.formatCurrency(settlement.netAmount),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildSettlementDetail(
                    'Payment Mode',
                    settlement.paymentMode.displayName,
                  ),
                ),
                Expanded(
                  child: _buildSettlementDetail(
                    'Reference',
                    settlement.referenceNumber,
                  ),
                ),
              ],
            ),
            if (settlement.deductions > 0) ...[
              const SizedBox(height: 8),
              _buildSettlementDetail(
                'Deductions',
                CalculationUtils.formatCurrency(settlement.deductions),
              ),
              if (settlement.deductionRemarks != null &&
                  settlement.deductionRemarks!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Reason: ${settlement.deductionRemarks}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettlementDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection(ClaimModel claim) {
    final hasPendingAmount = claim.pendingAmount > 0;

    if (!hasPendingAmount) {
      return Card(
        elevation: 0,
        color: AppColors.successLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'This claim has been fully settled.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.successDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create New Settlement',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SettlementForm(
          claim: claim,
          isLoading: _isLoading,
          onSubmit: _handleSubmit,
        ),
      ],
    );
  }

  Future<void> _handleSubmit(SettlementModel settlement) async {
    setState(() => _isLoading = true);

    try {
      final claimProvider = context.read<ClaimProvider>();
      await claimProvider.addSettlementToClaim(widget.claimId, settlement);

      if (mounted) {
        SnackbarUtils.showSuccess(context, 'Settlement added successfully');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Failed to add settlement');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
