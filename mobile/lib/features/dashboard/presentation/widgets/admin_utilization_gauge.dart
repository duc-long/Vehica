import 'package:flutter/material.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/features/dashboard/domain/entities/dashboard_summary_entity.dart';

/// Progress gauge showing fleet occupancy and status breakdown counts.
class AdminUtilizationGauge extends StatelessWidget {
  final DashboardSummaryEntity summary;

  const AdminUtilizationGauge({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = summary.totalVehicles;
    final rented = summary.vehiclesByStatus['RENTED'] ?? 0;
    final available = summary.vehiclesByStatus['AVAILABLE'] ?? 0;
    final maintenance = summary.vehiclesByStatus['MAINTENANCE'] ?? 0;
    final rate = total > 0 ? (rented / total) : 0.0;
    final percent = (rate * 100).toStringAsFixed(1);

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.pie_chart_rounded, size: 18, color: AppColors.tertiary),
                  const SizedBox(width: 8),
                  Text(
                    'Tỷ lệ lấp đầy đội xe (Utilization)',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$percent%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppColors.tertiary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: rate.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: isDark ? AppColors.surfaceVariantDark : AppColors.borderLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.tertiary),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🚗 Đang thuê: $rented xe',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.tertiary,
                ),
              ),
              Text(
                '🟢 Sẵn sàng: $available xe',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
              Text(
                '🔧 Bảo dưỡng: $maintenance xe',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
