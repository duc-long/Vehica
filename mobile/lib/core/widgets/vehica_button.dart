import 'package:flutter/material.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';

enum VehicaButtonType { primary, secondary, outline, text, danger }

class VehicaButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final IconData? trailingIcon;
  final VehicaButtonType type;
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double fontSize;

  const VehicaButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.trailingIcon,
    this.type = VehicaButtonType.primary,
    this.width,
    this.height = 50,
    this.borderRadius = 16,
    this.padding,
    this.fontSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = onPressed != null && !isLoading;

    final defaultPadding = padding ?? const EdgeInsets.symmetric(horizontal: 20);

    Widget content = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == VehicaButtonType.outline || type == VehicaButtonType.text
                    ? AppColors.primaryLight
                    : Colors.white,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: fontSize + 3,
                  color: _getTextColor(isDark, isEnabled),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _getTextColor(isDark, isEnabled),
                    fontWeight: FontWeight.w700,
                    fontSize: fontSize,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                Icon(
                  trailingIcon,
                  size: fontSize + 3,
                  color: _getTextColor(isDark, isEnabled),
                ),
              ],
            ],
          );

    return SizedBox(
      width: width,
      height: height,
      child: _buildDecoratedButton(context, content, isDark, isEnabled, defaultPadding),
    );
  }

  Color _getTextColor(bool isDark, bool isEnabled) {
    if (!isEnabled) {
      return isDark ? AppColors.textDisabledDark : AppColors.textDisabled;
    }
    switch (type) {
      case VehicaButtonType.primary:
      case VehicaButtonType.danger:
        return Colors.white;
      case VehicaButtonType.secondary:
        return isDark ? Colors.white : AppColors.textPrimary;
      case VehicaButtonType.outline:
      case VehicaButtonType.text:
        return AppColors.primaryLight;
    }
  }

  Widget _buildDecoratedButton(
    BuildContext context,
    Widget content,
    bool isDark,
    bool isEnabled,
    EdgeInsetsGeometry defaultPadding,
  ) {
    Decoration decoration;

    switch (type) {
      case VehicaButtonType.primary:
        decoration = BoxDecoration(
          color: isEnabled
              ? AppColors.primary
              : (isDark ? AppColors.surfaceVariantDark : const Color(0xFFCBD5E1)),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        );
        break;

      case VehicaButtonType.secondary:
        decoration = BoxDecoration(
          color: isEnabled
              ? (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight)
              : (isDark ? AppColors.surfaceDark : AppColors.surfaceVariantLight),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1.2,
          ),
        );
        break;

      case VehicaButtonType.outline:
        decoration = BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isEnabled
                ? (isDark ? AppColors.primaryLight : AppColors.primary)
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: 1.5,
          ),
        );
        break;

      case VehicaButtonType.danger:
        decoration = BoxDecoration(
          color: isEnabled
              ? AppColors.error
              : (isDark ? AppColors.surfaceVariantDark : const Color(0xFFCBD5E1)),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.error.withValues(alpha: isDark ? 0.25 : 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        );
        break;

      case VehicaButtonType.text:
        decoration = const BoxDecoration(color: Colors.transparent);
        break;
    }

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: decoration,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: Colors.white.withValues(alpha: 0.18),
          highlightColor: Colors.white.withValues(alpha: 0.08),
          child: Container(
            padding: defaultPadding,
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );
  }
}

