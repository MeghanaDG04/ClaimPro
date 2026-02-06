import 'package:flutter/foundation.dart';
import '../models/claim_model.dart';
import '../models/bill_model.dart';
import '../models/advance_model.dart';
import '../models/settlement_model.dart';
import '../core/constants/status_constants.dart';
import '../services/storage_service.dart';

class ClaimProvider extends ChangeNotifier {
  List<ClaimModel> _claims = [];
  ClaimModel? _selectedClaim;
  bool _isLoading = false;
  String? _error;

  String _searchQuery = '';
  ClaimStatus? _statusFilter;
  DateTimeRange? _dateRangeFilter;

  List<ClaimModel> get claims => _filterClaims();
  List<ClaimModel> get allClaims => _claims;
  ClaimModel? get selectedClaim => _selectedClaim;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  ClaimStatus? get statusFilter => _statusFilter;

  int get totalClaims => _claims.length;
  int get draftCount => _claims.where((c) => c.status == ClaimStatus.draft).length;
  int get submittedCount => _claims.where((c) => c.status == ClaimStatus.submitted).length;
  int get underReviewCount => _claims.where((c) => c.status == ClaimStatus.underReview).length;
  int get approvedCount => _claims.where((c) => c.status == ClaimStatus.approved).length;
  int get rejectedCount => _claims.where((c) => c.status == ClaimStatus.rejected).length;
  int get partiallySettledCount => _claims.where((c) => c.status == ClaimStatus.partiallySettled).length;
  int get fullySettledCount => _claims.where((c) => c.status == ClaimStatus.fullySettled).length;
  int get closedCount => _claims.where((c) => c.status == ClaimStatus.closed).length;

  int get pendingCount => submittedCount + underReviewCount;

  double get totalClaimValue => _claims.fold(0.0, (sum, c) => sum + c.estimatedAmount);
  double get totalApprovedValue => _claims
      .where((c) => c.approvedAmount != null)
      .fold(0.0, (sum, c) => sum + (c.approvedAmount ?? 0));
  double get totalSettledValue => _claims.fold(0.0, (sum, c) => sum + c.totalSettledAmount);

  Future<void> loadClaims() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final storedClaims = StorageService.getClaims();
      if (storedClaims.isNotEmpty) {
        _claims = storedClaims;
      } else {
        _claims = _generateSampleClaims();
        await StorageService.saveClaims(_claims);
      }
    } catch (e) {
      _error = 'Failed to load claims';
    }

    _isLoading = false;
    notifyListeners();
  }

  List<ClaimModel> _filterClaims() {
    var filtered = List<ClaimModel>.from(_claims);

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((c) =>
          c.claimNumber.toLowerCase().contains(query) ||
          c.patientName.toLowerCase().contains(query) ||
          c.hospitalName.toLowerCase().contains(query) ||
          c.policyNumber.toLowerCase().contains(query)).toList();
    }

    if (_statusFilter != null) {
      filtered = filtered.where((c) => c.status == _statusFilter).toList();
    }

    if (_dateRangeFilter != null) {
      filtered = filtered.where((c) =>
          c.createdAt.isAfter(_dateRangeFilter!.start) &&
          c.createdAt.isBefore(_dateRangeFilter!.end.add(const Duration(days: 1)))).toList();
    }

    filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return filtered;
  }

  ClaimModel? getClaimById(String id) {
    try {
      return _claims.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> createClaim(ClaimModel claim) async {
    _isLoading = true;
    notifyListeners();

    try {
      _claims.add(claim);
      await StorageService.saveClaims(_claims);
    } catch (e) {
      _error = 'Failed to create claim';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateClaim(ClaimModel claim) async {
    _isLoading = true;
    notifyListeners();

    try {
      final index = _claims.indexWhere((c) => c.id == claim.id);
      if (index != -1) {
        _claims[index] = claim.copyWith(updatedAt: DateTime.now());
        if (_selectedClaim?.id == claim.id) {
          _selectedClaim = _claims[index];
        }
        await StorageService.saveClaims(_claims);
      }
    } catch (e) {
      _error = 'Failed to update claim';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteClaim(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      _claims.removeWhere((c) => c.id == id);
      if (_selectedClaim?.id == id) {
        _selectedClaim = null;
      }
      await StorageService.saveClaims(_claims);
    } catch (e) {
      _error = 'Failed to delete claim';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> submitClaim(String id) async {
    final claim = getClaimById(id);
    if (claim == null || !claim.status.canSubmit) return;

    final updatedClaim = claim.copyWith(
      status: ClaimStatus.submitted,
      submittedAt: DateTime.now(),
    );
    await updateClaim(updatedClaim);
  }

  Future<void> approveClaim(String id, double approvedAmount) async {
    final claim = getClaimById(id);
    if (claim == null || !claim.status.canApprove) return;

    final updatedClaim = claim.copyWith(
      status: ClaimStatus.approved,
      approvedAmount: approvedAmount,
      approvedAt: DateTime.now(),
    );
    await updateClaim(updatedClaim);
  }

  Future<void> rejectClaim(String id, String reason) async {
    final claim = getClaimById(id);
    if (claim == null || !claim.status.canApprove) return;

    final updatedClaim = claim.copyWith(
      status: ClaimStatus.rejected,
    );
    await updateClaim(updatedClaim);
  }

  Future<void> addBillToClaim(String claimId, BillModel bill) async {
    final claim = getClaimById(claimId);
    if (claim == null) return;

    final updatedBills = [...claim.bills, bill];
    final updatedClaim = claim.copyWith(bills: updatedBills);
    await updateClaim(updatedClaim);
  }

  Future<void> updateBillInClaim(String claimId, BillModel bill) async {
    final claim = getClaimById(claimId);
    if (claim == null) return;

    final updatedBills = claim.bills.map((b) => b.id == bill.id ? bill : b).toList();
    final updatedClaim = claim.copyWith(bills: updatedBills);
    await updateClaim(updatedClaim);
  }

  Future<void> removeBillFromClaim(String claimId, String billId) async {
    final claim = getClaimById(claimId);
    if (claim == null) return;

    final updatedBills = claim.bills.where((b) => b.id != billId).toList();
    final updatedClaim = claim.copyWith(bills: updatedBills);
    await updateClaim(updatedClaim);
  }

  Future<void> addAdvanceToClaim(String claimId, AdvanceModel advance) async {
    final claim = getClaimById(claimId);
    if (claim == null) return;

    final updatedAdvances = [...claim.advances, advance];
    final updatedClaim = claim.copyWith(advances: updatedAdvances);
    await updateClaim(updatedClaim);
  }

  Future<void> updateAdvanceInClaim(String claimId, AdvanceModel advance) async {
    final claim = getClaimById(claimId);
    if (claim == null) return;

    final updatedAdvances = claim.advances.map((a) => a.id == advance.id ? advance : a).toList();
    final updatedClaim = claim.copyWith(advances: updatedAdvances);
    await updateClaim(updatedClaim);
  }

  Future<void> removeAdvanceFromClaim(String claimId, String advanceId) async {
    final claim = getClaimById(claimId);
    if (claim == null) return;

    final updatedAdvances = claim.advances.where((a) => a.id != advanceId).toList();
    final updatedClaim = claim.copyWith(advances: updatedAdvances);
    await updateClaim(updatedClaim);
  }

  Future<void> addSettlementToClaim(String claimId, SettlementModel settlement) async {
    final claim = getClaimById(claimId);
    if (claim == null) return;

    final updatedSettlements = [...claim.settlements, settlement];
    final newStatus = settlement.settlementType == SettlementType.final_
        ? ClaimStatus.fullySettled
        : ClaimStatus.partiallySettled;

    final updatedClaim = claim.copyWith(
      settlements: updatedSettlements,
      status: newStatus,
    );
    await updateClaim(updatedClaim);
  }

  void setSelectedClaim(ClaimModel? claim) {
    _selectedClaim = claim;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(ClaimStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setDateRangeFilter(DateTimeRange? dateRange) {
    _dateRangeFilter = dateRange;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    _dateRangeFilter = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  List<ClaimModel> _generateSampleClaims() {
    final now = DateTime.now();
    
    return [
      ClaimModel(
        id: 'claim-001',
        claimNumber: 'CLM-20250115-0001',
        patientName: 'Rajesh Kumar',
        patientId: 'PAT-001',
        dateOfBirth: DateTime(1985, 5, 15),
        gender: Gender.male,
        contactNumber: '+91 9876543210',
        email: 'rajesh.kumar@email.com',
        address: '123, MG Road, Bengaluru, Karnataka - 560001',
        hospitalName: 'Apollo Hospitals',
        hospitalId: 'HOSP-001',
        admissionDate: now.subtract(const Duration(days: 10)),
        dischargeDate: now.subtract(const Duration(days: 5)),
        treatingDoctor: 'Dr. Sharma',
        department: 'Cardiology',
        policyNumber: 'POL-2024-001234',
        insurerName: 'HDFC ERGO',
        tpaName: 'Medi Assist',
        claimType: ClaimType.cashless,
        diagnosisDetails: 'Coronary Artery Disease',
        treatmentDetails: 'Angioplasty with stent placement',
        estimatedAmount: 450000,
        approvedAmount: 425000,
        status: ClaimStatus.approved,
        bills: [
          BillModel(
            id: 'bill-001',
            claimId: 'claim-001',
            billNumber: 'BILL-001',
            billDate: now.subtract(const Duration(days: 5)),
            billType: BillType.hospitalCharges,
            description: 'Room charges - Deluxe (5 days)',
            amount: 75000,
            approvedAmount: 75000,
            status: BillStatus.approved,
            createdAt: now.subtract(const Duration(days: 5)),
            updatedAt: now.subtract(const Duration(days: 5)),
          ),
          BillModel(
            id: 'bill-002',
            claimId: 'claim-001',
            billNumber: 'BILL-002',
            billDate: now.subtract(const Duration(days: 5)),
            billType: BillType.surgeryCharges,
            description: 'Angioplasty procedure charges',
            amount: 300000,
            approvedAmount: 280000,
            status: BillStatus.approved,
            createdAt: now.subtract(const Duration(days: 5)),
            updatedAt: now.subtract(const Duration(days: 5)),
          ),
          BillModel(
            id: 'bill-003',
            claimId: 'claim-001',
            billNumber: 'BILL-003',
            billDate: now.subtract(const Duration(days: 5)),
            billType: BillType.medicines,
            description: 'Medicines and consumables',
            amount: 50000,
            approvedAmount: 45000,
            status: BillStatus.approved,
            createdAt: now.subtract(const Duration(days: 5)),
            updatedAt: now.subtract(const Duration(days: 5)),
          ),
        ],
        advances: [
          AdvanceModel(
            id: 'adv-001',
            claimId: 'claim-001',
            advanceNumber: 'ADV-20250110-0001',
            advanceDate: now.subtract(const Duration(days: 10)),
            amount: 100000,
            paymentMode: PaymentMode.bankTransfer,
            referenceNumber: 'TXN123456',
            paidTo: 'Apollo Hospitals',
            status: AdvanceStatus.disbursed,
            createdAt: now.subtract(const Duration(days: 10)),
            updatedAt: now.subtract(const Duration(days: 10)),
          ),
        ],
        settlements: [],
        createdAt: now.subtract(const Duration(days: 12)),
        updatedAt: now.subtract(const Duration(days: 2)),
        submittedAt: now.subtract(const Duration(days: 10)),
        approvedAt: now.subtract(const Duration(days: 3)),
      ),
      ClaimModel(
        id: 'claim-002',
        claimNumber: 'CLM-20250118-0002',
        patientName: 'Priya Sharma',
        patientId: 'PAT-002',
        dateOfBirth: DateTime(1990, 8, 22),
        gender: Gender.female,
        contactNumber: '+91 9988776655',
        email: 'priya.sharma@email.com',
        address: '456, Park Street, Mumbai, Maharashtra - 400001',
        hospitalName: 'Fortis Hospital',
        hospitalId: 'HOSP-002',
        admissionDate: now.subtract(const Duration(days: 5)),
        dischargeDate: null,
        treatingDoctor: 'Dr. Patel',
        department: 'Orthopedics',
        policyNumber: 'POL-2024-002345',
        insurerName: 'ICICI Lombard',
        tpaName: 'Health India TPA',
        claimType: ClaimType.cashless,
        diagnosisDetails: 'Knee Replacement Surgery',
        treatmentDetails: 'Total Knee Replacement',
        estimatedAmount: 350000,
        status: ClaimStatus.underReview,
        bills: [
          BillModel(
            id: 'bill-004',
            claimId: 'claim-002',
            billNumber: 'BILL-004',
            billDate: now.subtract(const Duration(days: 3)),
            billType: BillType.surgeryCharges,
            description: 'Knee replacement surgery',
            amount: 250000,
            status: BillStatus.pending,
            createdAt: now.subtract(const Duration(days: 3)),
            updatedAt: now.subtract(const Duration(days: 3)),
          ),
          BillModel(
            id: 'bill-005',
            claimId: 'claim-002',
            billNumber: 'BILL-005',
            billDate: now.subtract(const Duration(days: 2)),
            billType: BillType.roomCharges,
            description: 'Room charges - Semi-private',
            amount: 60000,
            status: BillStatus.pending,
            createdAt: now.subtract(const Duration(days: 2)),
            updatedAt: now.subtract(const Duration(days: 2)),
          ),
        ],
        advances: [
          AdvanceModel(
            id: 'adv-002',
            claimId: 'claim-002',
            advanceNumber: 'ADV-20250118-0001',
            advanceDate: now.subtract(const Duration(days: 5)),
            amount: 150000,
            paymentMode: PaymentMode.bankTransfer,
            referenceNumber: 'TXN789012',
            paidTo: 'Fortis Hospital',
            status: AdvanceStatus.disbursed,
            createdAt: now.subtract(const Duration(days: 5)),
            updatedAt: now.subtract(const Duration(days: 5)),
          ),
        ],
        settlements: [],
        createdAt: now.subtract(const Duration(days: 6)),
        updatedAt: now.subtract(const Duration(days: 1)),
        submittedAt: now.subtract(const Duration(days: 4)),
      ),
      ClaimModel(
        id: 'claim-003',
        claimNumber: 'CLM-20250120-0003',
        patientName: 'Amit Verma',
        patientId: 'PAT-003',
        dateOfBirth: DateTime(1978, 3, 10),
        gender: Gender.male,
        contactNumber: '+91 8877665544',
        email: 'amit.verma@email.com',
        address: '789, Civil Lines, Delhi - 110001',
        hospitalName: 'Max Super Speciality',
        hospitalId: 'HOSP-003',
        admissionDate: now.subtract(const Duration(days: 20)),
        dischargeDate: now.subtract(const Duration(days: 15)),
        treatingDoctor: 'Dr. Gupta',
        department: 'Gastroenterology',
        policyNumber: 'POL-2024-003456',
        insurerName: 'Star Health',
        tpaName: 'Paramount Health Services',
        claimType: ClaimType.reimbursement,
        diagnosisDetails: 'Gallbladder Stones',
        treatmentDetails: 'Laparoscopic Cholecystectomy',
        estimatedAmount: 180000,
        approvedAmount: 170000,
        status: ClaimStatus.partiallySettled,
        bills: [
          BillModel(
            id: 'bill-006',
            claimId: 'claim-003',
            billNumber: 'BILL-006',
            billDate: now.subtract(const Duration(days: 15)),
            billType: BillType.surgeryCharges,
            description: 'Laparoscopic surgery',
            amount: 120000,
            approvedAmount: 115000,
            status: BillStatus.approved,
            createdAt: now.subtract(const Duration(days: 15)),
            updatedAt: now.subtract(const Duration(days: 10)),
          ),
          BillModel(
            id: 'bill-007',
            claimId: 'claim-003',
            billNumber: 'BILL-007',
            billDate: now.subtract(const Duration(days: 15)),
            billType: BillType.roomCharges,
            description: 'Room charges (5 days)',
            amount: 40000,
            approvedAmount: 38000,
            status: BillStatus.approved,
            createdAt: now.subtract(const Duration(days: 15)),
            updatedAt: now.subtract(const Duration(days: 10)),
          ),
        ],
        advances: [],
        settlements: [
          SettlementModel(
            id: 'stl-001',
            claimId: 'claim-003',
            settlementNumber: 'STL-20250125-0001',
            settlementDate: now.subtract(const Duration(days: 5)),
            settledAmount: 100000,
            settlementType: SettlementType.partial,
            paymentMode: PaymentMode.bankTransfer,
            referenceNumber: 'NEFT123456',
            deductions: 5000,
            deductionRemarks: 'Non-payable items',
            remarks: 'First partial settlement',
            settledBy: 'Claims Manager',
            createdAt: now.subtract(const Duration(days: 5)),
          ),
        ],
        createdAt: now.subtract(const Duration(days: 22)),
        updatedAt: now.subtract(const Duration(days: 5)),
        submittedAt: now.subtract(const Duration(days: 18)),
        approvedAt: now.subtract(const Duration(days: 10)),
      ),
      ClaimModel(
        id: 'claim-004',
        claimNumber: 'CLM-20250122-0004',
        patientName: 'Sneha Reddy',
        patientId: 'PAT-004',
        dateOfBirth: DateTime(1995, 11, 5),
        gender: Gender.female,
        contactNumber: '+91 7766554433',
        email: 'sneha.reddy@email.com',
        address: '321, Jubilee Hills, Hyderabad, Telangana - 500033',
        hospitalName: 'KIMS Hospital',
        hospitalId: 'HOSP-004',
        admissionDate: now.subtract(const Duration(days: 3)),
        dischargeDate: null,
        treatingDoctor: 'Dr. Rao',
        department: 'General Medicine',
        policyNumber: 'POL-2024-004567',
        insurerName: 'New India Assurance',
        tpaName: 'Vidal Health',
        claimType: ClaimType.cashless,
        diagnosisDetails: 'Dengue Fever',
        treatmentDetails: 'Supportive treatment and monitoring',
        estimatedAmount: 75000,
        status: ClaimStatus.submitted,
        bills: [
          BillModel(
            id: 'bill-008',
            claimId: 'claim-004',
            billNumber: 'BILL-008',
            billDate: now.subtract(const Duration(days: 1)),
            billType: BillType.roomCharges,
            description: 'ICU charges (3 days)',
            amount: 45000,
            status: BillStatus.pending,
            createdAt: now.subtract(const Duration(days: 1)),
            updatedAt: now.subtract(const Duration(days: 1)),
          ),
          BillModel(
            id: 'bill-009',
            claimId: 'claim-004',
            billNumber: 'BILL-009',
            billDate: now.subtract(const Duration(days: 1)),
            billType: BillType.diagnostics,
            description: 'Blood tests and diagnostics',
            amount: 15000,
            status: BillStatus.pending,
            createdAt: now.subtract(const Duration(days: 1)),
            updatedAt: now.subtract(const Duration(days: 1)),
          ),
        ],
        advances: [],
        settlements: [],
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 1)),
        submittedAt: now.subtract(const Duration(days: 2)),
      ),
      ClaimModel(
        id: 'claim-005',
        claimNumber: 'CLM-20250125-0005',
        patientName: 'Vikram Singh',
        patientId: 'PAT-005',
        dateOfBirth: DateTime(1982, 7, 20),
        gender: Gender.male,
        contactNumber: '+91 9988001122',
        email: 'vikram.singh@email.com',
        address: '555, Sector 18, Noida, UP - 201301',
        hospitalName: 'Medanta Hospital',
        hospitalId: 'HOSP-005',
        admissionDate: now,
        treatingDoctor: 'Dr. Kapoor',
        department: 'Neurology',
        policyNumber: 'POL-2024-005678',
        insurerName: 'Bajaj Allianz',
        claimType: ClaimType.cashless,
        diagnosisDetails: 'Migraine - Chronic',
        treatmentDetails: 'Investigation and treatment',
        estimatedAmount: 50000,
        status: ClaimStatus.draft,
        bills: [],
        advances: [],
        settlements: [],
        createdAt: now,
        updatedAt: now,
      ),
      ClaimModel(
        id: 'claim-006',
        claimNumber: 'CLM-20250101-0006',
        patientName: 'Meera Joshi',
        patientId: 'PAT-006',
        dateOfBirth: DateTime(1970, 2, 14),
        gender: Gender.female,
        contactNumber: '+91 8899776655',
        email: 'meera.joshi@email.com',
        address: '888, FC Road, Pune, Maharashtra - 411004',
        hospitalName: 'Ruby Hall Clinic',
        hospitalId: 'HOSP-006',
        admissionDate: now.subtract(const Duration(days: 45)),
        dischargeDate: now.subtract(const Duration(days: 40)),
        treatingDoctor: 'Dr. Deshmukh',
        department: 'Oncology',
        policyNumber: 'POL-2024-006789',
        insurerName: 'Tata AIG',
        tpaName: 'MD India',
        claimType: ClaimType.reimbursement,
        diagnosisDetails: 'Breast Cancer - Stage 1',
        treatmentDetails: 'Mastectomy and chemotherapy initiation',
        estimatedAmount: 550000,
        approvedAmount: 520000,
        status: ClaimStatus.fullySettled,
        bills: [
          BillModel(
            id: 'bill-010',
            claimId: 'claim-006',
            billNumber: 'BILL-010',
            billDate: now.subtract(const Duration(days: 40)),
            billType: BillType.surgeryCharges,
            description: 'Mastectomy surgery',
            amount: 350000,
            approvedAmount: 340000,
            status: BillStatus.approved,
            createdAt: now.subtract(const Duration(days: 40)),
            updatedAt: now.subtract(const Duration(days: 30)),
          ),
          BillModel(
            id: 'bill-011',
            claimId: 'claim-006',
            billNumber: 'BILL-011',
            billDate: now.subtract(const Duration(days: 40)),
            billType: BillType.roomCharges,
            description: 'Room charges (5 days)',
            amount: 75000,
            approvedAmount: 70000,
            status: BillStatus.approved,
            createdAt: now.subtract(const Duration(days: 40)),
            updatedAt: now.subtract(const Duration(days: 30)),
          ),
          BillModel(
            id: 'bill-012',
            claimId: 'claim-006',
            billNumber: 'BILL-012',
            billDate: now.subtract(const Duration(days: 38)),
            billType: BillType.medicines,
            description: 'Chemotherapy medicines',
            amount: 100000,
            approvedAmount: 95000,
            status: BillStatus.approved,
            createdAt: now.subtract(const Duration(days: 38)),
            updatedAt: now.subtract(const Duration(days: 30)),
          ),
        ],
        advances: [
          AdvanceModel(
            id: 'adv-003',
            claimId: 'claim-006',
            advanceNumber: 'ADV-20250101-0001',
            advanceDate: now.subtract(const Duration(days: 45)),
            amount: 200000,
            paymentMode: PaymentMode.bankTransfer,
            referenceNumber: 'TXN456789',
            paidTo: 'Ruby Hall Clinic',
            status: AdvanceStatus.adjusted,
            createdAt: now.subtract(const Duration(days: 45)),
            updatedAt: now.subtract(const Duration(days: 20)),
          ),
        ],
        settlements: [
          SettlementModel(
            id: 'stl-002',
            claimId: 'claim-006',
            settlementNumber: 'STL-20250115-0001',
            settlementDate: now.subtract(const Duration(days: 20)),
            settledAmount: 320000,
            settlementType: SettlementType.final_,
            paymentMode: PaymentMode.bankTransfer,
            referenceNumber: 'NEFT789012',
            deductions: 15000,
            deductionRemarks: 'Policy excess and non-payable items',
            remarks: 'Final settlement after advance adjustment',
            settledBy: 'Senior Claims Manager',
            createdAt: now.subtract(const Duration(days: 20)),
          ),
        ],
        createdAt: now.subtract(const Duration(days: 48)),
        updatedAt: now.subtract(const Duration(days: 20)),
        submittedAt: now.subtract(const Duration(days: 42)),
        approvedAt: now.subtract(const Duration(days: 30)),
      ),
    ];
  }
}

class DateTimeRange {
  final DateTime start;
  final DateTime end;

  DateTimeRange({required this.start, required this.end});
}
