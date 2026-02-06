import 'package:flutter/material.dart';
import '../../models/claim_model.dart';
import '../../core/theme/color_scheme.dart';
import '../../core/utils/calculation_utils.dart';

class SettlementSummary extends StatelessWidget {
  final ClaimModel claim;

  const SettlementSummary({
    super.key,
    required this.claim,
  });

  @override
  Widget build(BuildContext context) {
    final approvedAmount = claim.approvedAmount ?? claim.estimatedAmount;
    final pendingAmount = claim.pendingAmount;

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
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Financial Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            _buildSummaryRow(
              'Total Bill Amount',
              CalculationUtils.formatCurrency(claim.totalBillAmount),
              valueColor: AppColors.textPrimary,
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Total Advances Paid',
              CalculationUtils.formatCurrency(claim.totalAdvanceAmount),
              valueColor: AppColors.info,
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Approved Amount',
              CalculationUtils.formatCurrency(approvedAmount),
              valueColor: AppColors.success,
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Already Settled Amount',
              CalculationUtils.formatCurrency(claim.totalSettledAmount),
              valueColor: AppColors.secondary,
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            _buildPendingAmountRow(pendingAmount),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPendingAmountRow(double pendingAmount) {
    final isPositive = pendingAmount > 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPositive
            ? AppColors.warning.withOpacity(0.1)
            : AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isPositive ? Icons.pending_actions : Icons.check_circle,
                size: 20,
                color: isPositive ? AppColors.warning : AppColors.success,
              ),
              const SizedBox(width: 8),
              Text(
                isPositive ? 'Pending Amount' : 'Fully Settled',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? AppColors.warningDark : AppColors.successDark,
                ),
              ),
            ],
          ),
          Text(
            CalculationUtils.formatCurrency(pendingAmount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isPositive ? AppColors.warningDark : AppColors.successDark,
            ),
          ),
        ],
      ),
    );
  }
}
