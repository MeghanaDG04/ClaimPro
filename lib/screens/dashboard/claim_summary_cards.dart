import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

import '../../providers/claim_provider.dart';
import '../../widgets/stat_card.dart';
import '../../core/theme/color_scheme.dart';
import '../../core/utils/calculation_utils.dart';

class ClaimSummaryCards extends StatelessWidget {
  const ClaimSummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ClaimProvider>(
      builder: (context, provider, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 1200
                ? 4
                : constraints.maxWidth > 800
                    ? 4
                    : constraints.maxWidth > 600
                        ? 2
                        : 2;

            final childAspectRatio = constraints.maxWidth > 600 ? 1.3 : 1.2;

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: childAspectRatio,
              children: [
                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 0),
                  child: StatCard(
                    title: 'Total Claims',
                    value: provider.totalClaims.toString(),
                    subtitle: 'All time claims',
                    icon: Icons.folder_outlined,
                    iconBackgroundColor: AppColors.primary,
                  ),
                ),
                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 100),
                  child: StatCard(
                    title: 'Pending Claims',
                    value: provider.pendingCount.toString(),
                    subtitle: 'Awaiting review',
                    icon: Icons.hourglass_empty,
                    iconBackgroundColor: AppColors.warning,
                  ),
                ),
                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 200),
                  child: StatCard(
                    title: 'Approved Claims',
                    value: provider.approvedCount.toString(),
                    subtitle: 'Ready for settlement',
                    icon: Icons.check_circle_outline,
                    iconBackgroundColor: AppColors.success,
                  ),
                ),
                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 300),
                  child: StatCard(
                    title: 'Total Value',
                    value: CalculationUtils.formatCurrencyCompact(
                        provider.totalClaimValue),
                    subtitle: 'Estimated amount',
                    icon: Icons.account_balance_wallet_outlined,
                    iconBackgroundColor: AppColors.secondary,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
