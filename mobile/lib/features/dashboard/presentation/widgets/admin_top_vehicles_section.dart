import 'package:flutter/material.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/utils/formatters.dart';
import 'package:vehica_mobile/core/widgets/vehica_image.dart';
import 'package:vehica_mobile/features/dashboard/domain/entities/dashboard_summary_entity.dart';

/// Leaderboard ranking the top rented vehicles by revenue and booking count.
class AdminTopVehiclesSection extends StatelessWidget {
  final DashboardSummaryEntity summary;

  const AdminTopVehiclesSection({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Xe được thuê nhiều nhất (Top Revenue)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Material(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: summary.topVehicles.isNotEmpty
              ? ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: summary.topVehicles.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                  itemBuilder: (context, index) {
                    final car = summary.topVehicles[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      leading: SizedBox(
                        width: 78,
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: index == 0
                                    ? AppColors.tertiary
                                    : (index == 1
                                        ? AppColors.primary
                                        : (isDark
                                            ? AppColors.surfaceVariantDark
                                            : AppColors.surfaceVariantLight)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  '#${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                    color: index < 2
                                        ? Colors.white
                                        : (isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimary),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 48,
                                height: 40,
                                child: VehicaImage(
                                  imageUrl: car.imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      title: Text(
                        car.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${car.brand} ${car.model} · ${car.bookingCount} lượt thuê',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                      trailing: Text(
                        VehicaFormatters.formatCurrency(car.totalRevenue),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    );
                  },
                )
              : Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Text(
                      'Chưa có dữ liệu thuê xe',
                      style: TextStyle(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
