// ==============================================================================
// VEHICA Design System — Custom Back Button
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';

/// Consistent back button — flat, bordered, modern.
/// Used automatically in all AppBars via theme.
class VehicaBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? iconColor;

  const VehicaBackButton({super.key, this.onPressed, this.iconColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: SizedBox(
        width: 38,
        height: 38,
        child: Material(
          color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed ?? () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 19,
                  color: iconColor ??
                      (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
