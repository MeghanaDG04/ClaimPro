import 'package:uuid/uuid.dart';
import '../core/constants/status_constants.dart';

enum BillType {
  hospitalCharges,
  doctorFees,
  medicines,
  diagnostics,
  roomCharges,
  surgeryCharges,
  miscellaneous,
  other,
}

extension BillTypeExtension on BillType {
  String get displayName {
    switch (this) {
      case BillType.hospitalCharges:
        return 'Hospital Charges';
      case BillType.doctorFees:
        return 'Doctor Fees';
      case BillType.medicines:
        return 'Medicines';
      case BillType.diagnostics:
        return 'Diagnostics';
      case BillType.roomCharges:
        return 'Room Charges';
      case BillType.surgeryCharges:
        return 'Surgery Charges';
      case BillType.miscellaneous:
        return 'Miscellaneous';
      case BillType.other:
        return 'Other';
    }
  }

  String toApiValue() {
    return name.toUpperCase();
  }

  static BillType fromApiValue(String value) {
    return BillType.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => BillType.other,
    );
  }
}

class BillModel {
  final String id;
  final String claimId;
  final String billNumber;
  final DateTime billDate;
  final BillType billType;
  final String description;
  final double amount;
  final double? approvedAmount;
  final BillStatus status;
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BillModel({
    required this.id,
    required this.claimId,
    required this.billNumber,
    required this.billDate,
    required this.billType,
    required this.description,
    required this.amount,
    this.approvedAmount,
    required this.status,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BillModel.create({
    required String claimId,
    required String billNumber,
    required DateTime billDate,
    required BillType billType,
    required String description,
    required double amount,
    double? approvedAmount,
    BillStatus status = BillStatus.pending,
    String? remarks,
  }) {
    final now = DateTime.now();
    return BillModel(
      id: const Uuid().v4(),
      claimId: claimId,
      billNumber: billNumber,
      billDate: billDate,
      billType: billType,
      description: description,
      amount: amount,
      approvedAmount: approvedAmount,
      status: status,
      remarks: remarks,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory BillModel.empty() {
    final now = DateTime.now();
    return BillModel(
      id: const Uuid().v4(),
      claimId: '',
      billNumber: '',
      billDate: now,
      billType: BillType.other,
      description: '',
      amount: 0.0,
      approvedAmount: null,
      status: BillStatus.pending,
      remarks: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  BillModel copyWith({
    String? id,
    String? claimId,
    String? billNumber,
    DateTime? billDate,
    BillType? billType,
    String? description,
    double? amount,
    double? approvedAmount,
    BillStatus? status,
    String? remarks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BillModel(
      id: id ?? this.id,
      claimId: claimId ?? this.claimId,
      billNumber: billNumber ?? this.billNumber,
      billDate: billDate ?? this.billDate,
      billType: billType ?? this.billType,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      approvedAmount: approvedAmount ?? this.approvedAmount,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'claimId': claimId,
      'billNumber': billNumber,
      'billDate': billDate.toIso8601String(),
      'billType': billType.toApiValue(),
      'description': description,
      'amount': amount,
      'approvedAmount': approvedAmount,
      'status': status.name.toUpperCase(),
      'remarks': remarks,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'] as String,
      claimId: json['claimId'] as String,
      billNumber: json['billNumber'] as String,
      billDate: DateTime.parse(json['billDate'] as String),
      billType: BillTypeExtension.fromApiValue(json['billType'] as String),
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      approvedAmount: json['approvedAmount'] != null
          ? (json['approvedAmount'] as num).toDouble()
          : null,
      status: BillStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == (json['status'] as String).toUpperCase(),
        orElse: () => BillStatus.pending,
      ),
      remarks: json['remarks'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BillModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BillModel(id: $id, billNumber: $billNumber, amount: $amount, status: ${status.displayName})';
  }
}
