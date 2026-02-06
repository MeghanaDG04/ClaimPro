import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../providers/claim_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/color_scheme.dart';
import '../../core/constants/route_constants.dart';
import '../../core/constants/status_constants.dart';
import '../../core/utils/calculation_utils.dart';
import '../../core/utils/date_utils.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/responsive_layout.dart';
import '../../models/claim_model.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ClaimProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.allClaims.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadClaims(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreetingSection(context),
                const SizedBox(height: 24),
                _buildStatsSection(context, provider),
                const SizedBox(height: 24),
                _buildPieChartSection(context, provider),
                const SizedBox(height: 24),
                _buildRecentClaimsSection(context, provider),
                const SizedBox(height: 24),
                _buildQuickActionsSection(context),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGreetingSection(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);

    return FadeInDown(
      duration: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting, ${user?.name.split(' ').first ?? 'User'}! 👋',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppDateUtils.formatToFull(now),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildStatsSection(BuildContext context, ClaimProvider provider) {
    final settledCount =
        provider.partiallySettledCount + provider.fullySettledCount;

    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 1000
              ? 5
              : constraints.maxWidth > 600
                  ? 3
                  : 2;
          final childAspectRatio = constraints.maxWidth > 600 ? 1.6 : 1.4;

          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
            children: [
              FadeInLeft(
                delay: const Duration(milliseconds: 100),
                child: StatCard(
                  title: 'Total Claims',
                  value: provider.totalClaims.toString(),
                  subtitle: 'All time',
                  icon: Icons.folder_copy_outlined,
                  iconBackgroundColor: AppColors.primary,
                  trendDirection: TrendDirection.up,
                  trendPercentage: '12%',
                  onTap: () => Navigator.pushNamed(context, RouteConstants.claims),
                ),
              ),
              FadeInLeft(
                delay: const Duration(milliseconds: 150),
                child: StatCard(
                  title: 'Draft Claims',
                  value: provider.draftCount.toString(),
                  subtitle: 'Incomplete',
                  icon: Icons.edit_note,
                  iconBackgroundColor: Colors.grey,
                  onTap: () => provider.setStatusFilter(ClaimStatus.draft),
                ),
              ),
              FadeInLeft(
                delay: const Duration(milliseconds: 200),
                child: StatCard(
                  title: 'Pending',
                  value: provider.pendingCount.toString(),
                  subtitle: 'Submitted + Under Review',
                  icon: Icons.pending_actions,
                  iconBackgroundColor: AppColors.warning,
                  trendDirection: TrendDirection.down,
                  trendPercentage: '5%',
                  onTap: () => provider.setStatusFilter(ClaimStatus.submitted),
                ),
              ),
              FadeInLeft(
                delay: const Duration(milliseconds: 250),
                child: StatCard(
                  title: 'Approved',
                  value: provider.approvedCount.toString(),
                  subtitle: 'Ready for settlement',
                  icon: Icons.check_circle_outline,
                  iconBackgroundColor: AppColors.success,
                  trendDirection: TrendDirection.up,
                  trendPercentage: '8%',
                  onTap: () => provider.setStatusFilter(ClaimStatus.approved),
                ),
              ),
              FadeInLeft(
                delay: const Duration(milliseconds: 300),
                child: StatCard(
                  title: 'Settled',
                  value: settledCount.toString(),
                  subtitle: CalculationUtils.formatCurrencyCompact(
                      provider.totalSettledValue),
                  icon: Icons.payments_outlined,
                  iconBackgroundColor: AppColors.secondary,
                  trendDirection: TrendDirection.up,
                  trendPercentage: '15%',
                  onTap: () =>
                      provider.setStatusFilter(ClaimStatus.fullySettled),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPieChartSection(BuildContext context, ClaimProvider provider) {
    final statusCounts = {
      ClaimStatus.draft: provider.draftCount,
      ClaimStatus.submitted: provider.submittedCount,
      ClaimStatus.underReview: provider.underReviewCount,
      ClaimStatus.approved: provider.approvedCount,
      ClaimStatus.rejected: provider.rejectedCount,
      ClaimStatus.partiallySettled: provider.partiallySettledCount,
      ClaimStatus.fullySettled: provider.fullySettledCount,
      ClaimStatus.closed: provider.closedCount,
    };

    final total = statusCounts.values.fold(0, (sum, count) => sum + count);

    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Claims Distribution by Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            if (total == 0)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text(
                    'No claims data available',
                    style: TextStyle(color: AppColors.textHint),
                  ),
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 500;
                  final chartWidget = _buildPieChart(statusCounts, total);
                  final legendWidget = _buildLegend(statusCounts);

                  if (isWide) {
                    return Row(
                      children: [
                        Expanded(child: chartWidget),
                        const SizedBox(width: 24),
                        Expanded(child: legendWidget),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      chartWidget,
                      const SizedBox(height: 20),
                      legendWidget,
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(Map<ClaimStatus, int> statusCounts, int total) {
    final sections = <PieChartSectionData>[];

    statusCounts.forEach((status, count) {
      if (count > 0) {
        final percentage = (count / total * 100);
        sections.add(PieChartSectionData(
          color: status.color,
          value: count.toDouble(),
          title: '${percentage.toStringAsFixed(0)}%',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titlePositionPercentageOffset: 0.55,
        ));
      }
    });

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 40,
          sectionsSpace: 2,
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {},
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(Map<ClaimStatus, int> statusCounts) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: statusCounts.entries
          .where((e) => e.value > 0)
          .map((e) => _buildLegendItem(e.key.displayName, e.key.color, e.value))
          .toList(),
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ($count)',
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildRecentClaimsSection(
      BuildContext context, ClaimProvider provider) {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      duration: const Duration(milliseconds: 600),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text(
                    'Recent Claims',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, RouteConstants.claims),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('View All'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (provider.claims.isEmpty)
              _buildEmptyState(context)
            else
              _buildClaimsList(context, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            child: Icon(
              Icons.folder_open_outlined,
              size: 80,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No claims found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first claim to get started',
            style: TextStyle(color: AppColors.textHint),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, RouteConstants.createClaim),
            icon: const Icon(Icons.add),
            label: const Text('Create Claim'),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimsList(BuildContext context, ClaimProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return _buildClaimsTable(context, provider);
        }
        return _buildClaimsCards(context, provider);
      },
    );
  }

  Widget _buildClaimsTable(BuildContext context, ClaimProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(AppColors.background),
        columns: const [
          DataColumn(label: Text('Claim #')),
          DataColumn(label: Text('Patient')),
          DataColumn(label: Text('Hospital')),
          DataColumn(label: Text('Amount')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Date')),
        ],
        rows: provider.claims.take(10).map((claim) {
          return DataRow(
            onSelectChanged: (_) => _navigateToClaimDetails(context, claim),
            cells: [
              DataCell(
                Text(
                  claim.claimNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(claim.patientName),
                    Text(
                      claim.patientId,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(Text(claim.hospitalName)),
              DataCell(
                Text(
                  CalculationUtils.formatCurrency(claim.estimatedAmount),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              DataCell(
                StatusBadge.claim(
                  status: claim.status,
                  size: BadgeSize.small,
                ),
              ),
              DataCell(
                Text(AppDateUtils.formatToDisplay(claim.createdAt)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildClaimsCards(BuildContext context, ClaimProvider provider) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: provider.claims.length > 10 ? 10 : provider.claims.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final claim = provider.claims[index];
        return _buildClaimCard(context, claim, index);
      },
    );
  }

  Widget _buildClaimCard(BuildContext context, ClaimModel claim, int index) {
    return FadeInLeft(
      delay: Duration(milliseconds: 50 * index),
      duration: const Duration(milliseconds: 400),
      child: InkWell(
        onTap: () => _navigateToClaimDetails(context, claim),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      claim.claimNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  StatusBadge.claim(
                    status: claim.status,
                    size: BadgeSize.small,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 16, color: AppColors.textHint),
                  const SizedBox(width: 6),
                  Expanded(child: Text(claim.patientName)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.local_hospital_outlined,
                      size: 16, color: AppColors.textHint),
                  const SizedBox(width: 6),
                  Expanded(child: Text(claim.hospitalName)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    CalculationUtils.formatCurrency(claim.estimatedAmount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    AppDateUtils.formatToDisplay(claim.createdAt),
                    style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return FadeInUp(
      delay: const Duration(milliseconds: 500),
      duration: const Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildQuickActionCard(
                    context,
                    icon: Icons.add_circle_outline,
                    label: 'New Claim',
                    color: AppColors.primary,
                    onTap: () =>
                        Navigator.pushNamed(context, RouteConstants.createClaim),
                  ),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.list_alt_outlined,
                    label: 'All Claims',
                    color: AppColors.secondary,
                    onTap: () =>
                        Navigator.pushNamed(context, RouteConstants.claims),
                  ),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.pending_actions,
                    label: 'Pending',
                    color: AppColors.warning,
                    onTap: () {
                      context
                          .read<ClaimProvider>()
                          .setStatusFilter(ClaimStatus.submitted);
                      Navigator.pushNamed(context, RouteConstants.claims);
                    },
                  ),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.bar_chart,
                    label: 'Reports',
                    color: AppColors.info,
                    onTap: () =>
                        Navigator.pushNamed(context, RouteConstants.reports),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToClaimDetails(BuildContext context, ClaimModel claim) {
    Navigator.pushNamed(
      context,
      RouteConstants.claimDetails,
      arguments: claim.id,
    );
  }
}
