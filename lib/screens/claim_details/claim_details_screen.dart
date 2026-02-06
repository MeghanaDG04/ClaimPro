import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/claim_provider.dart';
import '../../models/claim_model.dart';
import '../../models/bill_model.dart';
import '../../models/advance_model.dart';
import '../../models/settlement_model.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/calculation_utils.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/theme/color_scheme.dart';
import '../../core/constants/status_constants.dart';
import '../../widgets/claim_timeline.dart';
import '../../widgets/financial_summary_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart' as app_widgets;
import 'info_section.dart';
import 'claim_actions.dart';

class ClaimDetailsScreen extends StatefulWidget {
  final String claimId;

  const ClaimDetailsScreen({
    super.key,
    required this.claimId,
  });

  @override
  State<ClaimDetailsScreen> createState() => _ClaimDetailsScreenState();
}

class _ClaimDetailsScreenState extends State<ClaimDetailsScreen> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadClaim();
  }

  Future<void> _loadClaim() async {
    final provider = context.read<ClaimProvider>();
    if (provider.allClaims.isEmpty) {
      await provider.loadClaims();
    }
  }

  Future<void> _refreshClaim() async {
    setState(() => _isRefreshing = true);
    await context.read<ClaimProvider>().loadClaims();
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClaimProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && !_isRefreshing) {
          return Scaffold(
            appBar: AppBar(title: const Text('Claim Details')),
            body: const LoadingWidget(message: 'Loading claim details...'),
          );
        }

        final claim = provider.getClaimById(widget.claimId);

        if (claim == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Claim Details')),
            body: app_widgets.AppErrorWidget(
              message: 'Claim not found',
              onRetry: _loadClaim,
            ),
          );
        }

        return Scaffold(
          appBar: _buildAppBar(claim),
          body: RefreshIndicator(
            onRefresh: _refreshClaim,
            child: _buildBody(claim),
          ),
          floatingActionButton: _buildFloatingActionButtons(claim),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(ClaimModel claim) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            claim.claimNumber,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            claim.patientName,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (action) => ClaimActions.handleMenuAction(
            context: context,
            action: action,
            claim: claim,
          ),
          itemBuilder: (context) => ClaimActions.buildActionMenuItems(claim),
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }

  Widget _buildBody(ClaimModel claim) {
    final isDesktop = ResponsiveUtils.isDesktop(context);
    final padding = ResponsiveUtils.responsivePadding(context);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: padding,
      child: isDesktop
          ? _buildDesktopLayout(claim)
          : _buildMobileLayout(claim),
    );
  }

  Widget _buildMobileLayout(ClaimModel claim) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStatusHeader(claim),
        const SizedBox(height: 16),
        _buildPatientInfoSection(claim),
        const SizedBox(height: 16),
        _buildHospitalInfoSection(claim),
        const SizedBox(height: 16),
        _buildPolicyClaimInfoSection(claim),
        const SizedBox(height: 16),
        _buildFinancialSummary(claim),
        const SizedBox(height: 16),
        _buildBillsSection(claim),
        const SizedBox(height: 16),
        _buildAdvancesSection(claim),
        const SizedBox(height: 16),
        _buildSettlementsSection(claim),
        const SizedBox(height: 16),
        _buildClaimTimelineSection(claim),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildDesktopLayout(ClaimModel claim) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStatusHeader(claim),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildPatientInfoSection(claim),
                  const SizedBox(height: 16),
                  _buildHospitalInfoSection(claim),
                  const SizedBox(height: 16),
                  _buildBillsSection(claim),
                  const SizedBox(height: 16),
                  _buildAdvancesSection(claim),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                children: [
                  _buildPolicyClaimInfoSection(claim),
                  const SizedBox(height: 16),
                  _buildFinancialSummary(claim),
                  const SizedBox(height: 16),
                  _buildSettlementsSection(claim),
                  const SizedBox(height: 16),
                  _buildClaimTimelineSection(claim),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildStatusHeader(ClaimModel claim) {
    return FadeInDown(
      duration: const Duration(milliseconds: 400),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              claim.status.color.withOpacity(0.1),
              claim.status.color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: claim.status.color.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StatusBadge.claim(
                  status: claim.status,
                  size: BadgeSize.large,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClaimTimeline.fromStatus(claim.status),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfoSection(ClaimModel claim) {
    return InfoSection(
      title: 'Patient Information',
      icon: Icons.person_outline,
      headerColor: AppColors.info,
      showEditButton: claim.status.canEdit,
      onEdit: () => ClaimActions.editClaim(context: context, claim: claim),
      items: [
        InfoItem(label: 'Patient Name', value: claim.patientName, isBold: true),
        InfoItem(label: 'Patient ID', value: claim.patientId),
        InfoItem(
          label: 'Date of Birth',
          value: AppDateUtils.formatToDisplay(claim.dateOfBirth),
        ),
        if (claim.dateOfBirth != null)
          InfoItem(
            label: 'Age',
            value: AppDateUtils.getAgeString(claim.dateOfBirth),
          ),
        InfoItem(label: 'Gender', value: claim.gender.displayName),
        InfoItem(label: 'Contact', value: claim.contactNumber),
        if (claim.email != null && claim.email!.isNotEmpty)
          InfoItem(label: 'Email', value: claim.email!),
        if (claim.address != null && claim.address!.isNotEmpty)
          InfoItem(label: 'Address', value: claim.address!),
      ],
    );
  }

  Widget _buildHospitalInfoSection(ClaimModel claim) {
    return InfoSection(
      title: 'Hospital Information',
      icon: Icons.local_hospital_outlined,
      headerColor: AppColors.secondary,
      showEditButton: claim.status.canEdit,
      onEdit: () => ClaimActions.editClaim(context: context, claim: claim),
      items: [
        InfoItem(label: 'Hospital Name', value: claim.hospitalName, isBold: true),
        if (claim.hospitalId != null && claim.hospitalId!.isNotEmpty)
          InfoItem(label: 'Hospital ID', value: claim.hospitalId!),
        InfoItem(
          label: 'Admission Date',
          value: AppDateUtils.formatToDisplay(claim.admissionDate),
        ),
        InfoItem(
          label: 'Discharge Date',
          value: claim.dischargeDate != null
              ? AppDateUtils.formatToDisplay(claim.dischargeDate)
              : 'Ongoing',
          valueColor:
              claim.dischargeDate == null ? AppColors.warning : null,
        ),
        if (claim.treatingDoctor != null && claim.treatingDoctor!.isNotEmpty)
          InfoItem(label: 'Treating Doctor', value: claim.treatingDoctor!),
        if (claim.department != null && claim.department!.isNotEmpty)
          InfoItem(label: 'Department', value: claim.department!),
        if (claim.diagnosisDetails != null &&
            claim.diagnosisDetails!.isNotEmpty)
          InfoItem(label: 'Diagnosis', value: claim.diagnosisDetails!),
        if (claim.treatmentDetails != null &&
            claim.treatmentDetails!.isNotEmpty)
          InfoItem(label: 'Treatment', value: claim.treatmentDetails!),
      ],
    );
  }

  Widget _buildPolicyClaimInfoSection(ClaimModel claim) {
    return InfoSection(
      title: 'Policy & Claim Information',
      icon: Icons.policy_outlined,
      headerColor: AppColors.accent,
      showEditButton: claim.status.canEdit,
      onEdit: () => ClaimActions.editClaim(context: context, claim: claim),
      items: [
        InfoItem(label: 'Claim Number', value: claim.claimNumber, isBold: true),
        InfoItem(label: 'Policy Number', value: claim.policyNumber),
        InfoItem(label: 'Insurer', value: claim.insurerName),
        if (claim.tpaName != null && claim.tpaName!.isNotEmpty)
          InfoItem(label: 'TPA', value: claim.tpaName!),
        InfoItem(label: 'Claim Type', value: claim.claimType.displayName),
        InfoItem(
          label: 'Estimated Amount',
          value: CalculationUtils.formatCurrency(claim.estimatedAmount),
          valueColor: AppColors.info,
        ),
        if (claim.approvedAmount != null)
          InfoItem(
            label: 'Approved Amount',
            value: CalculationUtils.formatCurrency(claim.approvedAmount),
            valueColor: AppColors.success,
            isBold: true,
          ),
        InfoItem(
          label: 'Created',
          value: AppDateUtils.formatDateTime(claim.createdAt),
        ),
        if (claim.submittedAt != null)
          InfoItem(
            label: 'Submitted',
            value: AppDateUtils.formatDateTime(claim.submittedAt),
          ),
        if (claim.approvedAt != null)
          InfoItem(
            label: 'Approved',
            value: AppDateUtils.formatDateTime(claim.approvedAt),
          ),
      ],
    );
  }

  Widget _buildFinancialSummary(ClaimModel claim) {
    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      child: FinancialSummaryCard.fromAmounts(
        title: 'Financial Summary',
        totalBills: claim.totalBillAmount,
        totalAdvances: claim.totalAdvanceAmount,
        totalSettlements: claim.totalSettledAmount,
        approvedAmount: claim.approvedAmount,
      ),
    );
  }

  Widget _buildBillsSection(ClaimModel claim) {
    return CollapsibleListSection<BillModel>(
      title: 'Bills',
      icon: Icons.receipt_long_outlined,
      items: claim.bills,
      headerColor: AppColors.info,
      initiallyExpanded: false,
      emptyMessage: 'No bills added yet',
      onAdd: claim.status.canEdit
          ? () => ClaimActions.navigateToAddBill(context: context, claim: claim)
          : null,
      addButtonLabel: 'Add Bill',
      itemBuilder: (bill, index) => _buildBillCard(bill),
    );
  }

  Widget _buildBillCard(BillModel bill) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  bill.billNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              StatusBadge.bill(
                status: bill.status,
                size: BadgeSize.small,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            bill.description,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                bill.billType.displayName,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
              ),
              Text(
                CalculationUtils.formatCurrency(bill.amount),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (bill.approvedAmount != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Approved',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
                Text(
                  CalculationUtils.formatCurrency(bill.approvedAmount),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdvancesSection(ClaimModel claim) {
    return CollapsibleListSection<AdvanceModel>(
      title: 'Advances',
      icon: Icons.account_balance_wallet_outlined,
      items: claim.advances,
      headerColor: AppColors.warning,
      initiallyExpanded: false,
      emptyMessage: 'No advances recorded',
      onAdd: claim.status.canEdit
          ? () =>
              ClaimActions.navigateToAddAdvance(context: context, claim: claim)
          : null,
      addButtonLabel: 'Add Advance',
      itemBuilder: (advance, index) => _buildAdvanceCard(advance),
    );
  }

  Widget _buildAdvanceCard(AdvanceModel advance) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  advance.advanceNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              StatusBadge.advance(
                status: advance.status,
                size: BadgeSize.small,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppDateUtils.formatToDisplay(advance.advanceDate),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
              ),
              Text(
                CalculationUtils.formatCurrency(advance.amount),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Paid to: ${advance.paidTo}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                advance.paymentMode.displayName,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementsSection(ClaimModel claim) {
    return CollapsibleListSection<SettlementModel>(
      title: 'Settlements',
      icon: Icons.payments_outlined,
      items: claim.settlements,
      headerColor: AppColors.success,
      initiallyExpanded: false,
      emptyMessage: 'No settlements recorded',
      onAdd: claim.status.canSettle
          ? () => ClaimActions.navigateToAddSettlement(
              context: context, claim: claim)
          : null,
      addButtonLabel: 'Add Settlement',
      itemBuilder: (settlement, index) => _buildSettlementCard(settlement),
    );
  }

  Widget _buildSettlementCard(SettlementModel settlement) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  settlement.settlementNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: settlement.settlementType == SettlementType.final_
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  settlement.settlementType.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: settlement.settlementType == SettlementType.final_
                        ? AppColors.success
                        : AppColors.info,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppDateUtils.formatToDisplay(settlement.settlementDate),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
              ),
              Text(
                CalculationUtils.formatCurrency(settlement.netAmount),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          if (settlement.deductions > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Deductions: ${CalculationUtils.formatCurrency(settlement.deductions)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.error,
                  ),
                ),
                Text(
                  settlement.paymentMode.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ],
          if (settlement.remarks != null && settlement.remarks!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              settlement.remarks!,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildClaimTimelineSection(ClaimModel claim) {
    final events = _buildTimelineEvents(claim);

    return InfoSection(
      title: 'Claim Timeline',
      icon: Icons.timeline_outlined,
      headerColor: AppColors.primary,
      initiallyExpanded: false,
      items: [],
    );
  }

  List<TimelineEvent> _buildTimelineEvents(ClaimModel claim) {
    final events = <TimelineEvent>[];

    events.add(TimelineEvent(
      status: ClaimStatus.draft,
      timestamp: claim.createdAt,
      description: 'Claim created',
      isCompleted: true,
    ));

    if (claim.submittedAt != null) {
      events.add(TimelineEvent(
        status: ClaimStatus.submitted,
        timestamp: claim.submittedAt,
        description: 'Claim submitted for review',
        isCompleted: true,
      ));
    }

    if (claim.approvedAt != null) {
      events.add(TimelineEvent(
        status: ClaimStatus.approved,
        timestamp: claim.approvedAt,
        description:
            'Claim approved for ${CalculationUtils.formatCurrency(claim.approvedAmount)}',
        isCompleted: true,
      ));
    }

    for (final settlement in claim.settlements) {
      events.add(TimelineEvent(
        status: ClaimStatus.partiallySettled,
        timestamp: settlement.createdAt,
        description:
            'Settlement of ${CalculationUtils.formatCurrency(settlement.netAmount)}',
        isCompleted: true,
      ));
    }

    return events;
  }

  Widget? _buildFloatingActionButtons(ClaimModel claim) {
    final actions = <Widget>[];

    if (claim.status == ClaimStatus.draft) {
      actions.add(
        FloatingActionButton.extended(
          heroTag: 'edit',
          onPressed: () =>
              ClaimActions.editClaim(context: context, claim: claim),
          icon: const Icon(Icons.edit),
          label: const Text('Edit'),
          backgroundColor: AppColors.primary,
        ),
      );
      actions.add(const SizedBox(width: 12));
      actions.add(
        FloatingActionButton.extended(
          heroTag: 'submit',
          onPressed: () =>
              ClaimActions.submitClaim(context: context, claim: claim),
          icon: const Icon(Icons.send),
          label: const Text('Submit'),
          backgroundColor: AppColors.success,
        ),
      );
    }

    if (claim.status == ClaimStatus.approved ||
        claim.status == ClaimStatus.partiallySettled) {
      actions.add(
        FloatingActionButton.extended(
          heroTag: 'settlement',
          onPressed: () =>
              ClaimActions.navigateToAddSettlement(context: context, claim: claim),
          icon: const Icon(Icons.payments),
          label: const Text('Add Settlement'),
          backgroundColor: AppColors.success,
        ),
      );
    }

    if (actions.isEmpty) return null;

    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      child: Padding(
        padding: const EdgeInsets.only(left: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: actions,
        ),
      ),
    );
  }
}
