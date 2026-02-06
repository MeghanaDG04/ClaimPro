import 'package:flutter/material.dart';
import '../core/constants/status_constants.dart';

enum BadgeSize { small, medium, large }

class StatusBadge extends StatelessWidget {
  final ClaimStatus? claimStatus;
  final BillStatus? billStatus;
  final AdvanceStatus? advanceStatus;
  final BadgeSize size;
  final bool showIcon;

  const StatusBadge({
    super.key,
    this.claimStatus,
    this.billStatus,
    this.advanceStatus,
    this.size = BadgeSize.medium,
    this.showIcon = true,
  }) : assert(
          claimStatus != null || billStatus != null || advanceStatus != null,
          'At least one status must be provided',
        );

  const StatusBadge.claim({
    super.key,
    required ClaimStatus status,
    this.size = BadgeSize.medium,
    this.showIcon = true,
  })  : claimStatus = status,
        billStatus = null,
        advanceStatus = null;

  const StatusBadge.bill({
    super.key,
    required BillStatus status,
    this.size = BadgeSize.medium,
    this.showIcon = true,
  })  : claimStatus = null,
        billStatus = status,
        advanceStatus = null;

  const StatusBadge.advance({
    super.key,
    required AdvanceStatus status,
    this.size = BadgeSize.medium,
    this.showIcon = true,
  })  : claimStatus = null,
        billStatus = null,
        advanceStatus = status;

  String get _displayName {
    if (claimStatus != null) return claimStatus!.displayName;
    if (billStatus != null) return billStatus!.displayName;
    if (advanceStatus != null) return advanceStatus!.displayName;
    return '';
  }

  Color get _color {
    if (claimStatus != null) return claimStatus!.color;
    if (billStatus != null) return billStatus!.color;
    if (advanceStatus != null) return advanceStatus!.color;
    return Colors.grey;
  }

  Color get _backgroundColor {
    if (claimStatus != null) return claimStatus!.backgroundColor;
    return _color.withOpacity(0.1);
  }

  IconData get _icon {
    if (claimStatus != null) return claimStatus!.icon;
    if (billStatus != null) return billStatus!.icon;
    if (advanceStatus != null) return advanceStatus!.icon;
    return Icons.info;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        );
      },
      child: Container(
        key: ValueKey('$claimStatus$billStatus$advanceStatus'),
        padding: _getPadding(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _backgroundColor,
              _backgroundColor.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          boxShadow: [
            BoxShadow(
              color: _color.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: _color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(
                _icon,
                size: _getIconSize(),
                color: _color,
              ),
              SizedBox(width: _getSpacing()),
            ],
            Text(
              _displayName,
              style: TextStyle(
                color: _color,
                fontSize: _getFontSize(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case BadgeSize.small:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case BadgeSize.medium:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case BadgeSize.large:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case BadgeSize.small:
        return 12;
      case BadgeSize.medium:
        return 16;
      case BadgeSize.large:
        return 20;
    }
  }

  double _getIconSize() {
    switch (size) {
      case BadgeSize.small:
        return 12;
      case BadgeSize.medium:
        return 16;
      case BadgeSize.large:
        return 20;
    }
  }

  double _getSpacing() {
    switch (size) {
      case BadgeSize.small:
        return 4;
      case BadgeSize.medium:
        return 6;
      case BadgeSize.large:
        return 8;
    }
  }

  double _getFontSize() {
    switch (size) {
      case BadgeSize.small:
        return 11;
      case BadgeSize.medium:
        return 13;
      case BadgeSize.large:
        return 15;
    }
  }
}
