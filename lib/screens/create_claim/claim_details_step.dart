import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/claim_model.dart';
import '../../core/utils/validation_utils.dart';
import '../../core/theme/color_scheme.dart';
import '../../widgets/custom_text_field.dart';

class ClaimDetailsStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController policyNumberController;
  final TextEditingController insurerNameController;
  final TextEditingController tpaNameController;
  final TextEditingController diagnosisController;
  final TextEditingController treatmentController;
  final TextEditingController estimatedAmountController;
  final ClaimType claimType;
  final Function(ClaimType) onClaimTypeChanged;

  const ClaimDetailsStep({
    super.key,
    required this.formKey,
    required this.policyNumberController,
    required this.insurerNameController,
    required this.tpaNameController,
    required this.diagnosisController,
    required this.treatmentController,
    required this.estimatedAmountController,
    required this.claimType,
    required this.onClaimTypeChanged,
  });

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
              'Claim Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter policy and claim information',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              label: 'Policy Number *',
              hint: 'Enter policy number',
              controller: policyNumberController,
              prefixIcon: Icons.policy_outlined,
              textInputAction: TextInputAction.next,
              validator: (value) => ValidationUtils.validateRequired(value, 'Policy number'),
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
            _buildClaimTypeSelector(),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Diagnosis Details *',
              hint: 'Enter diagnosis details',
              controller: diagnosisController,
              prefixIcon: Icons.medical_information_outlined,
              maxLines: 3,
              textInputAction: TextInputAction.next,
              validator: (value) => ValidationUtils.validateRequired(value, 'Diagnosis details'),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Treatment Details',
              hint: 'Enter treatment details (optional)',
              controller: treatmentController,
              prefixIcon: Icons.healing_outlined,
              maxLines: 3,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Estimated Amount *',
              hint: 'Enter estimated claim amount',
              controller: estimatedAmountController,
              prefixIcon: Icons.currency_rupee,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) => ValidationUtils.validateAmount(value, fieldName: 'Estimated amount'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildClaimTypeSelector() {
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
        Row(
          children: ClaimType.values.map((type) {
            final isSelected = claimType == type;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: type == ClaimType.cashless ? 8 : 0,
                  left: type == ClaimType.reimbursement ? 8 : 0,
                ),
                child: InkWell(
                  onTap: () => onClaimTypeChanged(type),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          type == ClaimType.cashless
                              ? Icons.credit_card_off_outlined
                              : Icons.receipt_long_outlined,
                          size: 28,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          type.displayName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          type == ClaimType.cashless
                              ? 'Direct billing'
                              : 'Pay & claim',
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? Colors.white.withOpacity(0.8)
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
