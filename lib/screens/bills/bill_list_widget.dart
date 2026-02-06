import 'package:flutter/material.dart';
import '../../models/bill_model.dart';
import '../../core/theme/color_scheme.dart';
import '../../core/utils/calculation_utils.dart';
import '../../widgets/empty_state_widget.dart';
import 'bill_card.dart';

class BillListWidget extends StatelessWidget {
  final List<BillModel> bills;
  final String claimId;
  final Function(BillModel) onEditBill;
  final Function(String billId) onDeleteBill;
  final bool canEdit;

  const BillListWidget({
    super.key,
    required this.bills,
    required this.claimId,
    required this.onEditBill,
    required this.onDeleteBill,
    this.canEdit = true,
  });

  double get _totalAmount {
    return CalculationUtils.calculateTotalBills(
      bills.map((b) => b.amount).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (bills.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.receipt_long_outlined,
        title: 'No Bills Added',
        message: 'Add bills to track expenses for this claim.',
      );
    }

    return Column(
      children: [
        _buildTotalHeader(),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: bills.length,
            itemBuilder: (context, index) {
              final bill = bills[index];
              return BillCard(
                bill: bill,
                onEdit: canEdit ? () => onEditBill(bill) : null,
                onDelete: canEdit ? () => _confirmDelete(context, bill) : null,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTotalHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Bills',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${bills.length} ${bills.length == 1 ? 'bill' : 'bills'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
          Text(
            CalculationUtils.formatCurrency(_totalAmount),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, BillModel bill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bill'),
        content: Text(
          'Are you sure you want to delete bill "${bill.billNumber}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDeleteBill(bill.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
