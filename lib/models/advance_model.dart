import 'package:uuid/uuid.dart';
import '../core/constants/status_constants.dart';

enum PaymentMode {
  cash,
  cheque,
  bankTransfer,
  upi,
}

extension PaymentModeExtension on PaymentMode {
  String get displayName {
    switch (this) {
      case PaymentMode.cash:
        return 'Cash';
      case PaymentMode.cheque:
        return 'Cheque';
      case PaymentMode.bankTransfer:
        return 'Bank Transfer';
      case PaymentMode.upi:
        return 'UPI';
    }
  }

  String toApiValue() {
    return name.toUpperCase();
  }

  static PaymentMode fromApiValue(String value) {
    return PaymentMode.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => PaymentMode.cash,
    );
  }
}

class AdvanceModel {
  final String id;
  final String claimId;
  final String advanceNumber;
  final DateTime advanceDate;
  final double amount;
  final PaymentMode paymentMode;
  final String? referenceNumber;
  final String paidTo;
  final String? remarks;
  final AdvanceStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AdvanceModel({
    required this.id,
    required this.claimId,
    required this.advanceNumber,
    required this.advanceDate,
    required this.amount,
    required this.paymentMode,
    this.referenceNumber,
    required this.paidTo,
    this.remarks,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  static String _generateAdvanceNumber() {
    final now = DateTime.now();
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final randomSuffix = now.millisecondsSinceEpoch.toString().substring(7);
    return 'ADV-$dateStr-$randomSuffix';
  }

  factory AdvanceModel.create({
    required String claimId,
    String? advanceNumber,
    required DateTime advanceDate,
    required double amount,
    required PaymentMode paymentMode,
    String? referenceNumber,
    required String paidTo,
    String? remarks,
    AdvanceStatus status = AdvanceStatus.requested,
  }) {
    final now = DateTime.now();
    return AdvanceModel(
      id: const Uuid().v4(),
      claimId: claimId,
      advanceNumber: advanceNumber ?? _generateAdvanceNumber(),
      advanceDate: advanceDate,
      amount: amount,
      paymentMode: paymentMode,
      referenceNumber: referenceNumber,
      paidTo: paidTo,
      remarks: remarks,
      status: status,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory AdvanceModel.empty() {
    final now = DateTime.now();
    return AdvanceModel(
      id: const Uuid().v4(),
      claimId: '',
      advanceNumber: _generateAdvanceNumber(),
      advanceDate: now,
      amount: 0.0,
      paymentMode: PaymentMode.cash,
      referenceNumber: null,
      paidTo: '',
      remarks: null,
      status: AdvanceStatus.requested,
      createdAt: now,
      updatedAt: now,
    );
  }

  AdvanceModel copyWith({
    String? id,
    String? claimId,
    String? advanceNumber,
    DateTime? advanceDate,
    double? amount,
    PaymentMode? paymentMode,
    String? referenceNumber,
    String? paidTo,
    String? remarks,
    AdvanceStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdvanceModel(
      id: id ?? this.id,
      claimId: claimId ?? this.claimId,
      advanceNumber: advanceNumber ?? this.advanceNumber,
      advanceDate: advanceDate ?? this.advanceDate,
      amount: amount ?? this.amount,
      paymentMode: paymentMode ?? this.paymentMode,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      paidTo: paidTo ?? this.paidTo,
      remarks: remarks ?? this.remarks,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'claimId': claimId,
      'advanceNumber': advanceNumber,
      'advanceDate': advanceDate.toIso8601String(),
      'amount': amount,
      'paymentMode': paymentMode.toApiValue(),
      'referenceNumber': referenceNumber,
      'paidTo': paidTo,
      'remarks': remarks,
      'status': status.name.toUpperCase(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AdvanceModel.fromJson(Map<String, dynamic> json) {
    return AdvanceModel(
      id: json['id'] as String,
      claimId: json['claimId'] as String,
      advanceNumber: json['advanceNumber'] as String,
      advanceDate: DateTime.parse(json['advanceDate'] as String),
      amount: (json['amount'] as num).toDouble(),
      paymentMode: PaymentModeExtension.fromApiValue(json['paymentMode'] as String),
      referenceNumber: json['referenceNumber'] as String?,
      paidTo: json['paidTo'] as String,
      remarks: json['remarks'] as String?,
      status: AdvanceStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == (json['status'] as String).toUpperCase(),
        orElse: () => AdvanceStatus.requested,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdvanceModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AdvanceModel(id: $id, advanceNumber: $advanceNumber, amount: $amount, status: ${status.displayName})';
  }
}
