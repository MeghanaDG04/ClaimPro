import '../models/claim_model.dart';
import '../core/constants/status_constants.dart';
import '../core/utils/calculation_utils.dart';

class CalculationService {
  double calculateClaimBalance(ClaimModel claim) {
    return CalculationUtils.calculateBalanceAfterSettlement(
      totalBills: claim.totalBillAmount,
      settlementAmount: claim.totalSettledAmount,
      advancesPaid: claim.totalAdvanceAmount,
    );
  }

  ClaimSummary calculateSettlementDetails(ClaimModel claim) {
    final billAmounts = claim.bills.map((b) => b.amount).toList();
    final advanceAmounts = claim.advances
        .where((a) =>
            a.status == AdvanceStatus.disbursed ||
            a.status == AdvanceStatus.adjusted)
        .map((a) => a.amount)
        .toList();

    final approvedAmount = claim.approvedAmount ?? claim.estimatedAmount;
    final deductions = claim.settlements.fold(
      0.0,
      (sum, s) => sum + s.deductions,
    );

    return CalculationUtils.calculateClaimSummary(
      billAmounts: billAmounts,
      advanceAmounts: advanceAmounts,
      approvedAmount: approvedAmount,
      deductions: deductions,
      copayPercentage: 0,
    );
  }

  String formatAmount(double amount) {
    return CalculationUtils.formatCurrency(amount);
  }

  String formatAmountCompact(double amount) {
    return CalculationUtils.formatCurrencyCompact(amount);
  }

  double calculatePendingAmount(ClaimModel claim) {
    return CalculationUtils.calculatePendingAmount(
      totalBills: claim.totalBillAmount,
      totalAdvances: claim.totalAdvanceAmount,
    );
  }

  double calculatePatientPayable(ClaimModel claim) {
    return CalculationUtils.calculatePatientPayable(
      totalBills: claim.totalBillAmount,
      insuranceCoverage: claim.totalSettledAmount,
      advancesPaid: claim.totalAdvanceAmount,
    );
  }

  double calculateRefundAmount(ClaimModel claim) {
    return CalculationUtils.calculateRefundAmount(
      totalBills: claim.totalBillAmount,
      insuranceCoverage: claim.totalSettledAmount,
      advancesPaid: claim.totalAdvanceAmount,
    );
  }
}
