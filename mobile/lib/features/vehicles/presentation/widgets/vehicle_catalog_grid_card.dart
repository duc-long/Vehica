import 'package:flutter/material.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/utils/formatters.dart';
import 'package:vehica_mobile/core/widgets/vehica_image.dart';
import 'package:vehica_mobile/core/widgets/vehica_status_chip.dart';
import 'package:vehica_mobile/features/vehicles/domain/entities/vehicle_entity.dart';

class VehicleCatalogGridCard extends StatelessWidget {
  final VehicleEntity vehicle;
  final bool isHot;
  final bool isNew;
  final VoidCallback onTap;

  const VehicleCatalogGridCard({
    super.key,
    required this.vehicle,
    this.isHot = false,
    this.isNew = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imgUrl = vehicle.primaryImageUrl ??
        (vehicle.images.isNotEmpty ? vehicle.images.first.imageUrl : '');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Category Badge & Status Chip (Consistent with List View)
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                      child: VehicaImage(
                        imageUrl: imgUrl,
                        fit: BoxFit.cover,
                        fallbackIcon: Icons.directions_car_rounded,
                      ),
                    ),
                  ),

                  // Top-Left Real Category Badge from DB (Matching List View)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: (isDark ? const Color(0xFF0F1218) : AppColors.darkPill)
                            .withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        vehicle.type.name,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Top-Right Status Chip (Matching List View)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: VehicaStatusChip(
                      status: vehicle.status,
                      type: VehicaChipType.vehicleStatus,
                    ),
                  ),
                ],
              ),
            ),

            // Content Section with Anti-Overflow and Complete Vehicle Specs
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title & Brand Model (Exact same info as List View)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${vehicle.brand} ${vehicle.model} · Đời ${vehicle.year}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    // Specs Badges Wrap (Matches List View specs)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        VehicleCatalogGridTag(
                          icon: Icons.airline_seat_recline_normal_rounded,
                          label: '${vehicle.seatCapacity} chỗ',
                          isDark: isDark,
                        ),
                        VehicleCatalogGridTag(
                          icon: Icons.confirmation_number_outlined,
                          label: vehicle.licensePlate,
                          isDark: isDark,
                        ),
                      ],
                    ),

                    // Price & Action Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            '${VehicaFormatters.formatCurrency(vehicle.pricePerDay)}/ngày',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: AppColors.primaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Đặt xe',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VehicleCatalogGridTag extends StatelessWidget {
  final IconData? icon;
  final String label;
  final bool isDark;

  const VehicleCatalogGridTag({
    super.key,
    this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: (isDark ? AppColors.borderDark : AppColors.borderLight).withValues(alpha: 0.6),
          width: 0.6,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 11,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
