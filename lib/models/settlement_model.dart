import 'package:uuid/uuid.dart';
import 'advance_model.dart';

enum SettlementType {
  partial,
  final_,
}

extension SettlementTypeExtension on SettlementType {
  String get displayName {
    switch (this) {
      case SettlementType.partial:
        return 'Partial';
      case SettlementType.final_:
        return 'Final';
    }
  }

  String toApiValue() {
    switch (this) {
      case SettlementType.partial:
        return 'PARTIAL';
      case SettlementType.final_:
        return 'FINAL';
    }
  }

  static SettlementType fromApiValue(String value) {
    switch (value.toUpperCase()) {
      case 'PARTIAL':
        return SettlementType.partial;
      case 'FINAL':
        return SettlementType.final_;
      default:
        return SettlementType.partial;
    }
  }
}

class SettlementModel {
  final String id;
  final String claimId;
  final String settlementNumber;
  final DateTime settlementDate;
  final double settledAmount;
  final SettlementType settlementType;
  final PaymentMode paymentMode;
  final String referenceNumber;
  final double deductions;
  final String? deductionRemarks;
  final String? remarks;
  final String settledBy;
  final DateTime createdAt;

  const SettlementModel({
    required this.id,
    required this.claimId,
    required this.settlementNumber,
    required this.settlementDate,
    required this.settledAmount,
    required this.settlementType,
    required this.paymentMode,
    required this.referenceNumber,
    required this.deductions,
    this.deductionRemarks,
    this.remarks,
    required this.settledBy,
    required this.createdAt,
  });

  double get netAmount => settledAmount - deductions;

  static String _generateSettlementNumber() {
    final now = DateTime.now();
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final randomSuffix = now.millisecondsSinceEpoch.toString().substring(7);
    return 'STL-$dateStr-$randomSuffix';
  }

  factory SettlementModel.create({
    required String claimId,
    String? settlementNumber,
    required DateTime settlementDate,
    required double settledAmount,
    required SettlementType settlementType,
    required PaymentMode paymentMode,
    required String referenceNumber,
    double deductions = 0.0,
    String? deductionRemarks,
    String? remarks,
    required String settledBy,
  }) {
    return SettlementModel(
      id: const Uuid().v4(),
      claimId: claimId,
      settlementNumber: settlementNumber ?? _generateSettlementNumber(),
      settlementDate: settlementDate,
      settledAmount: settledAmount,
      settlementType: settlementType,
      paymentMode: paymentMode,
      referenceNumber: referenceNumber,
      deductions: deductions,
      deductionRemarks: deductionRemarks,
      remarks: remarks,
      settledBy: settledBy,
      createdAt: DateTime.now(),
    );
  }

  factory SettlementModel.empty() {
    return SettlementModel(
      id: const Uuid().v4(),
      claimId: '',
      settlementNumber: _generateSettlementNumber(),
      settlementDate: DateTime.now(),
      settledAmount: 0.0,
      settlementType: SettlementType.partial,
      paymentMode: PaymentMode.bankTransfer,
      referenceNumber: '',
      deductions: 0.0,
      deductionRemarks: null,
      remarks: null,
      settledBy: '',
      createdAt: DateTime.now(),
    );
  }

  SettlementModel copyWith({
    String? id,
    String? claimId,
    String? settlementNumber,
    DateTime? settlementDate,
    double? settledAmount,
    SettlementType? settlementType,
    PaymentMode? paymentMode,
    String? referenceNumber,
    double? deductions,
    String? deductionRemarks,
    String? remarks,
    String? settledBy,
    DateTime? createdAt,
  }) {
    return SettlementModel(
      id: id ?? this.id,
      claimId: claimId ?? this.claimId,
      settlementNumber: settlementNumber ?? this.settlementNumber,
      settlementDate: settlementDate ?? this.settlementDate,
      settledAmount: settledAmount ?? this.settledAmount,
      settlementType: settlementType ?? this.settlementType,
      paymentMode: paymentMode ?? this.paymentMode,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      deductions: deductions ?? this.deductions,
      deductionRemarks: deductionRemarks ?? this.deductionRemarks,
      remarks: remarks ?? this.remarks,
      settledBy: settledBy ?? this.settledBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'claimId': claimId,
      'settlementNumber': settlementNumber,
      'settlementDate': settlementDate.toIso8601String(),
      'settledAmount': settledAmount,
      'settlementType': settlementType.toApiValue(),
      'paymentMode': paymentMode.toApiValue(),
      'referenceNumber': referenceNumber,
      'deductions': deductions,
      'deductionRemarks': deductionRemarks,
      'netAmount': netAmount,
      'remarks': remarks,
      'settledBy': settledBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SettlementModel.fromJson(Map<String, dynamic> json) {
    return SettlementModel(
      id: json['id'] as String,
      claimId: json['claimId'] as String,
      settlementNumber: json['settlementNumber'] as String,
      settlementDate: DateTime.parse(json['settlementDate'] as String),
      settledAmount: (json['settledAmount'] as num).toDouble(),
      settlementType: SettlementTypeExtension.fromApiValue(json['settlementType'] as String),
      paymentMode: PaymentModeExtension.fromApiValue(json['paymentMode'] as String),
      referenceNumber: json['referenceNumber'] as String,
      deductions: (json['deductions'] as num?)?.toDouble() ?? 0.0,
      deductionRemarks: json['deductionRemarks'] as String?,
      remarks: json['remarks'] as String?,
      settledBy: json['settledBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettlementModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SettlementModel(id: $id, settlementNumber: $settlementNumber, netAmount: $netAmount)';
  }
}
