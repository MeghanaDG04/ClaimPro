import 'package:flutter/material.dart';

/// Enum representing all possible claim statuses
enum ClaimStatus {
  draft,
  submitted,
  underReview,
  approved,
  rejected,
  partiallySettled,
  fullySettled,
  closed,
}

/// Extension methods for ClaimStatus
extension ClaimStatusExtension on ClaimStatus {
  /// Display name for the status
  String get displayName {
    switch (this) {
      case ClaimStatus.draft:
        return 'Draft';
      case ClaimStatus.submitted:
        return 'Submitted';
      case ClaimStatus.underReview:
        return 'Under Review';
      case ClaimStatus.approved:
        return 'Approved';
      case ClaimStatus.rejected:
        return 'Rejected';
      case ClaimStatus.partiallySettled:
        return 'Partially Settled';
      case ClaimStatus.fullySettled:
        return 'Fully Settled';
      case ClaimStatus.closed:
        return 'Closed';
    }
  }

  /// Color associated with the status
  Color get color {
    switch (this) {
      case ClaimStatus.draft:
        return Colors.grey;
      case ClaimStatus.submitted:
        return Colors.blue;
      case ClaimStatus.underReview:
        return Colors.orange;
      case ClaimStatus.approved:
        return Colors.green;
      case ClaimStatus.rejected:
        return Colors.red;
      case ClaimStatus.partiallySettled:
        return Colors.teal;
      case ClaimStatus.fullySettled:
        return Colors.green.shade700;
      case ClaimStatus.closed:
        return Colors.blueGrey;
    }
  }

  /// Background color (lighter shade) for the status
  Color get backgroundColor {
    switch (this) {
      case ClaimStatus.draft:
        return Colors.grey.shade100;
      case ClaimStatus.submitted:
        return Colors.blue.shade50;
      case ClaimStatus.underReview:
        return Colors.orange.shade50;
      case ClaimStatus.approved:
        return Colors.green.shade50;
      case ClaimStatus.rejected:
        return Colors.red.shade50;
      case ClaimStatus.partiallySettled:
        return Colors.teal.shade50;
      case ClaimStatus.fullySettled:
        return Colors.green.shade100;
      case ClaimStatus.closed:
        return Colors.blueGrey.shade50;
    }
  }

  /// Icon associated with the status
  IconData get icon {
    switch (this) {
      case ClaimStatus.draft:
        return Icons.edit_note;
      case ClaimStatus.submitted:
        return Icons.send;
      case ClaimStatus.underReview:
        return Icons.hourglass_empty;
      case ClaimStatus.approved:
        return Icons.check_circle;
      case ClaimStatus.rejected:
        return Icons.cancel;
      case ClaimStatus.partiallySettled:
        return Icons.account_balance_wallet;
      case ClaimStatus.fullySettled:
        return Icons.paid;
      case ClaimStatus.closed:
        return Icons.lock;
    }
  }

  /// Whether the claim can be edited in this status
  bool get canEdit {
    return this == ClaimStatus.draft || this == ClaimStatus.rejected;
  }

  /// Whether the claim can be submitted in this status
  bool get canSubmit {
    return this == ClaimStatus.draft;
  }

  /// Whether the claim can be approved in this status
  bool get canApprove {
    return this == ClaimStatus.submitted || this == ClaimStatus.underReview;
  }

  /// Whether the claim can be rejected in this status
  bool get canReject {
    return this == ClaimStatus.submitted || this == ClaimStatus.underReview;
  }

  /// Whether the claim can be settled in this status
  bool get canSettle {
    return this == ClaimStatus.approved || this == ClaimStatus.partiallySettled;
  }

  /// Whether the claim can be closed in this status
  bool get canClose {
    return this == ClaimStatus.fullySettled ||
        this == ClaimStatus.rejected ||
        this == ClaimStatus.partiallySettled;
  }

  /// Whether the claim can be deleted in this status
  bool get canDelete {
    return this == ClaimStatus.draft;
  }

  /// Whether the claim is in a terminal state
  bool get isTerminal {
    return this == ClaimStatus.closed || this == ClaimStatus.fullySettled;
  }

  /// Whether the claim is active (not in terminal state)
  bool get isActive {
    return !isTerminal && this != ClaimStatus.rejected;
  }

  /// Get valid next statuses from current status
  List<ClaimStatus> get validNextStatuses {
    switch (this) {
      case ClaimStatus.draft:
        return [ClaimStatus.submitted];
      case ClaimStatus.submitted:
        return [ClaimStatus.underReview, ClaimStatus.approved, ClaimStatus.rejected];
      case ClaimStatus.underReview:
        return [ClaimStatus.approved, ClaimStatus.rejected];
      case ClaimStatus.approved:
        return [ClaimStatus.partiallySettled, ClaimStatus.fullySettled];
      case ClaimStatus.rejected:
        return [ClaimStatus.draft, ClaimStatus.closed];
      case ClaimStatus.partiallySettled:
        return [ClaimStatus.fullySettled, ClaimStatus.closed];
      case ClaimStatus.fullySettled:
        return [ClaimStatus.closed];
      case ClaimStatus.closed:
        return [];
    }
  }

  /// Check if transition to target status is valid
  bool canTransitionTo(ClaimStatus target) {
    return validNextStatuses.contains(target);
  }

  /// Convert to API string value
  String toApiValue() {
    switch (this) {
      case ClaimStatus.draft:
        return 'DRAFT';
      case ClaimStatus.submitted:
        return 'SUBMITTED';
      case ClaimStatus.underReview:
        return 'UNDER_REVIEW';
      case ClaimStatus.approved:
        return 'APPROVED';
      case ClaimStatus.rejected:
        return 'REJECTED';
      case ClaimStatus.partiallySettled:
        return 'PARTIALLY_SETTLED';
      case ClaimStatus.fullySettled:
        return 'FULLY_SETTLED';
      case ClaimStatus.closed:
        return 'CLOSED';
    }
  }

  /// Create from API string value
  static ClaimStatus fromApiValue(String value) {
    switch (value.toUpperCase()) {
      case 'DRAFT':
        return ClaimStatus.draft;
      case 'SUBMITTED':
        return ClaimStatus.submitted;
      case 'UNDER_REVIEW':
        return ClaimStatus.underReview;
      case 'APPROVED':
        return ClaimStatus.approved;
      case 'REJECTED':
        return ClaimStatus.rejected;
      case 'PARTIALLY_SETTLED':
        return ClaimStatus.partiallySettled;
      case 'FULLY_SETTLED':
        return ClaimStatus.fullySettled;
      case 'CLOSED':
        return ClaimStatus.closed;
      default:
        return ClaimStatus.draft;
    }
  }
}

/// Bill status enum
enum BillStatus {
  pending,
  verified,
  approved,
  rejected,
  paid,
}

extension BillStatusExtension on BillStatus {
  String get displayName {
    switch (this) {
      case BillStatus.pending:
        return 'Pending';
      case BillStatus.verified:
        return 'Verified';
      case BillStatus.approved:
        return 'Approved';
      case BillStatus.rejected:
        return 'Rejected';
      case BillStatus.paid:
        return 'Paid';
    }
  }

  Color get color {
    switch (this) {
      case BillStatus.pending:
        return Colors.orange;
      case BillStatus.verified:
        return Colors.blue;
      case BillStatus.approved:
        return Colors.green;
      case BillStatus.rejected:
        return Colors.red;
      case BillStatus.paid:
        return Colors.teal;
    }
  }

  IconData get icon {
    switch (this) {
      case BillStatus.pending:
        return Icons.pending;
      case BillStatus.verified:
        return Icons.verified;
      case BillStatus.approved:
        return Icons.check_circle;
      case BillStatus.rejected:
        return Icons.cancel;
      case BillStatus.paid:
        return Icons.payments;
    }
  }
}

/// Advance request status enum
enum AdvanceStatus {
  requested,
  approved,
  rejected,
  disbursed,
  adjusted,
}

extension AdvanceStatusExtension on AdvanceStatus {
  String get displayName {
    switch (this) {
      case AdvanceStatus.requested:
        return 'Requested';
      case AdvanceStatus.approved:
        return 'Approved';
      case AdvanceStatus.rejected:
        return 'Rejected';
      case AdvanceStatus.disbursed:
        return 'Disbursed';
      case AdvanceStatus.adjusted:
        return 'Adjusted';
    }
  }

  Color get color {
    switch (this) {
      case AdvanceStatus.requested:
        return Colors.orange;
      case AdvanceStatus.approved:
        return Colors.blue;
      case AdvanceStatus.rejected:
        return Colors.red;
      case AdvanceStatus.disbursed:
        return Colors.green;
      case AdvanceStatus.adjusted:
        return Colors.teal;
    }
  }

  IconData get icon {
    switch (this) {
      case AdvanceStatus.requested:
        return Icons.request_page;
      case AdvanceStatus.approved:
        return Icons.thumb_up;
      case AdvanceStatus.rejected:
        return Icons.thumb_down;
      case AdvanceStatus.disbursed:
        return Icons.account_balance;
      case AdvanceStatus.adjusted:
        return Icons.balance;
    }
  }
}
