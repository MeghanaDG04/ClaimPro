import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../core/theme/color_scheme.dart';

class FinancialItem {
  final String label;
  final double amount;
  final Color? color;
  final IconData? icon;
  final bool isTotal;
  final bool isNegative;

  const FinancialItem({
    required this.label,
    required this.amount,
    this.color,
    this.icon,
    this.isTotal = false,
    this.isNegative = false,
  });
}

class FinancialSummaryCard extends StatelessWidget {
  final String? title;
  final List<FinancialItem> items;
  final double? totalBills;
  final double? totalAdvances;
  final double? totalSettlements;
  final double? balance;
  final bool showBreakdown;
  final bool animate;
  final VoidCallback? onTap;
  final String currencySymbol;

  const FinancialSummaryCard({
    super.key,
    this.title,
    this.items = const [],
    this.totalBills,
    this.totalAdvances,
    this.totalSettlements,
    this.balance,
    this.showBreakdown = true,
    this.animate = true,
    this.onTap,
    this.currencySymbol = '₹',
  });

  factory FinancialSummaryCard.fromAmounts({
    String? title,
    required double totalBills,
    required double totalAdvances,
    required double totalSettlements,
    double? approvedAmount,
    bool animate = true,
    VoidCallback? onTap,
    String currencySymbol = '₹',
  }) {
    final balance = totalBills - totalAdvances - totalSettlements;

    return FinancialSummaryCard(
      title: title,
      totalBills: totalBills,
      totalAdvances: totalAdvances,
      totalSettlements: totalSettlements,
      balance: balance,
      animate: animate,
      onTap: onTap,
      currencySymbol: currencySymbol,
      items: [
        FinancialItem(
          label: 'Total Bills',
          amount: totalBills,
          icon: Icons.receipt_long,
          color: AppColors.info,
        ),
        FinancialItem(
          label: 'Advances Received',
          amount: totalAdvances,
          icon: Icons.account_balance_wallet,
          color: AppColors.warning,
          isNegative: true,
        ),
        FinancialItem(
          label: 'Settlements',
          amount: totalSettlements,
          icon: Icons.payments,
          color: AppColors.success,
          isNegative: true,
        ),
        FinancialItem(
          label: 'Balance Due',
          amount: balance,
          icon: Icons.account_balance,
          color: balance >= 0 ? AppColors.primary : AppColors.error,
          isTotal: true,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),
          ],
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            
            Widget row = _buildFinancialRow(item);
            
            if (animate) {
              row = FadeInRight(
                duration: const Duration(milliseconds: 300),
                delay: Duration(milliseconds: index * 100),
                child: row,
              );
            }
            
            return Column(
              children: [
                if (item.isTotal) ...[
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                ],
                row,
                if (!item.isTotal && index < items.length - 1)
                  const SizedBox(height: 12),
              ],
            );
          }),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }

  Widget _buildFinancialRow(FinancialItem item) {
    final formatter = NumberFormat('#,##,###.##');

    return Row(
      children: [
        if (item.icon != null) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (item.color ?? AppColors.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              item.icon,
              size: item.isTotal ? 22 : 18,
              color: item.color ?? AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(
            item.label,
            style: TextStyle(
              fontSize: item.isTotal ? 15 : 14,
              fontWeight: item.isTotal ? FontWeight.w600 : FontWeight.w500,
              color: item.isTotal
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
        ),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: item.amount),
          duration: animate
              ? const Duration(milliseconds: 800)
              : Duration.zero,
          curve: Curves.easeOut,
          builder: (context, value, child) {
            final animatedAmount = formatter.format(value.abs());
            final animatedDisplay = item.isNegative && value > 0
                ? '- $currencySymbol$animatedAmount'
                : '$currencySymbol$animatedAmount';
            return Text(
              animatedDisplay,
              style: TextStyle(
                fontSize: item.isTotal ? 18 : 15,
                fontWeight: item.isTotal ? FontWeight.w700 : FontWeight.w600,
                color: item.color ?? AppColors.textPrimary,
              ),
            );
          },
        ),
      ],
    );
  }
}
