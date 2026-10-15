import 'package:flutter/material.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/features/dashboard/domain/entities/dashboard_summary_entity.dart';

/// 4 Core KPI Cards Grid: Total Vehicles, Bookings, Users, Pending orders.
class AdminKpiGrid extends StatelessWidget {
  final DashboardSummaryEntity summary;

  const AdminKpiGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 700 ? 4 : 2;
        final childAspectRatio = constraints.maxWidth > 700 ? 1.85 : 1.7;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: childAspectRatio,
          children: [
            _KpiCard(
              title: 'Đội xe hoạt động',
              count: '${summary.totalVehicles}',
              subtitle: '${summary.vehiclesByStatus['AVAILABLE'] ?? 0} xe sẵn sàng',
              icon: Icons.directions_car_rounded,
              color: AppColors.primary,
            ),
            _KpiCard(
              title: 'Đơn đặt xe',
              count: '${summary.totalBookings}',
              subtitle: '${summary.bookingsByStatus['COMPLETED'] ?? 0} hoàn thành',
              icon: Icons.receipt_long_rounded,
              color: AppColors.tertiary,
            ),
            _KpiCard(
              title: 'Khách hàng',
              count: '${summary.totalUsers}',
              subtitle: '${summary.activeUsers} hoạt động',
              icon: Icons.people_alt_rounded,
              color: AppColors.success,
            ),
            _KpiCard(
              title: 'Chờ duyệt',
              count: '${summary.bookingsByStatus['PENDING'] ?? 0}',
              subtitle: 'Cần xử lý ngay',
              icon: Icons.pending_actions_rounded,
              color: AppColors.warning,
            ),
          ],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String count;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.count,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                count,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              Flexible(
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
