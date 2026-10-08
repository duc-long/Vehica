import 'package:flutter/material.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/features/dashboard/domain/entities/dashboard_summary_entity.dart';

/// Section showing Fleet and Booking status distributions side-by-side or stacked.
class AdminDistributionSection extends StatelessWidget {
  final DashboardSummaryEntity summary;

  const AdminDistributionSection({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: AdminFleetDistributionCard(summary: summary)),
              const SizedBox(width: 14),
              Expanded(child: AdminBookingDistributionCard(summary: summary)),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminFleetDistributionCard(summary: summary),
            const SizedBox(height: 14),
            AdminBookingDistributionCard(summary: summary),
          ],
        );
      },
    );
  }
}

/// Card breaking down the vehicles by their status (Available, Rented, Maintenance, Inactive).
class AdminFleetDistributionCard extends StatelessWidget {
  final DashboardSummaryEntity summary;

  const AdminFleetDistributionCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Phân bổ trạng thái đội xe',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Tổng: ${summary.totalVehicles} xe',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final countPerRow = constraints.maxWidth > 520 ? 4 : 2;
              final itemWidth = (constraints.maxWidth - ((countPerRow - 1) * 8)) / countPerRow;

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildStatTile(
                    width: itemWidth,
                    label: 'Sẵn sàng',
                    count: summary.vehiclesByStatus['AVAILABLE'] ?? 0,
                    color: AppColors.success,
                    icon: Icons.check_circle_outline_rounded,
                    isDark: isDark,
                  ),
                  _buildStatTile(
                    width: itemWidth,
                    label: 'Đang cho thuê',
                    count: summary.vehiclesByStatus['RENTED'] ?? 0,
                    color: AppColors.primary,
                    icon: Icons.car_rental_rounded,
                    isDark: isDark,
                  ),
                  _buildStatTile(
                    width: itemWidth,
                    label: 'Bảo dưỡng',
                    count: summary.vehiclesByStatus['MAINTENANCE'] ?? 0,
                    color: AppColors.warning,
                    icon: Icons.build_circle_outlined,
                    isDark: isDark,
                  ),
                  _buildStatTile(
                    width: itemWidth,
                    label: 'Ngừng hoạt động',
                    count: summary.vehiclesByStatus['INACTIVE'] ?? 0,
                    color: AppColors.textDisabled,
                    icon: Icons.pause_circle_outline_rounded,
                    isDark: isDark,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required double width,
    required String label,
    required int count,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withValues(alpha: 0.22),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card breaking down bookings by status (Pending, Confirmed, Picked_Up, Completed, Cancelled).
class AdminBookingDistributionCard extends StatelessWidget {
  final DashboardSummaryEntity summary;

  const AdminBookingDistributionCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Phân bổ trạng thái đơn thuê',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Tổng: ${summary.totalBookings} đơn',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final countPerRow = constraints.maxWidth > 580
                  ? 5
                  : (constraints.maxWidth > 340 ? 3 : 2);
              final itemWidth = (constraints.maxWidth - ((countPerRow - 1) * 8)) / countPerRow;

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildStatTile(
                    width: itemWidth,
                    label: 'Chờ duyệt',
                    count: summary.bookingsByStatus['PENDING'] ?? 0,
                    color: AppColors.warning,
                    icon: Icons.pending_actions_rounded,
                    isDark: isDark,
                  ),
                  _buildStatTile(
                    width: itemWidth,
                    label: 'Đã xác nhận',
                    count: summary.bookingsByStatus['CONFIRMED'] ?? 0,
                    color: AppColors.primary,
                    icon: Icons.thumb_up_alt_outlined,
                    isDark: isDark,
                  ),
                  _buildStatTile(
                    width: itemWidth,
                    label: 'Đang thuê',
                    count: summary.bookingsByStatus['PICKED_UP'] ?? 0,
                    color: AppColors.tertiary,
                    icon: Icons.directions_car_rounded,
                    isDark: isDark,
                  ),
                  _buildStatTile(
                    width: itemWidth,
                    label: 'Hoàn thành',
                    count: summary.bookingsByStatus['COMPLETED'] ?? 0,
                    color: AppColors.success,
                    icon: Icons.check_circle_rounded,
                    isDark: isDark,
                  ),
                  _buildStatTile(
                    width: itemWidth,
                    label: 'Đã hủy',
                    count: summary.bookingsByStatus['CANCELLED'] ?? 0,
                    color: AppColors.error,
                    icon: Icons.cancel_outlined,
                    isDark: isDark,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required double width,
    required String label,
    required int count,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withValues(alpha: 0.22),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
