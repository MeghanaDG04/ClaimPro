import 'package:intl/intl.dart';

class CalculationUtils {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _compactFormat = NumberFormat.compact(locale: 'en_IN');

  static double calculateTotalBills(List<double> billAmounts) {
    if (billAmounts.isEmpty) return 0;
    return billAmounts.fold(0.0, (sum, amount) => sum + amount);
  }

  static double calculateTotalAdvances(List<double> advanceAmounts) {
    if (advanceAmounts.isEmpty) return 0;
    return advanceAmounts.fold(0.0, (sum, amount) => sum + amount);
  }

  static double calculatePendingAmount({
    required double totalBills,
    required double totalAdvances,
  }) {
    final pending = totalBills - totalAdvances;
    return pending < 0 ? 0 : pending;
  }

  static double calculatePendingFromLists({
    required List<double> billAmounts,
    required List<double> advanceAmounts,
  }) {
    return calculatePendingAmount(
      totalBills: calculateTotalBills(billAmounts),
      totalAdvances: calculateTotalAdvances(advanceAmounts),
    );
  }

  static double calculateSettlementAmount({
    required double approvedAmount,
    required double deductions,
    required double copay,
  }) {
    final settlement = approvedAmount - deductions - copay;
    return settlement < 0 ? 0 : settlement;
  }

  static double calculateBalanceAfterSettlement({
    required double totalBills,
    required double settlementAmount,
    required double advancesPaid,
  }) {
    return totalBills - settlementAmount - advancesPaid;
  }

  static double calculatePatientPayable({
    required double totalBills,
    required double insuranceCoverage,
    required double advancesPaid,
  }) {
    final payable = totalBills - insuranceCoverage - advancesPaid;
    return payable < 0 ? 0 : payable;
  }

  static double calculateRefundAmount({
    required double totalBills,
    required double insuranceCoverage,
    required double advancesPaid,
  }) {
    final balance = totalBills - insuranceCoverage - advancesPaid;
    return balance < 0 ? balance.abs() : 0;
  }

  static double calculatePercentage(double value, double total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }

  static double calculateValueFromPercentage(double percentage, double total) {
    return (percentage / 100) * total;
  }

  static double calculateCopayAmount(double billAmount, double copayPercentage) {
    return calculateValueFromPercentage(copayPercentage, billAmount);
  }

  static double calculateDeductible({
    required double billAmount,
    required double deductibleAmount,
  }) {
    return billAmount > deductibleAmount ? deductibleAmount : billAmount;
  }

  static String formatCurrency(double? amount) {
    if (amount == null) return '₹0.00';
    return _currencyFormat.format(amount);
  }

  static String formatCurrencyCompact(double? amount) {
    if (amount == null) return '₹0';
    return '₹${_compactFormat.format(amount)}';
  }

  static String formatIndianNumber(double amount) {
    if (amount < 1000) {
      return amount.toStringAsFixed(2);
    } else if (amount < 100000) {
      return '${(amount / 1000).toStringAsFixed(2)}K';
    } else if (amount < 10000000) {
      return '${(amount / 100000).toStringAsFixed(2)} Lakhs';
    } else {
      return '${(amount / 10000000).toStringAsFixed(2)} Crores';
    }
  }

  static String formatIndianCurrency(double amount) {
    return '₹${formatIndianNumber(amount)}';
  }

  static String formatWithIndianCommas(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];

    if (integerPart.length <= 3) {
      return '₹$integerPart.$decimalPart';
    }

    final lastThree = integerPart.substring(integerPart.length - 3);
    var remaining = integerPart.substring(0, integerPart.length - 3);
    
    final buffer = StringBuffer();
    while (remaining.length > 2) {
      buffer.write('${remaining.substring(remaining.length - 2)},');
      remaining = remaining.substring(0, remaining.length - 2);
    }
    
    if (remaining.isNotEmpty) {
      buffer.write(remaining);
    }

    final reversed = buffer.toString().split('').reversed.join();
    return '₹$reversed,$lastThree.$decimalPart';
  }

  static double roundToTwoDecimals(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  static double roundUp(double value, int decimals) {
    final factor = _pow10(decimals);
    return (value * factor).ceil() / factor;
  }

  static double roundDown(double value, int decimals) {
    final factor = _pow10(decimals);
    return (value * factor).floor() / factor;
  }

  static double _pow10(int exponent) {
    double result = 1;
    for (int i = 0; i < exponent; i++) {
      result *= 10;
    }
    return result;
  }

  static ClaimSummary calculateClaimSummary({
    required List<double> billAmounts,
    required List<double> advanceAmounts,
    required double approvedAmount,
    required double deductions,
    required double copayPercentage,
  }) {
    final totalBills = calculateTotalBills(billAmounts);
    final totalAdvances = calculateTotalAdvances(advanceAmounts);
    final copayAmount = calculateCopayAmount(approvedAmount, copayPercentage);
    final settlementAmount = calculateSettlementAmount(
      approvedAmount: approvedAmount,
      deductions: deductions,
      copay: copayAmount,
    );
    final patientPayable = calculatePatientPayable(
      totalBills: totalBills,
      insuranceCoverage: settlementAmount,
      advancesPaid: totalAdvances,
    );
    final refundAmount = calculateRefundAmount(
      totalBills: totalBills,
      insuranceCoverage: settlementAmount,
      advancesPaid: totalAdvances,
    );

    return ClaimSummary(
      totalBills: totalBills,
      totalAdvances: totalAdvances,
      approvedAmount: approvedAmount,
      deductions: deductions,
      copayAmount: copayAmount,
      settlementAmount: settlementAmount,
      patientPayable: patientPayable,
      refundAmount: refundAmount,
    );
  }
}

class ClaimSummary {
  final double totalBills;
  final double totalAdvances;
  final double approvedAmount;
  final double deductions;
  final double copayAmount;
  final double settlementAmount;
  final double patientPayable;
  final double refundAmount;

  const ClaimSummary({
    required this.totalBills,
    required this.totalAdvances,
    required this.approvedAmount,
    required this.deductions,
    required this.copayAmount,
    required this.settlementAmount,
    required this.patientPayable,
    required this.refundAmount,
  });

  bool get hasRefund => refundAmount > 0;
  bool get hasPayable => patientPayable > 0;

  String get formattedTotalBills => CalculationUtils.formatCurrency(totalBills);
  String get formattedTotalAdvances => CalculationUtils.formatCurrency(totalAdvances);
  String get formattedApprovedAmount => CalculationUtils.formatCurrency(approvedAmount);
  String get formattedDeductions => CalculationUtils.formatCurrency(deductions);
  String get formattedCopayAmount => CalculationUtils.formatCurrency(copayAmount);
  String get formattedSettlementAmount => CalculationUtils.formatCurrency(settlementAmount);
  String get formattedPatientPayable => CalculationUtils.formatCurrency(patientPayable);
  String get formattedRefundAmount => CalculationUtils.formatCurrency(refundAmount);
}
