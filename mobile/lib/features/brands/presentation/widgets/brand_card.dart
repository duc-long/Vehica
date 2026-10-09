import 'package:flutter/material.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/widgets/vehica_badge.dart';
import 'package:vehica_mobile/core/widgets/vehica_image.dart';
import 'package:vehica_mobile/features/brands/domain/entities/brand_entity.dart';

class BrandCard extends StatelessWidget {
  final BrandEntity brand;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BrandCard({
    super.key,
    required this.brand,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
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
      child: Row(
        children: [
          // Logo
          Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: VehicaImage(
              imageUrl: brand.logoUrl,
              fit: BoxFit.contain,
              fallbackIcon: Icons.directions_car_rounded,
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        brand.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (brand.isPopular)
                      const VehicaBadge(
                        label: 'Phổ biến',
                        color: AppColors.primary,
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${brand.country ?? "N/A"} • ${brand.offerCount} xe • Thứ tự: ${brand.displayOrder}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Actions
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: AppColors.primary,
            tooltip: 'Sửa hãng xe',
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            color: AppColors.error,
            tooltip: 'Xóa hãng xe',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
