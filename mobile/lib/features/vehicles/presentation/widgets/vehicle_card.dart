// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// WIDGET             : VehicleCard (Vehicle Card for catalog & search)
// STYLE              : Dark Slate Luxury, Emerald Teal Accent
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/utils/formatters.dart';
import 'package:vehica_mobile/core/widgets/vehica_image.dart';
import 'package:vehica_mobile/core/widgets/vehica_status_chip.dart';
import 'package:vehica_mobile/features/vehicles/domain/entities/vehicle_entity.dart';

class VehicleCard extends StatelessWidget {
  final VehicleEntity vehicle;
  final VoidCallback onTap;
  final bool isNew;
  final bool isEV;
  final EdgeInsetsGeometry? margin;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onTap,
    this.isNew = false,
    this.isEV = false,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imgUrl = vehicle.primaryImageUrl ??
        (vehicle.images.isNotEmpty ? vehicle.images.first.imageUrl : '');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image Section with Status & Type Badges ─────────────────────
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    width: double.infinity,
                    color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                    child: VehicaImage(
                      imageUrl: imgUrl,
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.directions_car_outlined,
                    ),
                  ),
                ),

                // Top-Right Status Chip
                Positioned(
                  top: 12,
                  right: 12,
                  child: VehicaStatusChip(
                    status: vehicle.status,
                    type: VehicaChipType.vehicleStatus,
                  ),
                ),

                // Top-Left Real Category Badge from DB
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: (isDark ? const Color(0xFF0F1218) : AppColors.darkPill)
                          .withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      vehicle.type.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Info Section ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Brand Model
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicle.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${vehicle.brand} ${vehicle.model} · Đời ${vehicle.year}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Specs Grid (Clean 3 specs)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _SpecItem(
                        icon: Icons.airline_seat_recline_normal_rounded,
                        label: '${vehicle.seatCapacity} chỗ',
                        isDark: isDark,
                      ),
                      _SpecItem(
                        icon: Icons.directions_car_rounded,
                        label: vehicle.type.name,
                        isDark: isDark,
                      ),
                      _SpecItem(
                        icon: Icons.confirmation_number_outlined,
                        label: vehicle.licensePlate,
                        isDark: isDark,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  Divider(
                    height: 1,
                    color: isDark ? AppColors.borderDark : AppColors.divider,
                  ),
                  const SizedBox(height: 10),

                  // Bottom Price & Action Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Giá thuê niêm yết',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 1),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    VehicaFormatters.formatCurrency(vehicle.pricePerDay),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      color: AppColors.primaryLight,
                                    ),
                                  ),
                                  Text(
                                    ' / ngày',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Chi tiết & Đặt',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.1,
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _SpecItem({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: AppColors.primaryLight,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
