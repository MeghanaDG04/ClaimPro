import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/advance_model.dart';
import '../../core/theme/color_scheme.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/validation_utils.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class AddAdvanceDialog extends StatefulWidget {
  final AdvanceModel? advance;
  final String claimId;

  const AddAdvanceDialog({
    super.key,
    this.advance,
    required this.claimId,
  });

  static Future<AdvanceModel?> show({
    required BuildContext context,
    required String claimId,
    AdvanceModel? advance,
  }) {
    return showDialog<AdvanceModel>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddAdvanceDialog(
        claimId: claimId,
        advance: advance,
      ),
    );
  }

  @override
  State<AddAdvanceDialog> createState() => _AddAdvanceDialogState();
}

class _AddAdvanceDialogState extends State<AddAdvanceDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  late DateTime _advanceDate;
  late TextEditingController _amountController;
  late TextEditingController _referenceNumberController;
  late TextEditingController _paidToController;
  late TextEditingController _remarksController;
  late PaymentMode _paymentMode;

  bool _isLoading = false;

  bool get _isEditing => widget.advance != null;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();

    _advanceDate = widget.advance?.advanceDate ?? DateTime.now();
    _amountController = TextEditingController(
      text: widget.advance?.amount.toStringAsFixed(2) ?? '',
    );
    _referenceNumberController = TextEditingController(
      text: widget.advance?.referenceNumber ?? '',
    );
    _paidToController = TextEditingController(
      text: widget.advance?.paidTo ?? '',
    );
    _remarksController = TextEditingController(
      text: widget.advance?.remarks ?? '',
    );
    _paymentMode = widget.advance?.paymentMode ?? PaymentMode.cash;
  }

  @override
  void dispose() {
    _controller.dispose();
    _amountController.dispose();
    _referenceNumberController.dispose();
    _paidToController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _advanceDate,
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
      setState(() => _advanceDate = picked);
    }
  }

  String? _validateReferenceNumber(String? value) {
    if (_paymentMode != PaymentMode.cash) {
      return ValidationUtils.validateRequired(value, 'Reference number');
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(
        _amountController.text.replaceAll(RegExp(r'[,\s₹]'), ''),
      );

      AdvanceModel result;
      if (_isEditing) {
        result = widget.advance!.copyWith(
          advanceDate: _advanceDate,
          amount: amount,
          paymentMode: _paymentMode,
          referenceNumber: _referenceNumberController.text.trim().isNotEmpty
              ? _referenceNumberController.text.trim()
              : null,
          paidTo: _paidToController.text.trim(),
          remarks: _remarksController.text.trim().isNotEmpty
              ? _remarksController.text.trim()
              : null,
        );
      } else {
        result = AdvanceModel.create(
          claimId: widget.claimId,
          advanceDate: _advanceDate,
          amount: amount,
          paymentMode: _paymentMode,
          referenceNumber: _referenceNumberController.text.trim().isNotEmpty
              ? _referenceNumberController.text.trim()
              : null,
          paidTo: _paidToController.text.trim(),
          remarks: _remarksController.text.trim().isNotEmpty
              ? _remarksController.text.trim()
              : null,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.9;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: dialogWidth,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDatePicker(),
                          const SizedBox(height: 20),
                          _buildAmountField(),
                          const SizedBox(height: 20),
                          _buildPaymentModeDropdown(),
                          const SizedBox(height: 20),
                          _buildReferenceNumberField(),
                          const SizedBox(height: 20),
                          _buildPaidToField(),
                          const SizedBox(height: 20),
                          _buildRemarksField(),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _isEditing ? 'Edit Advance' : 'Add Advance',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: _cancel,
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Advance Date',
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
                Icon(
                  Icons.calendar_today,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  AppDateUtils.formatToDisplay(_advanceDate),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return CustomTextField(
      label: 'Amount',
      hint: 'Enter amount',
      controller: _amountController,
      prefixIcon: Icons.currency_rupee,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: (value) => ValidationUtils.validateAmount(
        value,
        minAmount: 0.01,
        fieldName: 'Amount',
      ),
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
              icon: const Icon(Icons.arrow_drop_down),
              items: PaymentMode.values.map((mode) {
                return DropdownMenuItem<PaymentMode>(
                  value: mode,
                  child: Row(
                    children: [
                      Icon(
                        _getPaymentModeIcon(mode),
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Text(mode.displayName),
                    ],
                  ),
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

  Widget _buildReferenceNumberField() {
    final isRequired = _paymentMode != PaymentMode.cash;
    return CustomTextField(
      label: 'Reference Number${isRequired ? '' : ' (Optional)'}',
      hint: 'Enter reference/transaction number',
      controller: _referenceNumberController,
      prefixIcon: Icons.tag,
      validator: _validateReferenceNumber,
    );
  }

  Widget _buildPaidToField() {
    return CustomTextField(
      label: 'Paid To',
      hint: 'Enter payee name',
      controller: _paidToController,
      prefixIcon: Icons.person_outline,
      validator: (value) => ValidationUtils.validateRequired(value, 'Paid To'),
    );
  }

  Widget _buildRemarksField() {
    return CustomTextField(
      label: 'Remarks (Optional)',
      hint: 'Enter any additional notes',
      controller: _remarksController,
      prefixIcon: Icons.notes,
      maxLines: 3,
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Cancel',
              variant: ButtonVariant.outline,
              onPressed: _isLoading ? null : _cancel,
              fullWidth: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomButton(
              text: _isEditing ? 'Update' : 'Save',
              variant: ButtonVariant.primary,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _save,
              fullWidth: true,
            ),
          ),
        ],
      ),
    );
  }
}
