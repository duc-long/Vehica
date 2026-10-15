import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/widgets/vehica_back_button.dart';
import 'package:vehica_mobile/core/widgets/vehica_badge.dart';
import 'package:vehica_mobile/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:vehica_mobile/features/dashboard/presentation/widgets/admin_kpi_grid.dart';
import 'package:vehica_mobile/features/dashboard/presentation/widgets/admin_nav_hub.dart';
import 'package:vehica_mobile/features/dashboard/presentation/widgets/admin_revenue_banner.dart';

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
                  const AdminNavHub(),
                  const SizedBox(height: 20),
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
                        AdminRevenueBanner(summary: summary),
                        const SizedBox(height: 16),
                        AdminKpiGrid(summary: summary),
                      ],
                    ),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (err, _) => Center(
                      child: Text('Lỗi: $err'),
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
