import 'package:flutter/material.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';

/// Light & Dark color schemes — Slate-neutral, Indigo accent
class AppColorSchemes {
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryMuted,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFCCFBF1),
    onSecondaryContainer: Color(0xFF134E4A),
    tertiary: AppColors.tertiary,
    onTertiary: Colors.white,
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: AppColors.errorBg,
    onErrorContainer: Color(0xFF7F1D1D),
    surface: AppColors.surfaceLight,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surfaceVariantLight,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.borderLight,
    outlineVariant: AppColors.divider,
    shadow: Color(0x14000000),
    inverseSurface: AppColors.darkPill,
    onInverseSurface: Colors.white,
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryLight,
    onPrimary: Color(0xFF0B1033),
    primaryContainer: AppColors.primaryDark,
    onPrimaryContainer: Colors.white,
    secondary: AppColors.secondaryLight,
    onSecondary: Color(0xFF0F2726),
    secondaryContainer: Color(0xFF1A3530),
    onSecondaryContainer: Color(0xFFF0FDFA),
    tertiary: Color(0xFFFBBF24),
    onTertiary: Color(0xFF2C1A00),
    error: Color(0xFFF87171),
    onError: Color(0xFF450A0A),
    errorContainer: Color(0xFF7F1D1D),
    onErrorContainer: Color(0xFFFEE2E2),
    surface: AppColors.surfaceDark,
    onSurface: Color(0xFFF0F2F8),
    surfaceContainerHighest: AppColors.surfaceVariantDark,
    onSurfaceVariant: Color(0xFF8892AB),
    outline: AppColors.borderDark,
    outlineVariant: Color(0xFF2A3045),
    shadow: Colors.black54,
    inverseSurface: Color(0xFFF1F3F9),
    onInverseSurface: AppColors.textPrimary,
  );
}
