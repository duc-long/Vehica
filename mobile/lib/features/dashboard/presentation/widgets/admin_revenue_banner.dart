import 'package:flutter/material.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/utils/formatters.dart';
import 'package:vehica_mobile/features/dashboard/domain/entities/dashboard_summary_entity.dart';

/// Banner displaying estimated total revenue and sub-metrics (total orders, rented vehicles, occupancy rate).
class AdminRevenueBanner extends StatelessWidget {
  final DashboardSummaryEntity summary;

  const AdminRevenueBanner({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final rentedCount = summary.vehiclesByStatus['RENTED'] ?? 0;
    final totalVehicles = summary.totalVehicles;
    final occupancy = totalVehicles > 0
        ? (rentedCount / totalVehicles * 100).toStringAsFixed(1)
        : '0';

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF132228),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.monetization_on_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tổng doanh thu hệ thống',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      VehicaFormatters.formatCurrency(summary.totalEstimatedRevenue),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRevenueSubMetric(
                  icon: Icons.receipt_long_rounded,
                  label: 'Tổng đơn',
                  value: '${summary.totalBookings}',
                ),
                Container(width: 1, height: 24, color: Colors.white24),
                _buildRevenueSubMetric(
                  icon: Icons.directions_car_rounded,
                  label: 'Xe đang thuê',
                  value: '$rentedCount',
                ),
                Container(width: 1, height: 24, color: Colors.white24),
                _buildRevenueSubMetric(
                  icon: Icons.trending_up_rounded,
                  label: 'Tỷ lệ lấp đầy',
                  value: '$occupancy%',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueSubMetric({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: Colors.white70),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
