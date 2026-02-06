import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/bill_model.dart';
import '../../core/constants/status_constants.dart';
import '../../core/theme/color_scheme.dart';
import '../../core/utils/date_utils.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class BillDialog extends StatefulWidget {
  final String claimId;
  final BillModel? bill;
  final Function(BillModel) onSave;

  const BillDialog({
    super.key,
    required this.claimId,
    this.bill,
    required this.onSave,
  });

  static Future<BillModel?> show({
    required BuildContext context,
    required String claimId,
    BillModel? bill,
    required Function(BillModel) onSave,
  }) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    if (isDesktop) {
      return showDialog<BillModel>(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: BillDialog(
              claimId: claimId,
              bill: bill,
              onSave: onSave,
            ),
          ),
        ),
      );
    } else {
      return showModalBottomSheet<BillModel>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: BillDialog(
              claimId: claimId,
              bill: bill,
              onSave: onSave,
            ),
          ),
        ),
      );
    }
  }

  @override
  State<BillDialog> createState() => _BillDialogState();
}

class _BillDialogState extends State<BillDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _billNumberController;
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _remarksController;

  late DateTime _billDate;
  late BillType _billType;
  bool _isLoading = false;

  bool get _isEditing => widget.bill != null;

  @override
  void initState() {
    super.initState();
    _billNumberController = TextEditingController(text: widget.bill?.billNumber ?? '');
    _descriptionController = TextEditingController(text: widget.bill?.description ?? '');
    _amountController = TextEditingController(
      text: widget.bill?.amount.toStringAsFixed(2) ?? '',
    );
    _remarksController = TextEditingController(text: widget.bill?.remarks ?? '');
    _billDate = widget.bill?.billDate ?? DateTime.now();
    _billType = widget.bill?.billType ?? BillType.hospitalCharges;
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
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _billDate = picked);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      
      final bill = widget.bill?.copyWith(
        billNumber: _billNumberController.text.trim(),
        billDate: _billDate,
        billType: _billType,
        description: _descriptionController.text.trim(),
        amount: amount,
        remarks: _remarksController.text.trim().isEmpty 
            ? null 
            : _remarksController.text.trim(),
      ) ?? BillModel.create(
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

      await widget.onSave(bill);
      
      if (mounted) {
        Navigator.of(context).pop(bill);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save bill: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _isEditing ? Icons.edit : Icons.add_circle_outline,
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
                              : 'Enter bill information',
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
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.background,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _billNumberController,
                label: 'Bill Number',
                hint: 'Enter bill number',
                prefixIcon: Icons.receipt,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Bill number is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDateField(),
              const SizedBox(height: 16),
              _buildBillTypeDropdown(),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Enter bill description',
                prefixIcon: Icons.description,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _amountController,
                label: 'Amount',
                hint: 'Enter amount',
                prefixIcon: Icons.currency_rupee,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Amount is required';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _remarksController,
                label: 'Remarks (Optional)',
                hint: 'Enter any additional remarks',
                prefixIcon: Icons.note,
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      variant: ButtonVariant.outline,
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      fullWidth: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: _isEditing ? 'Update Bill' : 'Add Bill',
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _handleSave,
                      fullWidth: true,
                      leadingIcon: _isEditing ? Icons.save : Icons.add,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
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
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<BillType>(
              value: _billType,
              isExpanded: true,
              icon: Icon(
                Icons.arrow_drop_down,
                color: AppColors.textSecondary,
              ),
              items: BillType.values.map((type) {
                return DropdownMenuItem<BillType>(
                  value: type,
                  child: Row(
                    children: [
                      Icon(
                        _getBillTypeIcon(type),
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Text(type.displayName),
                    ],
                  ),
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

  IconData _getBillTypeIcon(BillType type) {
    switch (type) {
      case BillType.hospitalCharges:
        return Icons.local_hospital;
      case BillType.doctorFees:
        return Icons.person;
      case BillType.medicines:
        return Icons.medication;
      case BillType.diagnostics:
        return Icons.biotech;
      case BillType.roomCharges:
        return Icons.bed;
      case BillType.surgeryCharges:
        return Icons.medical_services;
      case BillType.miscellaneous:
        return Icons.more_horiz;
      case BillType.other:
        return Icons.receipt_long;
    }
  }
}
