import 'package:flutter/material.dart';
import '../core/theme/color_scheme.dart';

class ColumnDefinition {
  final String id;
  final String label;
  final double? width;
  final double? flex;
  final TextAlign alignment;
  final bool sortable;

  const ColumnDefinition({
    required this.id,
    required this.label,
    this.width,
    this.flex,
    this.alignment = TextAlign.left,
    this.sortable = false,
  });
}

class CustomDataTable<T> extends StatefulWidget {
  final List<ColumnDefinition> columns;
  final List<T> data;
  final Widget Function(T item, ColumnDefinition column) cellBuilder;
  final void Function(T item)? onRowTap;
  final bool isLoading;
  final String emptyMessage;
  final Widget? emptyIcon;
  final int? currentPage;
  final int? totalPages;
  final void Function(int page)? onPageChanged;
  final int rowsPerPage;

  const CustomDataTable({
    super.key,
    required this.columns,
    required this.data,
    required this.cellBuilder,
    this.onRowTap,
    this.isLoading = false,
    this.emptyMessage = 'No data available',
    this.emptyIcon,
    this.currentPage,
    this.totalPages,
    this.onPageChanged,
    this.rowsPerPage = 10,
  });

  @override
  State<CustomDataTable<T>> createState() => _CustomDataTableState<T>();
}

class _CustomDataTableState<T> extends State<CustomDataTable<T>> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildLoadingState();
    }

    if (widget.data.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  ...widget.data.asMap().entries.map((entry) {
                    return _buildRow(entry.key, entry.value);
                  }),
                ],
              ),
            ),
          ),
        ),
        if (widget.currentPage != null && widget.totalPages != null)
          _buildPagination(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.emptyIcon ??
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: AppColors.textHint,
              ),
          const SizedBox(height: 16),
          Text(
            widget.emptyMessage,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 2),
        ),
      ),
      child: Row(
        children: widget.columns.map((column) {
          return _buildHeaderCell(column);
        }).toList(),
      ),
    );
  }

  Widget _buildHeaderCell(ColumnDefinition column) {
    Widget cell = Container(
      width: column.width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        column.label,
        textAlign: column.alignment,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
      ),
    );

    if (column.flex != null) {
      return Expanded(flex: column.flex!.toInt(), child: cell);
    }
    return cell;
  }

  Widget _buildRow(int index, T item) {
    final isHovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
        onTap: widget.onRowTap != null ? () => widget.onRowTap!(item) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: isHovered
                ? AppColors.primary.withOpacity(0.05)
                : (index.isEven ? AppColors.surface : AppColors.surfaceVariant),
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: Row(
            children: widget.columns.map((column) {
              return _buildCell(item, column);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCell(T item, ColumnDefinition column) {
    Widget cell = Container(
      width: column.width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      alignment: _getAlignment(column.alignment),
      child: widget.cellBuilder(item, column),
    );

    if (column.flex != null) {
      return Expanded(flex: column.flex!.toInt(), child: cell);
    }
    return cell;
  }

  Alignment _getAlignment(TextAlign textAlign) {
    switch (textAlign) {
      case TextAlign.left:
      case TextAlign.start:
        return Alignment.centerLeft;
      case TextAlign.right:
      case TextAlign.end:
        return Alignment.centerRight;
      case TextAlign.center:
        return Alignment.center;
      default:
        return Alignment.centerLeft;
    }
  }

  Widget _buildPagination() {
    final currentPage = widget.currentPage!;
    final totalPages = widget.totalPages!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: currentPage > 1
                ? () => widget.onPageChanged?.call(1)
                : null,
            color: AppColors.primary,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage > 1
                ? () => widget.onPageChanged?.call(currentPage - 1)
                : null,
            color: AppColors.primary,
          ),
          const SizedBox(width: 16),
          Text(
            'Page $currentPage of $totalPages',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages
                ? () => widget.onPageChanged?.call(currentPage + 1)
                : null,
            color: AppColors.primary,
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: currentPage < totalPages
                ? () => widget.onPageChanged?.call(totalPages)
                : null,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
