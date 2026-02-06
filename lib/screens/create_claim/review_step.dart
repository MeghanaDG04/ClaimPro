import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/claim_model.dart';
import '../../core/utils/date_utils.dart';
import '../../core/theme/color_scheme.dart';
import '../../widgets/custom_button.dart';

class ReviewStep extends StatelessWidget {
  final String patientName;
  final String patientId;
  final DateTime? dateOfBirth;
  final Gender gender;
  final String contactNumber;
  final String? email;
  final String? address;
  final String hospitalName;
  final String? hospitalId;
  final DateTime admissionDate;
  final DateTime? dischargeDate;
  final String? treatingDoctor;
  final String? department;
  final String policyNumber;
  final String insurerName;
  final String? tpaName;
  final ClaimType claimType;
  final String? diagnosisDetails;
  final String? treatmentDetails;
  final double estimatedAmount;
  final Function(int) onEditStep;
  final VoidCallback onSaveDraft;
  final VoidCallback onSubmit;
  final bool isSubmitting;
  final bool isSavingDraft;

  const ReviewStep({
    super.key,
    required this.patientName,
    required this.patientId,
    required this.dateOfBirth,
    required this.gender,
    required this.contactNumber,
    required this.email,
    required this.address,
    required this.hospitalName,
    required this.hospitalId,
    required this.admissionDate,
    required this.dischargeDate,
    required this.treatingDoctor,
    required this.department,
    required this.policyNumber,
    required this.insurerName,
    required this.tpaName,
    required this.claimType,
    required this.diagnosisDetails,
    required this.treatmentDetails,
    required this.estimatedAmount,
    required this.onEditStep,
    required this.onSaveDraft,
    required this.onSubmit,
    this.isSubmitting = false,
    this.isSavingDraft = false,
  });

  bool get _hasPatientInfoMissing =>
      patientName.isEmpty || patientId.isEmpty || contactNumber.isEmpty;

  bool get _hasHospitalInfoMissing => hospitalName.isEmpty;

  bool get _hasClaimDetailsMissing =>
      policyNumber.isEmpty ||
      insurerName.isEmpty ||
      (diagnosisDetails?.isEmpty ?? true) ||
      estimatedAmount <= 0;

  bool get _hasMissingFields =>
      _hasPatientInfoMissing || _hasHospitalInfoMissing || _hasClaimDetailsMissing;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Submit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please review all details before submitting',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          if (_hasMissingFields) ...[
            const SizedBox(height: 16),
            _buildMissingFieldsWarning(),
          ],
          const SizedBox(height: 24),
          _buildSection(
            title: 'Patient Information',
            stepIndex: 0,
            hasMissing: _hasPatientInfoMissing,
            children: [
              _buildInfoRow('Patient Name', patientName, required: true),
              _buildInfoRow('Patient ID', patientId, required: true),
              _buildInfoRow(
                'Date of Birth',
                dateOfBirth != null
                    ? '${AppDateUtils.formatToDisplay(dateOfBirth)} (${AppDateUtils.getAgeString(dateOfBirth)})'
                    : null,
              ),
              _buildInfoRow('Gender', gender.displayName),
              _buildInfoRow('Contact Number', contactNumber, required: true),
              _buildInfoRow('Email', email),
              _buildInfoRow('Address', address),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Hospital Details',
            stepIndex: 1,
            hasMissing: _hasHospitalInfoMissing,
            children: [
              _buildInfoRow('Hospital Name', hospitalName, required: true),
              _buildInfoRow('Hospital ID', hospitalId),
              _buildInfoRow(
                'Admission Date',
                AppDateUtils.formatToDisplay(admissionDate),
              ),
              _buildInfoRow(
                'Discharge Date',
                dischargeDate != null
                    ? AppDateUtils.formatToDisplay(dischargeDate)
                    : 'Still admitted',
              ),
              if (dischargeDate != null)
                _buildInfoRow(
                  'Duration',
                  '${AppDateUtils.daysBetween(admissionDate, dischargeDate!)} days',
                ),
              _buildInfoRow('Treating Doctor', treatingDoctor),
              _buildInfoRow('Department', department),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Claim Details',
            stepIndex: 2,
            hasMissing: _hasClaimDetailsMissing,
            children: [
              _buildInfoRow('Policy Number', policyNumber, required: true),
              _buildInfoRow('Insurer Name', insurerName, required: true),
              _buildInfoRow('TPA Name', tpaName),
              _buildInfoRow('Claim Type', claimType.displayName),
              _buildInfoRow('Diagnosis', diagnosisDetails, required: true),
              _buildInfoRow('Treatment', treatmentDetails),
              _buildInfoRow(
                'Estimated Amount',
                estimatedAmount > 0
                    ? NumberFormat.currency(locale: 'en_IN', symbol: '₹')
                        .format(estimatedAmount)
                    : null,
                required: true,
                highlight: true,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Save as Draft',
                  variant: ButtonVariant.outline,
                  leadingIcon: Icons.save_outlined,
                  isLoading: isSavingDraft,
                  onPressed: isSavingDraft || isSubmitting ? null : onSaveDraft,
                  fullWidth: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Submit Claim',
                  variant: ButtonVariant.primary,
                  leadingIcon: Icons.send_outlined,
                  isLoading: isSubmitting,
                  onPressed: _hasMissingFields || isSubmitting || isSavingDraft
                      ? null
                      : onSubmit,
                  fullWidth: true,
                ),
              ),
            ],
          ),
          if (_hasMissingFields)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Please complete all required fields before submitting',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMissingFieldsWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Missing Required Fields',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warningDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Some required fields are incomplete. Please review and complete them before submitting.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.warningDark.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required int stepIndex,
    required bool hasMissing,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasMissing ? AppColors.error.withOpacity(0.5) : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: hasMissing
                  ? AppColors.errorLight
                  : AppColors.surfaceVariant,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (hasMissing)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.error_outline,
                          size: 18,
                          color: AppColors.error,
                        ),
                      ),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: hasMissing ? AppColors.error : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => onEditStep(stepIndex),
                  icon: Icon(Icons.edit_outlined, size: 16),
                  label: Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String? value, {
    bool required = false,
    bool highlight = false,
  }) {
    final isEmpty = value == null || value.isEmpty;
    final showError = required && isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (required)
                  Text(
                    ' *',
                    style: TextStyle(
                      fontSize: 14,
                      color: showError ? AppColors.error : AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: showError
                ? Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Required',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.error,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  )
                : Text(
                    value ?? '—',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: highlight ? FontWeight.w600 : FontWeight.w500,
                      color: highlight ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
