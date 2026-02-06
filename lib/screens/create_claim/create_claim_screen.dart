import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/claim_model.dart';
import '../../providers/claim_provider.dart';
import '../../core/constants/status_constants.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../core/theme/color_scheme.dart';
import '../../services/storage_service.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/loading_widget.dart';
import 'patient_info_step.dart';
import 'hospital_info_step.dart';
import 'claim_details_step.dart';
import 'review_step.dart';

class CreateClaimScreen extends StatefulWidget {
  final String? claimId;

  const CreateClaimScreen({super.key, this.claimId});

  @override
  State<CreateClaimScreen> createState() => _CreateClaimScreenState();
}

class _CreateClaimScreenState extends State<CreateClaimScreen> {
  int _currentStep = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isSavingDraft = false;

  final _patientFormKey = GlobalKey<FormState>();
  final _hospitalFormKey = GlobalKey<FormState>();
  final _claimDetailsFormKey = GlobalKey<FormState>();

  final _patientNameController = TextEditingController();
  final _patientIdController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _hospitalNameController = TextEditingController();
  final _hospitalIdController = TextEditingController();
  final _treatingDoctorController = TextEditingController();
  final _policyNumberController = TextEditingController();
  final _insurerNameController = TextEditingController();
  final _tpaNameController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _estimatedAmountController = TextEditingController();

  DateTime? _dateOfBirth;
  Gender _gender = Gender.male;
  DateTime _admissionDate = DateTime.now();
  DateTime? _dischargeDate;
  String? _department;
  ClaimType _claimType = ClaimType.cashless;

  String? _existingClaimId;
  String? _existingClaimNumber;

  bool get isEditMode => widget.claimId != null;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _patientIdController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _hospitalNameController.dispose();
    _hospitalIdController.dispose();
    _treatingDoctorController.dispose();
    _policyNumberController.dispose();
    _insurerNameController.dispose();
    _tpaNameController.dispose();
    _diagnosisController.dispose();
    _treatmentController.dispose();
    _estimatedAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    if (isEditMode) {
      final provider = context.read<ClaimProvider>();
      final claim = provider.getClaimById(widget.claimId!);
      if (claim != null) {
        _populateFromClaim(claim);
        _existingClaimId = claim.id;
        _existingClaimNumber = claim.claimNumber;
      }
    } else {
      final draft = StorageService.getDraft();
      if (draft != null) {
        final shouldLoadDraft = await _showLoadDraftDialog();
        if (shouldLoadDraft == true) {
          _populateFromClaim(draft);
          _existingClaimId = draft.id;
          _existingClaimNumber = draft.claimNumber;
        } else if (shouldLoadDraft == false) {
          await StorageService.clearDraft();
        }
      }
    }

    setState(() => _isLoading = false);
  }

  Future<bool?> _showLoadDraftDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.drafts_outlined, color: AppColors.primary),
            const SizedBox(width: 12),
            const Text('Resume Draft?'),
          ],
        ),
        content: const Text(
          'You have an unsaved draft. Would you like to continue where you left off?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Start Fresh'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Resume Draft'),
          ),
        ],
      ),
    );
  }

  void _populateFromClaim(ClaimModel claim) {
    _patientNameController.text = claim.patientName;
    _patientIdController.text = claim.patientId;
    _contactNumberController.text = claim.contactNumber;
    _emailController.text = claim.email ?? '';
    _addressController.text = claim.address ?? '';
    _dateOfBirth = claim.dateOfBirth;
    _gender = claim.gender;

    _hospitalNameController.text = claim.hospitalName;
    _hospitalIdController.text = claim.hospitalId ?? '';
    _treatingDoctorController.text = claim.treatingDoctor ?? '';
    _admissionDate = claim.admissionDate;
    _dischargeDate = claim.dischargeDate;
    _department = claim.department;

    _policyNumberController.text = claim.policyNumber;
    _insurerNameController.text = claim.insurerName;
    _tpaNameController.text = claim.tpaName ?? '';
    _diagnosisController.text = claim.diagnosisDetails ?? '';
    _treatmentController.text = claim.treatmentDetails ?? '';
    _estimatedAmountController.text =
        claim.estimatedAmount > 0 ? claim.estimatedAmount.toString() : '';
    _claimType = claim.claimType;
  }

  ClaimModel _buildClaimFromForm({ClaimStatus status = ClaimStatus.draft}) {
    final estimatedAmount =
        double.tryParse(_estimatedAmountController.text.replaceAll(',', '')) ?? 0.0;

    if (_existingClaimId != null) {
      return ClaimModel(
        id: _existingClaimId!,
        claimNumber: _existingClaimNumber ?? '',
        patientName: _patientNameController.text.trim(),
        patientId: _patientIdController.text.trim(),
        dateOfBirth: _dateOfBirth,
        gender: _gender,
        contactNumber: _contactNumberController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        hospitalName: _hospitalNameController.text.trim(),
        hospitalId: _hospitalIdController.text.trim().isEmpty
            ? null
            : _hospitalIdController.text.trim(),
        admissionDate: _admissionDate,
        dischargeDate: _dischargeDate,
        treatingDoctor: _treatingDoctorController.text.trim().isEmpty
            ? null
            : _treatingDoctorController.text.trim(),
        department: _department,
        policyNumber: _policyNumberController.text.trim(),
        insurerName: _insurerNameController.text.trim(),
        tpaName: _tpaNameController.text.trim().isEmpty ? null : _tpaNameController.text.trim(),
        claimType: _claimType,
        diagnosisDetails: _diagnosisController.text.trim().isEmpty
            ? null
            : _diagnosisController.text.trim(),
        treatmentDetails: _treatmentController.text.trim().isEmpty
            ? null
            : _treatmentController.text.trim(),
        estimatedAmount: estimatedAmount,
        status: status,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    return ClaimModel.create(
      patientName: _patientNameController.text.trim(),
      patientId: _patientIdController.text.trim(),
      dateOfBirth: _dateOfBirth,
      gender: _gender,
      contactNumber: _contactNumberController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      hospitalName: _hospitalNameController.text.trim(),
      hospitalId:
          _hospitalIdController.text.trim().isEmpty ? null : _hospitalIdController.text.trim(),
      admissionDate: _admissionDate,
      dischargeDate: _dischargeDate,
      treatingDoctor: _treatingDoctorController.text.trim().isEmpty
          ? null
          : _treatingDoctorController.text.trim(),
      department: _department,
      policyNumber: _policyNumberController.text.trim(),
      insurerName: _insurerNameController.text.trim(),
      tpaName: _tpaNameController.text.trim().isEmpty ? null : _tpaNameController.text.trim(),
      claimType: _claimType,
      diagnosisDetails:
          _diagnosisController.text.trim().isEmpty ? null : _diagnosisController.text.trim(),
      treatmentDetails:
          _treatmentController.text.trim().isEmpty ? null : _treatmentController.text.trim(),
      estimatedAmount: estimatedAmount,
      status: status,
    );
  }

  Future<void> _saveDraft() async {
    final claim = _buildClaimFromForm();
    await StorageService.saveDraft(claim);
    _existingClaimId = claim.id;
    _existingClaimNumber = claim.claimNumber;
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _patientFormKey.currentState?.validate() ?? false;
      case 1:
        return _hospitalFormKey.currentState?.validate() ?? false;
      case 2:
        return _claimDetailsFormKey.currentState?.validate() ?? false;
      default:
        return true;
    }
  }

  void _onStepContinue() {
    if (_validateCurrentStep()) {
      _saveDraft();
      if (_currentStep < 3) {
        setState(() => _currentStep += 1);
      }
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  void _onStepTapped(int step) {
    if (step < _currentStep) {
      setState(() => _currentStep = step);
    } else if (step == _currentStep + 1) {
      if (_validateCurrentStep()) {
        _saveDraft();
        setState(() => _currentStep = step);
      }
    }
  }

  Future<void> _handleSaveDraft() async {
    setState(() => _isSavingDraft = true);
    try {
      final claim = _buildClaimFromForm();
      final provider = context.read<ClaimProvider>();

      if (isEditMode || _existingClaimId != null) {
        await provider.updateClaim(claim);
      } else {
        await provider.createClaim(claim);
        _existingClaimId = claim.id;
        _existingClaimNumber = claim.claimNumber;
      }

      await StorageService.clearDraft();
      if (mounted) {
        SnackbarUtils.showSuccess(context, 'Draft saved successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Failed to save draft');
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingDraft = false);
      }
    }
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);
    try {
      final claim = _buildClaimFromForm(status: ClaimStatus.submitted);
      final provider = context.read<ClaimProvider>();

      if (isEditMode || _existingClaimId != null) {
        await provider.updateClaim(claim.copyWith(
          status: ClaimStatus.submitted,
          submittedAt: DateTime.now(),
        ));
      } else {
        await provider.createClaim(claim.copyWith(
          status: ClaimStatus.submitted,
          submittedAt: DateTime.now(),
        ));
      }

      await StorageService.clearDraft();
      if (mounted) {
        SnackbarUtils.showSuccess(context, 'Claim submitted successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Failed to submit claim');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _handleCancel() async {
    final hasData = _patientNameController.text.isNotEmpty ||
        _hospitalNameController.text.isNotEmpty ||
        _policyNumberController.text.isNotEmpty;

    if (!hasData) {
      Navigator.pop(context);
      return;
    }

    final result = await ConfirmationDialog.show(
      context: context,
      title: 'Discard Changes?',
      message:
          'You have unsaved changes. Are you sure you want to discard them?',
      confirmText: 'Discard',
      cancelText: 'Keep Editing',
      type: DialogType.warning,
    );

    if (result == true && mounted) {
      await StorageService.clearDraft();
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Claim' : 'Create Claim'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _handleCancel,
        ),
        actions: [
          if (!isDesktop)
            TextButton.icon(
              onPressed: _isSavingDraft || _isSubmitting ? null : _handleSaveDraft,
              icon: const Icon(Icons.save_outlined, size: 20),
              label: const Text('Save Draft'),
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading...')
          : isDesktop
              ? _buildDesktopLayout()
              : _buildMobileLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Stepper(
      type: StepperType.vertical,
      currentStep: _currentStep,
      onStepContinue: _currentStep < 3 ? _onStepContinue : null,
      onStepCancel: _currentStep > 0 ? _onStepCancel : null,
      onStepTapped: _onStepTapped,
      controlsBuilder: (context, details) {
        if (_currentStep == 3) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: details.onStepContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Continue'),
              ),
              if (_currentStep > 0) ...[
                const SizedBox(width: 12),
                TextButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Back'),
                ),
              ],
            ],
          ),
        );
      },
      steps: _buildSteps(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 280,
          child: Card(
            margin: const EdgeInsets.all(16),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDesktopStepTile(0, 'Patient Info', Icons.person_outline),
                _buildDesktopStepTile(1, 'Hospital Details', Icons.local_hospital_outlined),
                _buildDesktopStepTile(2, 'Claim Details', Icons.description_outlined),
                _buildDesktopStepTile(3, 'Review & Submit', Icons.check_circle_outline),
              ],
            ),
          ),
        ),
        Expanded(
          child: Card(
            margin: const EdgeInsets.fromLTRB(0, 16, 16, 16),
            child: Column(
              children: [
                Expanded(child: _buildStepContent(_currentStep)),
                if (_currentStep < 3)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentStep > 0)
                          TextButton.icon(
                            onPressed: _onStepCancel,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Previous'),
                          )
                        else
                          const SizedBox.shrink(),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: _isSavingDraft ? null : _handleSaveDraft,
                              icon: const Icon(Icons.save_outlined),
                              label: const Text('Save Draft'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: _onStepContinue,
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text('Continue'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopStepTile(int index, String title, IconData icon) {
    final isActive = _currentStep == index;
    final isCompleted = _currentStep > index;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary
              : isCompleted
                  ? AppColors.success
                  : AppColors.surfaceVariant,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isCompleted ? Icons.check : icon,
          color: isActive || isCompleted ? Colors.white : AppColors.textSecondary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          color: isActive ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      selected: isActive,
      selectedTileColor: AppColors.primary.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () => _onStepTapped(index),
    );
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('Patient Info'),
        subtitle: _currentStep > 0 ? Text(_patientNameController.text) : null,
        content: _buildStepContent(0),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Hospital Details'),
        subtitle: _currentStep > 1 ? Text(_hospitalNameController.text) : null,
        content: _buildStepContent(1),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Claim Details'),
        subtitle: _currentStep > 2 ? Text(_claimType.displayName) : null,
        content: _buildStepContent(2),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Review & Submit'),
        content: _buildStepContent(3),
        isActive: _currentStep >= 3,
        state: StepState.indexed,
      ),
    ];
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return PatientInfoStep(
          formKey: _patientFormKey,
          patientNameController: _patientNameController,
          patientIdController: _patientIdController,
          contactNumberController: _contactNumberController,
          emailController: _emailController,
          addressController: _addressController,
          dateOfBirth: _dateOfBirth,
          gender: _gender,
          onDateOfBirthChanged: (date) => setState(() => _dateOfBirth = date),
          onGenderChanged: (gender) => setState(() => _gender = gender),
        );
      case 1:
        return HospitalInfoStep(
          formKey: _hospitalFormKey,
          hospitalNameController: _hospitalNameController,
          hospitalIdController: _hospitalIdController,
          treatingDoctorController: _treatingDoctorController,
          admissionDate: _admissionDate,
          dischargeDate: _dischargeDate,
          department: _department,
          onAdmissionDateChanged: (date) => setState(() => _admissionDate = date),
          onDischargeDateChanged: (date) => setState(() => _dischargeDate = date),
          onDepartmentChanged: (dept) => setState(() => _department = dept),
        );
      case 2:
        return ClaimDetailsStep(
          formKey: _claimDetailsFormKey,
          policyNumberController: _policyNumberController,
          insurerNameController: _insurerNameController,
          tpaNameController: _tpaNameController,
          diagnosisController: _diagnosisController,
          treatmentController: _treatmentController,
          estimatedAmountController: _estimatedAmountController,
          claimType: _claimType,
          onClaimTypeChanged: (type) => setState(() => _claimType = type),
        );
      case 3:
        return ReviewStep(
          patientName: _patientNameController.text,
          patientId: _patientIdController.text,
          dateOfBirth: _dateOfBirth,
          gender: _gender,
          contactNumber: _contactNumberController.text,
          email: _emailController.text.isEmpty ? null : _emailController.text,
          address: _addressController.text.isEmpty ? null : _addressController.text,
          hospitalName: _hospitalNameController.text,
          hospitalId: _hospitalIdController.text.isEmpty ? null : _hospitalIdController.text,
          admissionDate: _admissionDate,
          dischargeDate: _dischargeDate,
          treatingDoctor:
              _treatingDoctorController.text.isEmpty ? null : _treatingDoctorController.text,
          department: _department,
          policyNumber: _policyNumberController.text,
          insurerName: _insurerNameController.text,
          tpaName: _tpaNameController.text.isEmpty ? null : _tpaNameController.text,
          claimType: _claimType,
          diagnosisDetails: _diagnosisController.text.isEmpty ? null : _diagnosisController.text,
          treatmentDetails: _treatmentController.text.isEmpty ? null : _treatmentController.text,
          estimatedAmount:
              double.tryParse(_estimatedAmountController.text.replaceAll(',', '')) ?? 0.0,
          onEditStep: (step) => setState(() => _currentStep = step),
          onSaveDraft: _handleSaveDraft,
          onSubmit: _handleSubmit,
          isSubmitting: _isSubmitting,
          isSavingDraft: _isSavingDraft,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
