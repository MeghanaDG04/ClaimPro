import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/claim_model.dart';
import '../../models/settlement_model.dart';
import '../../models/advance_model.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/color_scheme.dart';
import '../../core/utils/validation_utils.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/calculation_utils.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class SettlementForm extends StatefulWidget {
  final ClaimModel claim;
  final Function(SettlementModel) onSubmit;
  final bool isLoading;

  const SettlementForm({
    super.key,
    required this.claim,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<SettlementForm> createState() => _SettlementFormState();
}

class _SettlementFormState extends State<SettlementForm> {
  final _formKey = GlobalKey<FormState>();
  
  late DateTime _settlementDate;
  late SettlementType _settlementType;
  late PaymentMode _paymentMode;
  
  final _settledAmountController = TextEditingController();
  final _referenceNumberController = TextEditingController();
  final _deductionsController = TextEditingController();
  final _deductionRemarksController = TextEditingController();
  final _remarksController = TextEditingController();

  double get _settledAmount =>
      double.tryParse(_settledAmountController.text) ?? 0.0;
  
  double get _deductions =>
      double.tryParse(_deductionsController.text) ?? 0.0;
  
  double get _netAmount => _settledAmount - _deductions;

  @override
  void initState() {
    super.initState();
    _settlementDate = DateTime.now();
    _settlementType = SettlementType.partial;
    _paymentMode = PaymentMode.bankTransfer;
    _deductionsController.text = '0';
  }

  @override
  void dispose() {
    _settledAmountController.dispose();
    _referenceNumberController.dispose();
    _deductionsController.dispose();
    _deductionRemarksController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Card(
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
              _buildDatePicker(),
              const SizedBox(height: 16),
              _buildSettlementTypeDropdown(),
              const SizedBox(height: 16),
              _buildSettledAmountField(),
              const SizedBox(height: 16),
              _buildPaymentModeDropdown(),
              const SizedBox(height: 16),
              _buildReferenceNumberField(),
              const SizedBox(height: 16),
              _buildDeductionsField(),
              if (_deductions > 0) ...[
                const SizedBox(height: 16),
                _buildDeductionRemarksField(),
              ],
              const SizedBox(height: 16),
              _buildRemarksField(),
              const SizedBox(height: 20),
              _buildNetAmountPreview(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Settlement Date',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: 12),
                Text(
                  AppDateUtils.formatToDisplay(_settlementDate),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _settlementDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _settlementDate = picked);
    }
  }

  Widget _buildSettlementTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Settlement Type',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<SettlementType>(
              value: _settlementType,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              items: SettlementType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _settlementType = value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettledAmountField() {
    return CustomTextField(
      label: 'Settled Amount',
      hint: 'Enter amount',
      controller: _settledAmountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      prefixIcon: Icons.currency_rupee,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      validator: (value) {
        final error = ValidationUtils.validateAmount(
          value,
          fieldName: 'Settled amount',
          minAmount: 0.01,
          maxAmount: widget.claim.pendingAmount,
        );
        if (error != null) return error;
        return null;
      },
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildPaymentModeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Mode',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<PaymentMode>(
              value: _paymentMode,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              items: PaymentMode.values.map((mode) {
                return DropdownMenuItem(
                  value: mode,
                  child: Text(mode.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _paymentMode = value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferenceNumberField() {
    return CustomTextField(
      label: 'Reference Number',
      hint: 'Enter transaction reference',
      controller: _referenceNumberController,
      prefixIcon: Icons.numbers,
      validator: (value) => ValidationUtils.validateRequired(value, 'Reference number'),
    );
  }

  Widget _buildDeductionsField() {
    return CustomTextField(
      label: 'Deductions',
      hint: 'Enter deduction amount (if any)',
      controller: _deductionsController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      prefixIcon: Icons.remove_circle_outline,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) return null;
        final amount = double.tryParse(value);
        if (amount == null) return 'Please enter a valid amount';
        if (amount < 0) return 'Deductions cannot be negative';
        if (amount >= _settledAmount) {
          return 'Deductions must be less than settled amount';
        }
        return null;
      },
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildDeductionRemarksField() {
    return CustomTextField(
      label: 'Deduction Remarks',
      hint: 'Reason for deductions',
      controller: _deductionRemarksController,
      prefixIcon: Icons.note,
      maxLines: 2,
    );
  }

  Widget _buildRemarksField() {
    return CustomTextField(
      label: 'Remarks (Optional)',
      hint: 'Any additional remarks',
      controller: _remarksController,
      prefixIcon: Icons.comment,
      maxLines: 3,
    );
  }

  Widget _buildNetAmountPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Settled Amount',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                CalculationUtils.formatCurrency(_settledAmount),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (_deductions > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Deductions',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '- ${CalculationUtils.formatCurrency(_deductions)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Net Amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                CalculationUtils.formatCurrency(_netAmount),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return CustomButton(
      text: 'Submit Settlement',
      fullWidth: true,
      isLoading: widget.isLoading,
      leadingIcon: Icons.check_circle,
      onPressed: widget.isLoading ? null : _handleSubmit,
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final settledBy = authProvider.currentUser?.name ?? 'Unknown User';

    final settlement = SettlementModel.create(
      claimId: widget.claim.id,
      settlementDate: _settlementDate,
      settledAmount: _settledAmount,
      settlementType: _settlementType,
      paymentMode: _paymentMode,
      referenceNumber: _referenceNumberController.text.trim(),
      deductions: _deductions,
      deductionRemarks: _deductions > 0
          ? _deductionRemarksController.text.trim()
          : null,
      remarks: _remarksController.text.trim().isNotEmpty
          ? _remarksController.text.trim()
          : null,
      settledBy: settledBy,
    );

    widget.onSubmit(settlement);
  }
}
