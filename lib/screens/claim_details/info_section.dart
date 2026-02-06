import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/color_scheme.dart';

class InfoItem {
  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;
  final bool isBold;

  const InfoItem({
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
    this.isBold = false,
  });
}

class InfoSection extends StatefulWidget {
  final String title;
  final IconData? icon;
  final List<InfoItem> items;
  final bool initiallyExpanded;
  final VoidCallback? onEdit;
  final bool showEditButton;
  final bool animate;
  final Color? headerColor;

  const InfoSection({
    super.key,
    required this.title,
    this.icon,
    required this.items,
    this.initiallyExpanded = true,
    this.onEdit,
    this.showEditButton = false,
    this.animate = true,
    this.headerColor,
  });

  @override
  State<InfoSection> createState() => _InfoSectionState();
}

class _InfoSectionState extends State<InfoSection>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _iconRotation;
  late Animation<double> _contentFade;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _iconRotation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  heightFactor: _controller.value,
                  child: FadeTransition(
                    opacity: _contentFade,
                    child: child,
                  ),
                ),
              );
            },
            child: _buildContent(),
          ),
        ],
      ),
    );

    if (widget.animate) {
      content = FadeInUp(
        duration: const Duration(milliseconds: 400),
        child: content,
      );
    }

    return content;
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: _toggleExpanded,
      borderRadius: BorderRadius.vertical(
        top: const Radius.circular(12),
        bottom: Radius.circular(_isExpanded ? 0 : 12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.headerColor?.withOpacity(0.05) ??
              AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(12),
            bottom: Radius.circular(_isExpanded ? 0 : 12),
          ),
        ),
        child: Row(
          children: [
            if (widget.icon != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.headerColor?.withOpacity(0.1) ??
                      AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  widget.icon,
                  size: 20,
                  color: widget.headerColor ?? AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: widget.headerColor ?? AppColors.textPrimary,
                ),
              ),
            ),
            if (widget.showEditButton && widget.onEdit != null) ...[
              IconButton(
                onPressed: widget.onEdit,
                icon: const Icon(Icons.edit_outlined),
                iconSize: 20,
                color: AppColors.primary,
                tooltip: 'Edit',
                visualDensity: VisualDensity.compact,
              ),
            ],
            RotationTransition(
              turns: _iconRotation,
              child: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No information available',
          style: TextStyle(
            color: AppColors.textHint,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: widget.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == widget.items.length - 1;

          return Column(
            children: [
              _buildInfoRow(item),
              if (!isLast)
                Divider(
                  height: 24,
                  color: AppColors.divider,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoRow(InfoItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.icon != null) ...[
          Icon(
            item.icon,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          flex: 2,
          child: Text(
            item.label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Text(
            item.value.isEmpty ? '-' : item.value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: item.isBold ? FontWeight.w600 : FontWeight.w500,
              color: item.valueColor ?? AppColors.textPrimary,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class CollapsibleListSection<T> extends StatefulWidget {
  final String title;
  final IconData? icon;
  final List<T> items;
  final Widget Function(T item, int index) itemBuilder;
  final bool initiallyExpanded;
  final VoidCallback? onAdd;
  final String? addButtonLabel;
  final Color? headerColor;
  final String emptyMessage;
  final bool animate;

  const CollapsibleListSection({
    super.key,
    required this.title,
    this.icon,
    required this.items,
    required this.itemBuilder,
    this.initiallyExpanded = false,
    this.onAdd,
    this.addButtonLabel,
    this.headerColor,
    this.emptyMessage = 'No items available',
    this.animate = true,
  });

  @override
  State<CollapsibleListSection<T>> createState() =>
      _CollapsibleListSectionState<T>();
}

class _CollapsibleListSectionState<T> extends State<CollapsibleListSection<T>>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _iconRotation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _iconRotation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: _buildContent(),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );

    if (widget.animate) {
      content = FadeInUp(
        duration: const Duration(milliseconds: 400),
        child: content,
      );
    }

    return content;
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: _toggleExpanded,
      borderRadius: BorderRadius.vertical(
        top: const Radius.circular(12),
        bottom: Radius.circular(_isExpanded ? 0 : 12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.headerColor?.withOpacity(0.05) ??
              AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(12),
            bottom: Radius.circular(_isExpanded ? 0 : 12),
          ),
        ),
        child: Row(
          children: [
            if (widget.icon != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.headerColor?.withOpacity(0.1) ??
                      AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  widget.icon,
                  size: 20,
                  color: widget.headerColor ?? AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Row(
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: widget.headerColor ?? AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: widget.headerColor?.withOpacity(0.2) ??
                          AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${widget.items.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: widget.headerColor ?? AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.onAdd != null && _isExpanded) ...[
              TextButton.icon(
                onPressed: widget.onAdd,
                icon: const Icon(Icons.add, size: 18),
                label: Text(widget.addButtonLabel ?? 'Add'),
                style: TextButton.styleFrom(
                  foregroundColor: widget.headerColor ?? AppColors.primary,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
            RotationTransition(
              turns: _iconRotation,
              child: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 48,
                color: AppColors.textHint,
              ),
              const SizedBox(height: 8),
              Text(
                widget.emptyMessage,
                style: TextStyle(
                  color: AppColors.textHint,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: widget.items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return widget.itemBuilder(widget.items[index], index);
      },
    );
  }
}
