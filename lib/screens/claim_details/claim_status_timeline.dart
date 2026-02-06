import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/claim_model.dart';
import '../../core/constants/status_constants.dart';
import '../../core/theme/color_scheme.dart';

class ClaimStatusTimeline extends StatelessWidget {
  final ClaimModel claim;
  final bool compact;

  const ClaimStatusTimeline({
    super.key,
    required this.claim,
    this.compact = false,
  });

  static const List<ClaimStatus> _statusProgression = [
    ClaimStatus.draft,
    ClaimStatus.submitted,
    ClaimStatus.underReview,
    ClaimStatus.approved,
    ClaimStatus.fullySettled,
    ClaimStatus.closed,
  ];

  static const List<ClaimStatus> _rejectedProgression = [
    ClaimStatus.draft,
    ClaimStatus.submitted,
    ClaimStatus.underReview,
    ClaimStatus.rejected,
    ClaimStatus.closed,
  ];

  List<ClaimStatus> get _applicableProgression {
    if (claim.status == ClaimStatus.rejected) {
      return _rejectedProgression;
    }
    if (claim.status == ClaimStatus.partiallySettled) {
      return [
        ClaimStatus.draft,
        ClaimStatus.submitted,
        ClaimStatus.underReview,
        ClaimStatus.approved,
        ClaimStatus.partiallySettled,
        ClaimStatus.fullySettled,
        ClaimStatus.closed,
      ];
    }
    return _statusProgression;
  }

  int get _currentStatusIndex {
    return _applicableProgression.indexOf(claim.status);
  }

  DateTime? _getTimestampForStatus(ClaimStatus status) {
    switch (status) {
      case ClaimStatus.draft:
        return claim.createdAt;
      case ClaimStatus.submitted:
        return claim.submittedAt;
      case ClaimStatus.approved:
      case ClaimStatus.rejected:
        return claim.approvedAt;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!compact) ...[
            Text(
              'Claim Progress',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
          ],
          ..._applicableProgression.asMap().entries.map((entry) {
            final index = entry.key;
            final status = entry.value;
            final isLast = index == _applicableProgression.length - 1;
            final isCompleted = index < _currentStatusIndex;
            final isCurrent = index == _currentStatusIndex;
            final isPending = index > _currentStatusIndex;
            final timestamp = _getTimestampForStatus(status);

            return _buildTimelineNode(
              status: status,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isPending: isPending,
              isLast: isLast,
              timestamp: isCompleted || isCurrent ? timestamp : null,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineNode({
    required ClaimStatus status,
    required bool isCompleted,
    required bool isCurrent,
    required bool isPending,
    required bool isLast,
    DateTime? timestamp,
  }) {
    final nodeSize = compact ? 28.0 : 36.0;
    final iconSize = compact ? 14.0 : 18.0;
    final lineHeight = compact ? 24.0 : 32.0;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _buildNode(
                status: status,
                isCompleted: isCompleted,
                isCurrent: isCurrent,
                isPending: isPending,
                size: nodeSize,
                iconSize: iconSize,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: lineHeight,
                  decoration: BoxDecoration(
                    gradient: isCompleted
                        ? LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [AppColors.success, AppColors.success],
                          )
                        : null,
                    color: isCompleted ? null : AppColors.border,
                  ),
                ),
            ],
          ),
          SizedBox(width: compact ? 12 : 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          status.displayName,
                          style: TextStyle(
                            fontSize: compact ? 13 : 15,
                            fontWeight: isCurrent
                                ? FontWeight.w700
                                : isCompleted
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                            color: isPending
                                ? AppColors.textHint
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: status.backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Current',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: status.color,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (timestamp != null && !compact) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatTimestamp(timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNode({
    required ClaimStatus status,
    required bool isCompleted,
    required bool isCurrent,
    required bool isPending,
    required double size,
    required double iconSize,
  }) {
    if (isCompleted) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.check,
          size: iconSize,
          color: Colors.white,
        ),
      );
    }

    if (isCurrent) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: status.backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: status.color, width: 3),
          boxShadow: [
            BoxShadow(
              color: status.color.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          status.icon,
          size: iconSize,
          color: status.color,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 2),
      ),
      child: Icon(
        status.icon,
        size: iconSize,
        color: AppColors.textHint,
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }
}
