import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/color_scheme.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/validation_utils.dart';
import '../../models/claim_model.dart';
import '../../widgets/custom_text_field.dart';

class HospitalDetailsForm extends StatelessWidget {
  final TextEditingController hospitalNameController;
  final TextEditingController hospitalIdController;
  final TextEditingController treatingDoctorController;
  final TextEditingController departmentController;
  final TextEditingController policyNumberController;
  final TextEditingController insurerNameController;
  final TextEditingController tpaNameController;
  final TextEditingController diagnosisDetailsController;
  final TextEditingController treatmentDetailsController;
  final TextEditingController estimatedAmountController;
  final ClaimType? selectedClaimType;
  final ValueChanged<ClaimType?> onClaimTypeChanged;
  final DateTime? selectedAdmissionDate;
  final ValueChanged<DateTime?> onAdmissionDateChanged;
  final DateTime? selectedDischargeDate;
  final ValueChanged<DateTime?> onDischargeDateChanged;
  final GlobalKey<FormState>? formKey;

  const HospitalDetailsForm({
    super.key,
    required this.hospitalNameController,
    required this.hospitalIdController,
    required this.treatingDoctorController,
    required this.departmentController,
    required this.policyNumberController,
    required this.insurerNameController,
    required this.tpaNameController,
    required this.diagnosisDetailsController,
    required this.treatmentDetailsController,
    required this.estimatedAmountController,
    required this.selectedClaimType,
    required this.onClaimTypeChanged,
    required this.selectedAdmissionDate,
    required this.onAdmissionDateChanged,
    required this.selectedDischargeDate,
    required this.onDischargeDateChanged,
    this.formKey,
  });

  Future<void> _selectAdmissionDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedAdmissionDate ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
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
      onAdmissionDateChanged(picked);
    }
  }

  Future<void> _selectDischargeDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime minDate = selectedAdmissionDate ?? DateTime(2000);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDischargeDate ?? (selectedAdmissionDate ?? now),
      firstDate: minDate,
      lastDate: now.add(const Duration(days: 365)),
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
      onDischargeDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Hospital Information'),
          const SizedBox(height: 12),
          CustomTextField(
            label: 'Hospital Name *',
            hint: 'Enter hospital name',
            controller: hospitalNameController,
            prefixIcon: Icons.local_hospital_outlined,
            textInputAction: TextInputAction.next,
            validator: (value) => ValidationUtils.validateRequired(value, 'Hospital name'),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Hospital ID',
            hint: 'Enter hospital ID (optional)',
            controller: hospitalIdController,
            prefixIcon: Icons.numbers_outlined,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  context: context,
                  label: 'Admission Date *',
                  selectedDate: selectedAdmissionDate,
                  onTap: () => _selectAdmissionDate(context),
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateField(
                  context: context,
                  label: 'Discharge Date',
                  selectedDate: selectedDischargeDate,
                  onTap: () => _selectDischargeDate(context),
                  isRequired: false,
                ),
              ),
            ],
          ),
          if (selectedDischargeDate != null &&
              selectedAdmissionDate != null &&
              selectedDischargeDate!.isBefore(selectedAdmissionDate!))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Discharge date must be after admission date',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Treating Doctor',
            hint: 'Enter treating doctor name (optional)',
            controller: treatingDoctorController,
            prefixIcon: Icons.medical_services_outlined,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Department',
            hint: 'Enter department (optional)',
            controller: departmentController,
            prefixIcon: Icons.domain_outlined,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Insurance Information'),
          const SizedBox(height: 12),
          CustomTextField(
            label: 'Policy Number *',
            hint: 'Enter policy number (e.g., ABC12345678)',
            controller: policyNumberController,
            prefixIcon: Icons.policy_outlined,
            textInputAction: TextInputAction.next,
            validator: ValidationUtils.validatePolicyNumber,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Insurer Name *',
            hint: 'Enter insurance company name',
            controller: insurerNameController,
            prefixIcon: Icons.business_outlined,
            textInputAction: TextInputAction.next,
            validator: (value) => ValidationUtils.validateRequired(value, 'Insurer name'),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'TPA Name',
            hint: 'Enter TPA name (optional)',
            controller: tpaNameController,
            prefixIcon: Icons.account_balance_outlined,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          _buildClaimTypeDropdown(),
          const SizedBox(height: 24),
          _buildSectionHeader('Medical Details'),
          const SizedBox(height: 12),
          CustomTextField(
            label: 'Diagnosis Details',
            hint: 'Enter diagnosis details',
            controller: diagnosisDetailsController,
            prefixIcon: Icons.description_outlined,
            maxLines: 3,
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Treatment Details',
            hint: 'Enter treatment details',
            controller: treatmentDetailsController,
            prefixIcon: Icons.healing_outlined,
            maxLines: 3,
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Estimated Amount (₹) *',
            hint: 'Enter estimated claim amount',
            controller: estimatedAmountController,
            prefixIcon: Icons.currency_rupee_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) => ValidationUtils.validatePositiveNumber(value, 'Estimated amount'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
    required bool isRequired,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? AppDateUtils.formatToDisplay(selectedDate)
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 14,
                      color: selectedDate != null
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isRequired && selectedDate == null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '',
              style: TextStyle(fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildClaimTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Claim Type *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<ClaimType>(
          value: selectedClaimType,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.category_outlined,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error),
            ),
          ),
          hint: Text(
            'Select claim type',
            style: TextStyle(color: AppColors.textHint),
          ),
          items: ClaimType.values.map((type) {
            return DropdownMenuItem<ClaimType>(
              value: type,
              child: Text(type.displayName),
            );
          }).toList(),
          onChanged: onClaimTypeChanged,
          validator: (value) {
            if (value == null) {
              return 'Please select a claim type';
            }
            return null;
          },
        ),
      ],
    );
  }
}
