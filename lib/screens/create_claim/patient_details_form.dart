import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/color_scheme.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/validation_utils.dart';
import '../../models/claim_model.dart';
import '../../widgets/custom_text_field.dart';

class PatientDetailsForm extends StatelessWidget {
  final TextEditingController patientNameController;
  final TextEditingController patientIdController;
  final TextEditingController contactNumberController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final Gender? selectedGender;
  final ValueChanged<Gender?> onGenderChanged;
  final DateTime? selectedDateOfBirth;
  final ValueChanged<DateTime?> onDateOfBirthChanged;
  final GlobalKey<FormState>? formKey;

  const PatientDetailsForm({
    super.key,
    required this.patientNameController,
    required this.patientIdController,
    required this.contactNumberController,
    required this.emailController,
    required this.addressController,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.selectedDateOfBirth,
    required this.onDateOfBirthChanged,
    this.formKey,
  });

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateOfBirth ?? DateTime(now.year - 30),
      firstDate: DateTime(1900),
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
      onDateOfBirthChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            label: 'Patient Name *',
            hint: 'Enter patient full name',
            controller: patientNameController,
            prefixIcon: Icons.person_outline,
            textInputAction: TextInputAction.next,
            validator: (value) => ValidationUtils.validateRequired(value, 'Patient name'),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Patient ID / UHID *',
            hint: 'Enter patient ID or UHID',
            controller: patientIdController,
            prefixIcon: Icons.badge_outlined,
            textInputAction: TextInputAction.next,
            validator: ValidationUtils.validateUHID,
          ),
          const SizedBox(height: 16),
          _buildDateOfBirthField(context),
          const SizedBox(height: 16),
          _buildGenderDropdown(),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Contact Number *',
            hint: 'Enter 10-digit mobile number',
            controller: contactNumberController,
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: ValidationUtils.validatePhone,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Email',
            hint: 'Enter email address (optional)',
            controller: emailController,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: ValidationUtils.validateOptionalEmail,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Address',
            hint: 'Enter patient address (optional)',
            controller: addressController,
            prefixIcon: Icons.location_on_outlined,
            maxLines: 3,
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
          ),
        ],
      ),
    );
  }

  Widget _buildDateOfBirthField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of Birth',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDateOfBirth(context),
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
                  Icons.calendar_today_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedDateOfBirth != null
                        ? AppDateUtils.formatToDisplay(selectedDateOfBirth)
                        : 'Select date of birth',
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedDateOfBirth != null
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                  ),
                ),
                if (selectedDateOfBirth != null)
                  Text(
                    '(${AppDateUtils.getAgeString(selectedDateOfBirth)})',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<Gender>(
          value: selectedGender,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.wc_outlined,
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
            'Select gender',
            style: TextStyle(color: AppColors.textHint),
          ),
          items: Gender.values.map((gender) {
            return DropdownMenuItem<Gender>(
              value: gender,
              child: Text(gender.displayName),
            );
          }).toList(),
          onChanged: onGenderChanged,
          validator: (value) {
            if (value == null) {
              return 'Please select a gender';
            }
            return null;
          },
        ),
      ],
    );
  }
}
