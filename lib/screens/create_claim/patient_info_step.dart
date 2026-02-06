import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/claim_model.dart';
import '../../core/utils/validation_utils.dart';
import '../../core/utils/date_utils.dart';
import '../../core/theme/color_scheme.dart';
import '../../widgets/custom_text_field.dart';

class PatientInfoStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController patientNameController;
  final TextEditingController patientIdController;
  final TextEditingController contactNumberController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final DateTime? dateOfBirth;
  final Gender gender;
  final Function(DateTime?) onDateOfBirthChanged;
  final Function(Gender) onGenderChanged;

  const PatientInfoStep({
    super.key,
    required this.formKey,
    required this.patientNameController,
    required this.patientIdController,
    required this.contactNumberController,
    required this.emailController,
    required this.addressController,
    required this.dateOfBirth,
    required this.gender,
    required this.onDateOfBirthChanged,
    required this.onGenderChanged,
  });

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Select Date of Birth',
    );
    if (picked != null) {
      onDateOfBirthChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patient Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the patient\'s personal details',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
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
              label: 'Patient ID *',
              hint: 'Enter patient ID/UHID',
              controller: patientIdController,
              prefixIcon: Icons.badge_outlined,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-]')),
              ],
              validator: (value) => ValidationUtils.validateRequired(value, 'Patient ID'),
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
              hint: 'Enter full address (optional)',
              controller: addressController,
              prefixIcon: Icons.location_on_outlined,
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 24),
          ],
        ),
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
          onTap: () => _selectDate(context),
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
                    dateOfBirth != null
                        ? AppDateUtils.formatToDisplay(dateOfBirth)
                        : 'Select date of birth',
                    style: TextStyle(
                      fontSize: 16,
                      color: dateOfBirth != null
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                  ),
                ),
                if (dateOfBirth != null) ...[
                  Text(
                    '(${AppDateUtils.getAgeString(dateOfBirth)})',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => onDateOfBirthChanged(null),
                    child: Icon(
                      Icons.clear,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Gender>(
              value: gender,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
              items: Gender.values.map((g) {
                return DropdownMenuItem(
                  value: g,
                  child: Row(
                    children: [
                      Icon(
                        _getGenderIcon(g),
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Text(g.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onGenderChanged(value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  IconData _getGenderIcon(Gender gender) {
    switch (gender) {
      case Gender.male:
        return Icons.male;
      case Gender.female:
        return Icons.female;
      case Gender.other:
        return Icons.transgender;
    }
  }
}
