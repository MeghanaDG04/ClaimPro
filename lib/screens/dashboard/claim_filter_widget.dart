import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/claim_provider.dart';
import '../../core/constants/status_constants.dart';
import '../../core/theme/color_scheme.dart';

class ClaimFilterWidget extends StatelessWidget {
  const ClaimFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ClaimProvider>(
      builder: (context, provider, _) {
        final selectedStatus = provider.statusFilter;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              _buildFilterChip(
                context: context,
                label: 'All',
                isSelected: selectedStatus == null,
                onSelected: () => provider.setStatusFilter(null),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context: context,
                label: ClaimStatus.draft.displayName,
                status: ClaimStatus.draft,
                isSelected: selectedStatus == ClaimStatus.draft,
                onSelected: () => provider.setStatusFilter(ClaimStatus.draft),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context: context,
                label: ClaimStatus.submitted.displayName,
                status: ClaimStatus.submitted,
                isSelected: selectedStatus == ClaimStatus.submitted,
                onSelected: () =>
                    provider.setStatusFilter(ClaimStatus.submitted),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context: context,
                label: ClaimStatus.underReview.displayName,
                status: ClaimStatus.underReview,
                isSelected: selectedStatus == ClaimStatus.underReview,
                onSelected: () =>
                    provider.setStatusFilter(ClaimStatus.underReview),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context: context,
                label: ClaimStatus.approved.displayName,
                status: ClaimStatus.approved,
                isSelected: selectedStatus == ClaimStatus.approved,
                onSelected: () =>
                    provider.setStatusFilter(ClaimStatus.approved),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context: context,
                label: ClaimStatus.rejected.displayName,
                status: ClaimStatus.rejected,
                isSelected: selectedStatus == ClaimStatus.rejected,
                onSelected: () =>
                    provider.setStatusFilter(ClaimStatus.rejected),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context: context,
                label: 'Settled',
                isSelected: selectedStatus == ClaimStatus.fullySettled,
                onSelected: () =>
                    provider.setStatusFilter(ClaimStatus.fullySettled),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    ClaimStatus? status,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    final color = status?.color ?? AppColors.primary;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      backgroundColor: AppColors.surface,
      side: BorderSide(
        color: isSelected ? color : AppColors.border,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
