import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/bill_model.dart';
import '../../core/theme/color_scheme.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/validation_utils.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class AddEditBillDialog extends StatefulWidget {
  final BillModel? bill;
  final String claimId;
  final Function(BillModel) onSave;

  const AddEditBillDialog({
    super.key,
    this.bill,
    required this.claimId,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    BillModel? bill,
    required String claimId,
    required Function(BillModel) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditBillDialog(
        bill: bill,
        claimId: claimId,
        onSave: onSave,
      ),
    );
  }

  @override
  State<AddEditBillDialog> createState() => _AddEditBillDialogState();
}

class _AddEditBillDialogState extends State<AddEditBillDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _billNumberController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;
  late final TextEditingController _remarksController;

  late DateTime _billDate;
  late BillType _billType;
  bool _isLoading = false;

  bool get _isEditing => widget.bill != null;

  @override
  void initState() {
    super.initState();
    _billNumberController = TextEditingController(
      text: widget.bill?.billNumber ?? _generateBillNumber(),
    );
    _descriptionController = TextEditingController(
      text: widget.bill?.description ?? '',
    );
    _amountController = TextEditingController(
      text: widget.bill?.amount.toString() ?? '',
    );
    _remarksController = TextEditingController(
      text: widget.bill?.remarks ?? '',
    );
    _billDate = widget.bill?.billDate ?? DateTime.now();
    _billType = widget.bill?.billType ?? BillType.hospitalCharges;
  }

  String _generateBillNumber() {
    final now = DateTime.now();
    return 'BILL-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';
  }

  @override
  void dispose() {
    _billNumberController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _billDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: AppColors.lightColorScheme,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _billDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final amount = double.parse(
      _amountController.text.replaceAll(RegExp(r'[,\s₹]'), ''),
    );

    final bill = _isEditing
        ? widget.bill!.copyWith(
            billNumber: _billNumberController.text.trim(),
            billDate: _billDate,
            billType: _billType,
            description: _descriptionController.text.trim(),
            amount: amount,
            remarks: _remarksController.text.trim().isEmpty
                ? null
                : _remarksController.text.trim(),
          )
        : BillModel.create(
            claimId: widget.claimId,
            billNumber: _billNumberController.text.trim(),
            billDate: _billDate,
            billType: _billType,
            description: _descriptionController.text.trim(),
            amount: amount,
            remarks: _remarksController.text.trim().isEmpty
                ? null
                : _remarksController.text.trim(),
          );

    widget.onSave(bill);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Bill Number',
                  controller: _billNumberController,
                  prefixIcon: Icons.receipt,
                  validator: (value) =>
                      ValidationUtils.validateRequired(value, 'Bill number'),
                ),
                const SizedBox(height: 16),
                _buildDatePicker(),
                const SizedBox(height: 16),
                _buildBillTypeDropdown(),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Description',
                  controller: _descriptionController,
                  prefixIcon: Icons.description,
                  maxLines: 3,
                  validator: (value) =>
                      ValidationUtils.validateRequired(value, 'Description'),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Amount',
                  controller: _amountController,
                  prefixIcon: Icons.currency_rupee,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) =>
                      ValidationUtils.validatePositiveNumber(value, 'Amount'),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Remarks (Optional)',
                  controller: _remarksController,
                  prefixIcon: Icons.note,
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                _buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _isEditing ? Icons.edit : Icons.add,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditing ? 'Edit Bill' : 'Add New Bill',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                _isEditing
                    ? 'Update bill details'
                    : 'Enter bill details for this claim',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bill Date',
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
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
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
                  AppDateUtils.formatToDisplay(_billDate),
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

  Widget _buildBillTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bill Type',
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
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<BillType>(
              value: _billType,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              items: BillType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _billType = value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Cancel',
            variant: ButtonVariant.outline,
            onPressed: () => Navigator.of(context).pop(),
            fullWidth: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            text: _isEditing ? 'Update' : 'Save',
            onPressed: _isLoading ? null : _submit,
            isLoading: _isLoading,
            fullWidth: true,
          ),
        ),
      ],
    );
  }
}
