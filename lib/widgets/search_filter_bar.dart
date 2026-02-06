import 'package:flutter/material.dart';
import '../core/theme/color_scheme.dart';

class FilterChipData {
  final String id;
  final String label;
  final IconData? icon;
  final bool isSelected;

  const FilterChipData({
    required this.id,
    required this.label,
    this.icon,
    this.isSelected = false,
  });

  FilterChipData copyWith({bool? isSelected}) {
    return FilterChipData(
      id: id,
      label: label,
      icon: icon,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class SearchFilterBar extends StatefulWidget {
  final String? searchHint;
  final String? initialSearchValue;
  final List<FilterChipData> filters;
  final void Function(String query)? onSearchChanged;
  final void Function(String query)? onSearchSubmitted;
  final void Function(String filterId, bool isSelected)? onFilterChanged;
  final VoidCallback? onClearFilters;
  final bool showClearButton;
  final bool expandable;

  const SearchFilterBar({
    super.key,
    this.searchHint = 'Search...',
    this.initialSearchValue,
    this.filters = const [],
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onFilterChanged,
    this.onClearFilters,
    this.showClearButton = true,
    this.expandable = false,
  });

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  late TextEditingController _searchController;
  late List<FilterChipData> _filters;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearchValue);
    _filters = widget.filters;
  }

  @override
  void didUpdateWidget(SearchFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filters != oldWidget.filters) {
      _filters = widget.filters;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters => _filters.any((f) => f.isSelected);

  void _clearSearch() {
    _searchController.clear();
    widget.onSearchChanged?.call('');
  }

  void _toggleFilter(FilterChipData filter) {
    setState(() {
      final index = _filters.indexWhere((f) => f.id == filter.id);
      if (index != -1) {
        _filters[index] = filter.copyWith(isSelected: !filter.isSelected);
      }
    });
    widget.onFilterChanged?.call(filter.id, !filter.isSelected);
  }

  void _clearAllFilters() {
    setState(() {
      _filters = _filters.map((f) => f.copyWith(isSelected: false)).toList();
    });
    widget.onClearFilters?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: _buildSearchField()),
            if (widget.expandable && _filters.isNotEmpty) ...[
              const SizedBox(width: 8),
              _buildExpandButton(),
            ],
          ],
        ),
        if (_filters.isNotEmpty && (!widget.expandable || _isExpanded)) ...[
          const SizedBox(height: 12),
          _buildFilterChips(),
        ],
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
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
      child: TextField(
        controller: _searchController,
        onChanged: widget.onSearchChanged,
        onSubmitted: widget.onSearchSubmitted,
        decoration: InputDecoration(
          hintText: widget.searchHint,
          hintStyle: TextStyle(color: AppColors.textHint),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textSecondary,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: _clearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        style: const TextStyle(
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildExpandButton() {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(
              color: _hasActiveFilters ? AppColors.primary : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.filter_list,
                color: _hasActiveFilters
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 20,
              ),
              if (_hasActiveFilters) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_filters.where((f) => f.isSelected).length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ..._filters.map((filter) => _buildFilterChip(filter)),
        if (widget.showClearButton && _hasActiveFilters)
          ActionChip(
            label: const Text('Clear all'),
            onPressed: _clearAllFilters,
            backgroundColor: AppColors.surfaceVariant,
            labelStyle: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterChip(FilterChipData filter) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (filter.icon != null) ...[
            Icon(
              filter.icon,
              size: 16,
              color: filter.isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
          ],
          Text(filter.label),
        ],
      ),
      selected: filter.isSelected,
      onSelected: (_) => _toggleFilter(filter),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: filter.isSelected ? Colors.white : AppColors.textPrimary,
        fontSize: 13,
        fontWeight: filter.isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      side: BorderSide(
        color: filter.isSelected ? AppColors.primary : AppColors.border,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }
}
