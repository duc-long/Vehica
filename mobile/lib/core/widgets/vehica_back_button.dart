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
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: GestureDetector(
        onTap: onPressed ?? () => Navigator.of(context).maybePop(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariantLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            size: 18,
            color: iconColor ?? AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
