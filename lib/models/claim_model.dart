import 'package:uuid/uuid.dart';
import 'bill_model.dart';
import 'advance_model.dart';
import 'settlement_model.dart';
import '../core/constants/status_constants.dart';

enum ClaimType {
  cashless,
  reimbursement,
}

extension ClaimTypeExtension on ClaimType {
  String get displayName {
    switch (this) {
      case ClaimType.cashless:
        return 'Cashless';
      case ClaimType.reimbursement:
        return 'Reimbursement';
    }
  }

  String toApiValue() {
    return name.toUpperCase();
  }

  static ClaimType fromApiValue(String value) {
    return ClaimType.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => ClaimType.cashless,
    );
  }
}

enum Gender {
  male,
  female,
  other,
}

extension GenderExtension on Gender {
  String get displayName {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }

  String toApiValue() {
    return name.toUpperCase();
  }

  static Gender fromApiValue(String value) {
    return Gender.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => Gender.other,
    );
  }
}

class ClaimModel {
  final String id;
  final String claimNumber;
  
  // Patient info
  final String patientName;
  final String patientId;
  final DateTime? dateOfBirth;
  final Gender gender;
  final String contactNumber;
  final String? email;
  final String? address;
  
  // Hospital info
  final String hospitalName;
  final String? hospitalId;
  final DateTime admissionDate;
  final DateTime? dischargeDate;
  final String? treatingDoctor;
  final String? department;
  
  // Claim metadata
  final String policyNumber;
  final String insurerName;
  final String? tpaName;
  final ClaimType claimType;
  final String? diagnosisDetails;
  final String? treatmentDetails;
  
  // Amounts
  final double estimatedAmount;
  final double? approvedAmount;
  
  // Status
  final ClaimStatus status;
  
  // Related entities
  final List<BillModel> bills;
  final List<AdvanceModel> advances;
  final List<SettlementModel> settlements;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? submittedAt;
  final DateTime? approvedAt;

  const ClaimModel({
    required this.id,
    required this.claimNumber,
    required this.patientName,
    required this.patientId,
    this.dateOfBirth,
    required this.gender,
    required this.contactNumber,
    this.email,
    this.address,
    required this.hospitalName,
    this.hospitalId,
    required this.admissionDate,
    this.dischargeDate,
    this.treatingDoctor,
    this.department,
    required this.policyNumber,
    required this.insurerName,
    this.tpaName,
    required this.claimType,
    this.diagnosisDetails,
    this.treatmentDetails,
    required this.estimatedAmount,
    this.approvedAmount,
    required this.status,
    this.bills = const [],
    this.advances = const [],
    this.settlements = const [],
    required this.createdAt,
    required this.updatedAt,
    this.submittedAt,
    this.approvedAt,
  });

  // Computed getters
  bool get isDraft => status == ClaimStatus.draft;

  double get totalBillAmount {
    if (bills.isEmpty) return 0.0;
    return bills.fold(0.0, (sum, bill) => sum + bill.amount);
  }

  double get totalAdvanceAmount {
    if (advances.isEmpty) return 0.0;
    return advances
        .where((adv) => adv.status == AdvanceStatus.disbursed || adv.status == AdvanceStatus.adjusted)
        .fold(0.0, (sum, adv) => sum + adv.amount);
  }

  double get totalSettledAmount {
    if (settlements.isEmpty) return 0.0;
    return settlements.fold(0.0, (sum, stl) => sum + stl.netAmount);
  }

  double get pendingAmount {
    final approved = approvedAmount ?? estimatedAmount;
    return approved - totalSettledAmount;
  }

  double get balanceAmount {
    return totalBillAmount - totalAdvanceAmount - totalSettledAmount;
  }

  static String _generateClaimNumber() {
    final now = DateTime.now();
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final randomSuffix = now.millisecondsSinceEpoch.toString().substring(7).padLeft(4, '0');
    return 'CLM-$dateStr-$randomSuffix';
  }

  factory ClaimModel.create({
    String? claimNumber,
    required String patientName,
    required String patientId,
    DateTime? dateOfBirth,
    required Gender gender,
    required String contactNumber,
    String? email,
    String? address,
    required String hospitalName,
    String? hospitalId,
    required DateTime admissionDate,
    DateTime? dischargeDate,
    String? treatingDoctor,
    String? department,
    required String policyNumber,
    required String insurerName,
    String? tpaName,
    required ClaimType claimType,
    String? diagnosisDetails,
    String? treatmentDetails,
    required double estimatedAmount,
    double? approvedAmount,
    ClaimStatus status = ClaimStatus.draft,
    List<BillModel>? bills,
    List<AdvanceModel>? advances,
    List<SettlementModel>? settlements,
  }) {
    final now = DateTime.now();
    return ClaimModel(
      id: const Uuid().v4(),
      claimNumber: claimNumber ?? _generateClaimNumber(),
      patientName: patientName,
      patientId: patientId,
      dateOfBirth: dateOfBirth,
      gender: gender,
      contactNumber: contactNumber,
      email: email,
      address: address,
      hospitalName: hospitalName,
      hospitalId: hospitalId,
      admissionDate: admissionDate,
      dischargeDate: dischargeDate,
      treatingDoctor: treatingDoctor,
      department: department,
      policyNumber: policyNumber,
      insurerName: insurerName,
      tpaName: tpaName,
      claimType: claimType,
      diagnosisDetails: diagnosisDetails,
      treatmentDetails: treatmentDetails,
      estimatedAmount: estimatedAmount,
      approvedAmount: approvedAmount,
      status: status,
      bills: bills ?? [],
      advances: advances ?? [],
      settlements: settlements ?? [],
      createdAt: now,
      updatedAt: now,
      submittedAt: null,
      approvedAt: null,
    );
  }

  factory ClaimModel.empty() {
    final now = DateTime.now();
    return ClaimModel(
      id: const Uuid().v4(),
      claimNumber: _generateClaimNumber(),
      patientName: '',
      patientId: '',
      dateOfBirth: null,
      gender: Gender.male,
      contactNumber: '',
      email: null,
      address: null,
      hospitalName: '',
      hospitalId: null,
      admissionDate: now,
      dischargeDate: null,
      treatingDoctor: null,
      department: null,
      policyNumber: '',
      insurerName: '',
      tpaName: null,
      claimType: ClaimType.cashless,
      diagnosisDetails: null,
      treatmentDetails: null,
      estimatedAmount: 0.0,
      approvedAmount: null,
      status: ClaimStatus.draft,
      bills: [],
      advances: [],
      settlements: [],
      createdAt: now,
      updatedAt: now,
      submittedAt: null,
      approvedAt: null,
    );
  }

  ClaimModel copyWith({
    String? id,
    String? claimNumber,
    String? patientName,
    String? patientId,
    DateTime? dateOfBirth,
    Gender? gender,
    String? contactNumber,
    String? email,
    String? address,
    String? hospitalName,
    String? hospitalId,
    DateTime? admissionDate,
    DateTime? dischargeDate,
    String? treatingDoctor,
    String? department,
    String? policyNumber,
    String? insurerName,
    String? tpaName,
    ClaimType? claimType,
    String? diagnosisDetails,
    String? treatmentDetails,
    double? estimatedAmount,
    double? approvedAmount,
    ClaimStatus? status,
    List<BillModel>? bills,
    List<AdvanceModel>? advances,
    List<SettlementModel>? settlements,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? submittedAt,
    DateTime? approvedAt,
  }) {
    return ClaimModel(
      id: id ?? this.id,
      claimNumber: claimNumber ?? this.claimNumber,
      patientName: patientName ?? this.patientName,
      patientId: patientId ?? this.patientId,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      hospitalName: hospitalName ?? this.hospitalName,
      hospitalId: hospitalId ?? this.hospitalId,
      admissionDate: admissionDate ?? this.admissionDate,
      dischargeDate: dischargeDate ?? this.dischargeDate,
      treatingDoctor: treatingDoctor ?? this.treatingDoctor,
      department: department ?? this.department,
      policyNumber: policyNumber ?? this.policyNumber,
      insurerName: insurerName ?? this.insurerName,
      tpaName: tpaName ?? this.tpaName,
      claimType: claimType ?? this.claimType,
      diagnosisDetails: diagnosisDetails ?? this.diagnosisDetails,
      treatmentDetails: treatmentDetails ?? this.treatmentDetails,
      estimatedAmount: estimatedAmount ?? this.estimatedAmount,
      approvedAmount: approvedAmount ?? this.approvedAmount,
      status: status ?? this.status,
      bills: bills ?? this.bills,
      advances: advances ?? this.advances,
      settlements: settlements ?? this.settlements,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      submittedAt: submittedAt ?? this.submittedAt,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'claimNumber': claimNumber,
      'patientName': patientName,
      'patientId': patientId,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender.toApiValue(),
      'contactNumber': contactNumber,
      'email': email,
      'address': address,
      'hospitalName': hospitalName,
      'hospitalId': hospitalId,
      'admissionDate': admissionDate.toIso8601String(),
      'dischargeDate': dischargeDate?.toIso8601String(),
      'treatingDoctor': treatingDoctor,
      'department': department,
      'policyNumber': policyNumber,
      'insurerName': insurerName,
      'tpaName': tpaName,
      'claimType': claimType.toApiValue(),
      'diagnosisDetails': diagnosisDetails,
      'treatmentDetails': treatmentDetails,
      'estimatedAmount': estimatedAmount,
      'approvedAmount': approvedAmount,
      'status': status.toApiValue(),
      'bills': bills.map((b) => b.toJson()).toList(),
      'advances': advances.map((a) => a.toJson()).toList(),
      'settlements': settlements.map((s) => s.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'submittedAt': submittedAt?.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
    };
  }

  factory ClaimModel.fromJson(Map<String, dynamic> json) {
    return ClaimModel(
      id: json['id'] as String,
      claimNumber: json['claimNumber'] as String,
      patientName: json['patientName'] as String,
      patientId: json['patientId'] as String,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      gender: GenderExtension.fromApiValue(json['gender'] as String),
      contactNumber: json['contactNumber'] as String,
      email: json['email'] as String?,
      address: json['address'] as String?,
      hospitalName: json['hospitalName'] as String,
      hospitalId: json['hospitalId'] as String?,
      admissionDate: DateTime.parse(json['admissionDate'] as String),
      dischargeDate: json['dischargeDate'] != null
          ? DateTime.parse(json['dischargeDate'] as String)
          : null,
      treatingDoctor: json['treatingDoctor'] as String?,
      department: json['department'] as String?,
      policyNumber: json['policyNumber'] as String,
      insurerName: json['insurerName'] as String,
      tpaName: json['tpaName'] as String?,
      claimType: ClaimTypeExtension.fromApiValue(json['claimType'] as String),
      diagnosisDetails: json['diagnosisDetails'] as String?,
      treatmentDetails: json['treatmentDetails'] as String?,
      estimatedAmount: (json['estimatedAmount'] as num).toDouble(),
      approvedAmount: json['approvedAmount'] != null
          ? (json['approvedAmount'] as num).toDouble()
          : null,
      status: ClaimStatusExtension.fromApiValue(json['status'] as String),
      bills: (json['bills'] as List<dynamic>?)
              ?.map((b) => BillModel.fromJson(b as Map<String, dynamic>))
              .toList() ??
          [],
      advances: (json['advances'] as List<dynamic>?)
              ?.map((a) => AdvanceModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      settlements: (json['settlements'] as List<dynamic>?)
              ?.map((s) => SettlementModel.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'] as String)
          : null,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClaimModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ClaimModel(id: $id, claimNumber: $claimNumber, patientName: $patientName, status: ${status.displayName})';
  }
}
