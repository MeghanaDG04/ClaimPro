import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/claim_provider.dart';
import '../../models/bill_model.dart';
import '../../models/claim_model.dart';
import '../../core/constants/status_constants.dart';
import '../../core/theme/color_scheme.dart';
import '../../core/utils/calculation_utils.dart';
import '../../core/utils/date_utils.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/confirmation_dialog.dart';
import 'bill_card.dart';
import 'bill_dialog.dart';

class BillsScreen extends StatefulWidget {
  final String claimId;

  const BillsScreen({
    super.key,
    required this.claimId,
  });

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  bool _isLoading = false;

  ClaimModel? get _claim {
    return context.read<ClaimProvider>().getClaimById(widget.claimId);
  }

  List<BillModel> get _bills {
    return _claim?.bills ?? [];
  }

  double get _totalAmount {
    return _bills.fold(0.0, (sum, bill) => sum + bill.amount);
  }

  double get _totalApprovedAmount {
    return _bills
        .where((bill) => bill.approvedAmount != null)
        .fold(0.0, (sum, bill) => sum + (bill.approvedAmount ?? 0));
  }

  Future<void> _addBill() async {
    await BillDialog.show(
      context: context,
      claimId: widget.claimId,
      onSave: (bill) async {
        await context.read<ClaimProvider>().addBillToClaim(widget.claimId, bill);
      },
    );
  }

  Future<void> _editBill(BillModel bill) async {
    await BillDialog.show(
      context: context,
      claimId: widget.claimId,
      bill: bill,
      onSave: (updatedBill) async {
        await context.read<ClaimProvider>().updateBillInClaim(widget.claimId, updatedBill);
      },
    );
  }

  Future<void> _deleteBill(BillModel bill) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Bill',
      message: 'Are you sure you want to delete bill ${bill.billNumber}? This action cannot be undone.',
      confirmText: 'Delete',
      type: DialogType.error,
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      try {
        await context.read<ClaimProvider>().removeBillFromClaim(
          widget.claimId,
          bill.id,
        );
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
        final bills = claim?.bills ?? [];

        return Scaffold(
          appBar: AppBar(
            title: Text('Bills for ${claim?.claimNumber ?? 'Claim'}'),
            elevation: 0,
          ),
          body: _isLoading || provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildSummaryCard(bills),
                    Expanded(
                      child: bills.isEmpty
                          ? _buildEmptyState()
                          : _buildBillsList(bills),
                    ),
                  ],
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _addBill,
            icon: const Icon(Icons.add),
            label: const Text('Add Bill'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(List<BillModel> bills) {
    final totalAmount = bills.fold(0.0, (sum, bill) => sum + bill.amount);
    final totalApproved = bills
        .where((b) => b.approvedAmount != null)
        .fold(0.0, (sum, bill) => sum + (bill.approvedAmount ?? 0));

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
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
                  Icons.receipt_long,
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
                      'Bills Summary',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${bills.length} ${bills.length == 1 ? 'Bill' : 'Bills'}',
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
                          'Approved Amount',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CalculationUtils.formatCurrency(totalApproved),
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
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Bills Added',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add bills to track expenses for this claim',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Add First Bill',
              leadingIcon: Icons.add,
              onPressed: _addBill,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillsList(List<BillModel> bills) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return _buildDesktopView(bills);
        }
        return _buildMobileView(bills);
      },
    );
  }

  Widget _buildMobileView(List<BillModel> bills) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: bills.length,
      itemBuilder: (context, index) {
        final bill = bills[index];
        return BillCard(
          bill: bill,
          onEdit: () => _editBill(bill),
          onDelete: () => _deleteBill(bill),
        );
      },
    );
  }

  Widget _buildDesktopView(List<BillModel> bills) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.background),
            columnSpacing: 24,
            horizontalMargin: 20,
            columns: const [
              DataColumn(label: Text('Bill #', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: bills.map((bill) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      bill.billNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  DataCell(Text(AppDateUtils.formatToDisplay(bill.billDate))),
                  DataCell(_buildBillTypeChip(bill.billType)),
                  DataCell(
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 200),
                      child: Text(
                        bill.description,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      CalculationUtils.formatCurrency(bill.amount),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  DataCell(_buildStatusBadge(bill.status)),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          tooltip: 'Edit',
                          onPressed: () => _editBill(bill),
                          color: AppColors.primary,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          tooltip: 'Delete',
                          onPressed: () => _deleteBill(bill),
                          color: AppColors.error,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildBillTypeChip(BillType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBillTypeColor(type).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type.displayName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _getBillTypeColor(type),
        ),
      ),
    );
  }

  Color _getBillTypeColor(BillType type) {
    switch (type) {
      case BillType.hospitalCharges:
        return Colors.blue;
      case BillType.doctorFees:
        return Colors.purple;
      case BillType.medicines:
        return Colors.green;
      case BillType.diagnostics:
        return Colors.orange;
      case BillType.roomCharges:
        return Colors.teal;
      case BillType.surgeryCharges:
        return Colors.red;
      case BillType.miscellaneous:
        return Colors.grey;
      case BillType.other:
        return Colors.blueGrey;
    }
  }

  Widget _buildStatusBadge(BillStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.icon,
            size: 14,
            color: status.color,
          ),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }
}
