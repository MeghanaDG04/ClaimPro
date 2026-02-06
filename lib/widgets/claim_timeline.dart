import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../core/theme/color_scheme.dart';
import '../core/constants/status_constants.dart';

class TimelineEvent {
  final ClaimStatus status;
  final DateTime? timestamp;
  final String? description;
  final bool isCompleted;
  final bool isCurrent;

  const TimelineEvent({
    required this.status,
    this.timestamp,
    this.description,
    this.isCompleted = false,
    this.isCurrent = false,
  });
}

class ClaimTimeline extends StatelessWidget {
  final List<TimelineEvent> events;
  final ClaimStatus currentStatus;
  final bool horizontal;
  final bool animate;
  final bool compact;

  const ClaimTimeline({
    super.key,
    required this.events,
    required this.currentStatus,
    this.horizontal = false,
    this.animate = true,
    this.compact = false,
  });

  factory ClaimTimeline.fromStatus(ClaimStatus currentStatus) {
    final allStatuses = [
      ClaimStatus.draft,
      ClaimStatus.submitted,
      ClaimStatus.underReview,
      ClaimStatus.approved,
      ClaimStatus.fullySettled,
      ClaimStatus.closed,
    ];

    final currentIndex = allStatuses.indexOf(currentStatus);
    final events = allStatuses.asMap().entries.map((entry) {
      final index = entry.key;
      final status = entry.value;
      return TimelineEvent(
        status: status,
        isCompleted: index < currentIndex,
        isCurrent: status == currentStatus,
      );
    }).toList();

    return ClaimTimeline(
      events: events,
      currentStatus: currentStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (horizontal) {
      return _buildHorizontalTimeline();
    }
    return _buildVerticalTimeline();
  }

  Widget _buildVerticalTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: events.asMap().entries.map((entry) {
        final index = entry.key;
        final event = entry.value;
        final isLast = index == events.length - 1;

        Widget item = _buildVerticalTimelineItem(event, isLast);

        if (animate) {
          item = FadeInLeft(
            duration: const Duration(milliseconds: 300),
            delay: Duration(milliseconds: index * 100),
            child: item,
          );
        }

        return item;
      }).toList(),
    );
  }

  Widget _buildVerticalTimelineItem(TimelineEvent event, bool isLast) {
    final color = _getStatusColor(event);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _buildStatusDot(event, color),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: event.isCompleted
                        ? AppColors.success
                        : AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.status.displayName,
                    style: TextStyle(
                      fontSize: compact ? 14 : 16,
                      fontWeight: event.isCurrent
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: event.isCurrent || event.isCompleted
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                  ),
                  if (event.timestamp != null && !compact) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(event.timestamp!),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (event.description != null && !compact) ...[
                    const SizedBox(height: 4),
                    Text(
                      event.description!,
                      style: TextStyle(
                        fontSize: 13,
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

  Widget _buildHorizontalTimeline() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: events.asMap().entries.map((entry) {
          final index = entry.key;
          final event = entry.value;
          final isLast = index == events.length - 1;

          Widget item = _buildHorizontalTimelineItem(event, isLast);

          if (animate) {
            item = FadeInDown(
              duration: const Duration(milliseconds: 300),
              delay: Duration(milliseconds: index * 100),
              child: item,
            );
          }

          return item;
        }).toList(),
      ),
    );
  }

  Widget _buildHorizontalTimelineItem(TimelineEvent event, bool isLast) {
    final color = _getStatusColor(event);

    return Row(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusDot(event, color),
            const SizedBox(height: 8),
            SizedBox(
              width: compact ? 60 : 80,
              child: Text(
                event.status.displayName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: compact ? 10 : 12,
                  fontWeight: event.isCurrent
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: event.isCurrent || event.isCompleted
                      ? AppColors.textPrimary
                      : AppColors.textHint,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (!isLast)
          Container(
            width: compact ? 30 : 50,
            height: 2,
            margin: const EdgeInsets.only(bottom: 30),
            color: event.isCompleted ? AppColors.success : AppColors.border,
          ),
      ],
    );
  }

  Widget _buildStatusDot(TimelineEvent event, Color color) {
    final size = compact ? 24.0 : 32.0;
    final iconSize = compact ? 14.0 : 18.0;

    if (event.isCurrent) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 3),
        ),
        child: Icon(
          event.status.icon,
          size: iconSize,
          color: color,
        ),
      );
    }

    if (event.isCompleted) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check,
          size: iconSize,
          color: Colors.white,
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
        event.status.icon,
        size: iconSize,
        color: AppColors.textHint,
      ),
    );
  }

  Color _getStatusColor(TimelineEvent event) {
    if (event.isCurrent) {
      return event.status.color;
    }
    if (event.isCompleted) {
      return AppColors.success;
    }
    return AppColors.textHint;
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year at $hour:$minute';
  }
}
