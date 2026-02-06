import 'package:flutter/material.dart';
import '../../core/utils/validation_utils.dart';
import '../../core/utils/date_utils.dart';
import '../../core/theme/color_scheme.dart';
import '../../widgets/custom_text_field.dart';

class HospitalInfoStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController hospitalNameController;
  final TextEditingController hospitalIdController;
  final TextEditingController treatingDoctorController;
  final DateTime admissionDate;
  final DateTime? dischargeDate;
  final String? department;
  final Function(DateTime) onAdmissionDateChanged;
  final Function(DateTime?) onDischargeDateChanged;
  final Function(String?) onDepartmentChanged;

  static const List<String> departments = [
    'General Medicine',
    'Cardiology',
    'Orthopedics',
    'Neurology',
    'Oncology',
    'Gastroenterology',
    'Pulmonology',
    'Nephrology',
    'Urology',
    'Gynecology',
    'Pediatrics',
    'ENT',
    'Ophthalmology',
    'Dermatology',
    'Psychiatry',
    'Emergency Medicine',
    'Critical Care / ICU',
    'Surgery - General',
    'Surgery - Cardiac',
    'Surgery - Neuro',
    'Other',
  ];

  const HospitalInfoStep({
    super.key,
    required this.formKey,
    required this.hospitalNameController,
    required this.hospitalIdController,
    required this.treatingDoctorController,
    required this.admissionDate,
    required this.dischargeDate,
    required this.department,
    required this.onAdmissionDateChanged,
    required this.onDischargeDateChanged,
    required this.onDepartmentChanged,
  });

  Future<void> _selectAdmissionDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: admissionDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      helpText: 'Select Admission Date',
    );
    if (picked != null) {
      onAdmissionDateChanged(picked);
      if (dischargeDate != null && dischargeDate!.isBefore(picked)) {
        onDischargeDateChanged(null);
      }
    }
  }

  Future<void> _selectDischargeDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dischargeDate ?? admissionDate,
      firstDate: admissionDate,
      lastDate: DateTime.now().add(const Duration(days: 30)),
      helpText: 'Select Discharge Date',
    );
    if (picked != null) {
      onDischargeDateChanged(picked);
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
              'Hospital Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the hospital and admission details',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
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
            _buildAdmissionDateField(context),
            const SizedBox(height: 16),
            _buildDischargeDateField(context),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Treating Doctor',
              hint: 'Enter doctor\'s name (optional)',
              controller: treatingDoctorController,
              prefixIcon: Icons.medical_services_outlined,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            _buildDepartmentDropdown(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAdmissionDateField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Admission Date *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectAdmissionDate(context),
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
                    AppDateUtils.formatToDisplay(admissionDate),
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDischargeDateField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Discharge Date',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDischargeDate(context),
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
                  Icons.event_available_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    dischargeDate != null
                        ? AppDateUtils.formatToDisplay(dischargeDate)
                        : 'Select discharge date (optional)',
                    style: TextStyle(
                      fontSize: 16,
                      color: dischargeDate != null
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                  ),
                ),
                if (dischargeDate != null) ...[
                  _buildDurationBadge(),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => onDischargeDateChanged(null),
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

  Widget _buildDurationBadge() {
    if (dischargeDate == null) return const SizedBox.shrink();
    final days = AppDateUtils.daysBetween(admissionDate, dischargeDate!);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$days ${days == 1 ? 'day' : 'days'}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.info,
        ),
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Department',
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
            child: DropdownButton<String>(
              value: department,
              hint: Row(
                children: [
                  Icon(
                    Icons.apartment_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Select department (optional)',
                    style: TextStyle(color: AppColors.textHint),
                  ),
                ],
              ),
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
              items: departments.map((dept) {
                return DropdownMenuItem(
                  value: dept,
                  child: Text(dept),
                );
              }).toList(),
              onChanged: onDepartmentChanged,
            ),
          ),
        ),
        if (department != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: GestureDetector(
              onTap: () => onDepartmentChanged(null),
              child: Text(
                'Clear selection',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
