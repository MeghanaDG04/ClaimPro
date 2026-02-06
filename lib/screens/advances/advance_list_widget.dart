import 'package:flutter/material.dart';
import '../../models/advance_model.dart';
import '../../core/constants/status_constants.dart';
import '../../core/theme/color_scheme.dart';
import '../../core/utils/calculation_utils.dart';
import '../../core/utils/date_utils.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/status_badge.dart';

class AdvanceListWidget extends StatelessWidget {
  final List<AdvanceModel> advances;
  final Function(AdvanceModel) onEdit;
  final Function(String advanceId) onDelete;
  final bool canModify;

  const AdvanceListWidget({
    super.key,
    required this.advances,
    required this.onEdit,
    required this.onDelete,
    this.canModify = true,
  });

  double get _totalAmount {
    return advances.fold(0.0, (sum, advance) => sum + advance.amount);
  }

  bool _canModifyAdvance(AdvanceModel advance) {
    if (!canModify) return false;
    return advance.status == AdvanceStatus.requested ||
        advance.status == AdvanceStatus.approved;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return _buildDesktopView(context);
        }
        return _buildMobileView(context);
      },
    );
  }

  Widget _buildMobileView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: advances.length,
            itemBuilder: (context, index) {
              final advance = advances[index];
              return _buildAdvanceCard(context, advance, index);
            },
          ),
        ),
        _buildTotalFooter(),
      ],
    );
  }

  Widget _buildAdvanceCard(
      BuildContext context, AdvanceModel advance, int index) {
    final canModifyThis = _canModifyAdvance(advance);

    return AnimatedCard(
      delay: Duration(milliseconds: index * 50),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      advance.advanceNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppDateUtils.formatToDisplay(advance.advanceDate),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge.advance(
                status: advance.status,
                size: BadgeSize.small,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Amount',
                    CalculationUtils.formatCurrency(advance.amount),
                    Icons.currency_rupee,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.border,
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Payment Mode',
                    advance.paymentMode.displayName,
                    _getPaymentModeIcon(advance.paymentMode),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Paid to: ${advance.paidTo}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (advance.referenceNumber != null &&
              advance.referenceNumber!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.tag,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ref: ${advance.referenceNumber}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (advance.remarks != null && advance.remarks!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.notes,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    advance.remarks!,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (canModifyThis) ...[
            const SizedBox(height: 12),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => onEdit(advance),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => onDelete(advance.id),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getPaymentModeIcon(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.cash:
        return Icons.money;
      case PaymentMode.cheque:
        return Icons.description_outlined;
      case PaymentMode.bankTransfer:
        return Icons.account_balance;
      case PaymentMode.upi:
        return Icons.phone_android;
    }
  }

  Widget _buildDesktopView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: DataTable(
                  headingRowColor:
                      WidgetStateProperty.all(AppColors.background),
                  columnSpacing: 24,
                  horizontalMargin: 20,
                  columns: const [
                    DataColumn(
                        label: Text('Advance #',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Date',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Amount',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        numeric: true),
                    DataColumn(
                        label: Text('Payment Mode',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Paid To',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Status',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Actions',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: advances.map((advance) {
                    final canModifyThis = _canModifyAdvance(advance);
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            advance.advanceNumber,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        DataCell(Text(
                            AppDateUtils.formatToDisplay(advance.advanceDate))),
                        DataCell(
                          Text(
                            CalculationUtils.formatCurrency(advance.amount),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        DataCell(_buildPaymentModeChip(advance.paymentMode)),
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 150),
                            child: Text(
                              advance.paidTo,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(StatusBadge.advance(
                          status: advance.status,
                          size: BadgeSize.small,
                        )),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (canModifyThis) ...[
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined,
                                      size: 20),
                                  tooltip: 'Edit',
                                  onPressed: () => onEdit(advance),
                                  color: AppColors.primary,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      size: 20),
                                  tooltip: 'Delete',
                                  onPressed: () => onDelete(advance.id),
                                  color: AppColors.error,
                                ),
                              ] else
                                const Text(
                                  '-',
                                  style:
                                      TextStyle(color: AppColors.textSecondary),
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
          ),
        ),
        _buildTotalFooter(),
      ],
    );
  }

  Widget _buildPaymentModeChip(PaymentMode mode) {
    Color color;
    switch (mode) {
      case PaymentMode.cash:
        color = Colors.green;
        break;
      case PaymentMode.cheque:
        color = Colors.blue;
        break;
      case PaymentMode.bankTransfer:
        color = Colors.purple;
        break;
      case PaymentMode.upi:
        color = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getPaymentModeIcon(mode),
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            mode.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
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
                'Total Advances',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${advances.length} ${advances.length == 1 ? 'advance' : 'advances'}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
          Text(
            CalculationUtils.formatCurrency(_totalAmount),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
