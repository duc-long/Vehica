import 'package:flutter/material.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/utils/formatters.dart';
import 'package:vehica_mobile/core/widgets/vehica_image.dart';
import 'package:vehica_mobile/core/widgets/vehica_status_chip.dart';
import 'package:vehica_mobile/features/vehicles/domain/entities/vehicle_entity.dart';

class AdminVehicleCard extends StatelessWidget {
  final VehicleEntity vehicle;
  final bool isDark;
  final VoidCallback onStatusTap;
  final VoidCallback onEditTap;
  final VoidCallback onDeleteTap;

  const AdminVehicleCard({
    super.key,
    required this.vehicle,
    required this.isDark,
    required this.onStatusTap,
    required this.onEditTap,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                ),
                child: VehicaImage(
                  imageUrl: vehicle.primaryImageUrl,
                  borderRadius: BorderRadius.circular(12),
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),

              // Main info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            vehicle.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${vehicle.brand} ${vehicle.model} • ${vehicle.seatCapacity} chỗ • Năm ${vehicle.year}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Biển số: ${vehicle.licensePlate} • ${vehicle.type.name}',
                      style: TextStyle(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Status chip
              VehicaStatusChip(
                status: vehicle.status,
                type: VehicaChipType.vehicleStatus,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Bottom actions bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${VehicaFormatters.formatCurrency(vehicle.pricePerDay)}/ngày',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Row(
                children: [
                  // Status button
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                      side: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.tune_rounded, size: 14, color: AppColors.primary),
                    label: const Text('Trạng thái', style: TextStyle(fontSize: 11.5, color: AppColors.primary)),
                    onPressed: onStatusTap,
                  ),
                  const SizedBox(width: 6),

                  // Edit button
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    color: AppColors.primary,
                    tooltip: 'Sửa xe',
                    onPressed: onEditTap,
                  ),
                  const SizedBox(width: 4),

                  // Delete button
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 20),
                    color: AppColors.error,
                    tooltip: 'Xóa xe',
                    onPressed: onDeleteTap,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
