import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/claim_provider.dart';
import '../../models/claim_model.dart';
import '../../core/constants/route_constants.dart';
import '../../core/constants/status_constants.dart';
import '../../core/theme/color_scheme.dart';
import '../../core/utils/calculation_utils.dart';
import '../../core/utils/date_utils.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';

class ClaimListWidget extends StatelessWidget {
  const ClaimListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ClaimProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const LoadingWidget(
            message: 'Loading claims...',
          );
        }

        final claims = provider.claims;

        if (claims.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.folder_off_outlined,
            title: 'No Claims Found',
            message: provider.statusFilter != null
                ? 'No claims match the selected filter. Try a different filter.'
                : 'You haven\'t created any claims yet. Start by adding a new claim.',
            actionLabel: 'Create Claim',
            actionIcon: Icons.add,
            onAction: () {
              Navigator.pushNamed(context, RouteConstants.createClaim);
            },
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: claims.length,
          itemBuilder: (context, index) {
            final claim = claims[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AnimatedCard(
                delay: Duration(milliseconds: index * 50),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    RouteConstants.claimDetails,
                    arguments: claim.id,
                  );
                },
                child: _ClaimListItem(claim: claim),
              ),
            );
          },
        );
      },
    );
  }
}

class _ClaimListItem extends StatelessWidget {
  final ClaimModel claim;

  const _ClaimListItem({required this.claim});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: claim.status.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.description_outlined,
            color: claim.status.color,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      claim.claimNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  StatusBadge.claim(
                    status: claim.status,
                    size: BadgeSize.small,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                claim.patientName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.local_hospital_outlined,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      claim.hospitalName,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    CalculationUtils.formatCurrency(claim.estimatedAmount),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    AppDateUtils.formatToDisplay(claim.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.chevron_right,
          color: AppColors.textHint,
        ),
      ],
    );
  }
}
