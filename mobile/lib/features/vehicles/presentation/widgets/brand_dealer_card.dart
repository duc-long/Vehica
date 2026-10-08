import 'package:flutter/material.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/widgets/vehica_image.dart';

class BrandDealerCard extends StatelessWidget {
  final String name;
  final String offerCount;
  final String? logoUrl;
  final Color badgeColor;
  final IconData badgeIcon;
  final VoidCallback onTap;

  const BrandDealerCard({
    super.key,
    required this.name,
    required this.offerCount,
    this.logoUrl,
    this.badgeColor = AppColors.darkPill,
    this.badgeIcon = Icons.directions_car_rounded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasLogo = logoUrl != null && logoUrl!.trim().isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 124,
        margin: const EdgeInsets.only(right: 12, bottom: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo / Icon badge
            if (hasLogo)
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceVariantDark : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: VehicaImage(
                  imageUrl: logoUrl,
                  fit: BoxFit.contain,
                  borderRadius: BorderRadius.circular(6),
                  fallbackIcon: badgeIcon,
                ),
              )
            else
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Center(
                  child: Icon(
                    badgeIcon,
                    color: AppColors.primaryLight,
                    size: 22,
                  ),
                ),
              ),

            // Name & offers count
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    letterSpacing: -0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    offerCount,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
