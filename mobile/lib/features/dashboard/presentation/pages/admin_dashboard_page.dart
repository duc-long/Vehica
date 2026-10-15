// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// SCREEN            : S10 - Admin Dashboard & Analytics
// USE CASE          : UC-11 - KPI Statistics, Revenue & Fleet Reports (Admin Dashboard KPI & Reports)
// BUSINESS RULES    : BR-22 (Timezone UTC+7, Estimated total revenue stats, occupancy rate, hot vehicles),
//                     FR-STA-01..06
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/widgets/vehica_back_button.dart';
import 'package:vehica_mobile/core/widgets/vehica_badge.dart';
import 'package:vehica_mobile/core/widgets/vehica_skeleton.dart';
import 'package:vehica_mobile/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:vehica_mobile/features/dashboard/presentation/widgets/admin_distribution_cards.dart';
import 'package:vehica_mobile/features/dashboard/presentation/widgets/admin_kpi_grid.dart';
import 'package:vehica_mobile/features/dashboard/presentation/widgets/admin_nav_hub.dart';
import 'package:vehica_mobile/features/dashboard/presentation/widgets/admin_revenue_banner.dart';
import 'package:vehica_mobile/features/dashboard/presentation/widgets/admin_top_vehicles_section.dart';
import 'package:vehica_mobile/features/dashboard/presentation/widgets/admin_utilization_gauge.dart';

/// Admin Dashboard & Analytics Screen (S10)
class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summaryState = ref.watch(adminDashboardSummaryProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: const VehicaBackButton(),
        title: Row(
          children: [
            const Text('Admin Portal'),
            const SizedBox(width: 8),
            VehicaBadge.admin(),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Làm mới dữ liệu',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(adminDashboardSummaryProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(adminDashboardSummaryProvider);
        },
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Business Management Hub (5 Core Admin Modules) ─────────
                  const AdminNavHub(),
                  const SizedBox(height: 20),

                  // ── Operational & Revenue Metrics ─────────────────────────
                  Text(
                    'Chỉ số vận hành & Thống kê (KPI)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  summaryState.when(
                    data: (summary) => Column(
                      children: [
                        // Total Revenue Card
                        AdminRevenueBanner(summary: summary),
                        const SizedBox(height: 12),

                        // Fleet Utilization Gauge
                        AdminUtilizationGauge(summary: summary),
                        const SizedBox(height: 12),

                        // 4 Core KPI Cards Grid
                        AdminKpiGrid(summary: summary),
                        const SizedBox(height: 16),

                        // Fleet & Booking Status Breakdown
                        AdminDistributionSection(summary: summary),
                        const SizedBox(height: 20),

                        // Top Popular Vehicles Leaderboard
                        AdminTopVehiclesSection(summary: summary),
                      ],
                    ),
                    loading: () => Column(
                      children: const [
                        VehicaSkeleton(height: 95),
                        SizedBox(height: 12),
                        VehicaSkeleton(height: 110),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: VehicaSkeleton(height: 80)),
                            SizedBox(width: 10),
                            Expanded(child: VehicaSkeleton(height: 80)),
                          ],
                        ),
                        SizedBox(height: 12),
                        VehicaSkeleton(height: 120),
                      ],
                    ),
                    error: (err, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 32.0,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 44,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Không thể tải dữ liệu thống kê',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Vui lòng kiểm tra kết nối mạng và thử lại.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () =>
                                  ref.invalidate(adminDashboardSummaryProvider),
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              label: const Text('Thử lại'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
