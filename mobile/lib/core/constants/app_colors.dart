import 'package:flutter/material.dart';

/// VEHICA Design System — Palette: Slate-neutral, Indigo accent, No gradient, No glare
class AppColors {
  // ─── Brand Accent (Emerald Teal - matching reference UI) ───────────────────
  static const Color primary = Color(0xFF107C74); // Vibrant emerald teal
  static const Color primaryLight = Color(0xFF14B8A6); // Teal highlight
  static const Color primaryDark = Color(0xFF0F635D);
  static const Color primaryMuted = Color(0xFF163C38); // Dark teal container / pill
  static const Color primaryMutedLight = Color(0xFFCCFBF1); // Light teal tint

  // ─── Dark Pill / CTA ─────────────────────────────────────────────────────────
  static const Color darkPill = Color(0xFF1E2430);
  static const Color darkPillHover = Color(0xFF283040);
  static const Color darkCard = Color(0xFF1A1F29);
  static const Color darkCardBorder = Color(0xFF283142);

  // ─── Surface & Background (Light) ────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF1F4F8);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFE8EDF4);
  static const Color surfaceElevatedLight = Color(0xFFF8FAFC);

  // ─── Surface & Background (Dark - Slate Luxury) ──────────────────────────────
  static const Color backgroundDark = Color(0xFF0F1216); // Deep slate black
  static const Color surfaceDark = Color(0xFF171B22); // Card surface
  static const Color surfaceVariantDark = Color(0xFF1F242F); // Pill / Input container
  static const Color surfaceElevatedDark = Color(0xFF262C3A);

  // ─── Text / On-surface ───────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F1220);
  static const Color textSecondary = Color(0xFF5A6279);
  static const Color textDisabled = Color(0xFFADB5CC);

  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textDisabledDark = Color(0xFF64748B);

  // ─── Border / Divider ────────────────────────────────────────────────────────
  static const Color borderLight = Color(0xFFDDE3EE);
  static const Color borderDark = Color(0xFF283142);
  static const Color divider = Color(0xFF242C3C);

  // ─── Secondary / Teal & Accent ───────────────────────────────────────────────
  static const Color secondary = Color(0xFF14B8A6);
  static const Color secondaryLight = Color(0xFF2DD4BF);
  static const Color accentGold = Color(0xFFF59E0B); // Rating star gold

  // ─── Tertiary / Amber ────────────────────────────────────────────────────────
  static const Color tertiary = Color(0xFFD97706);

  // ─── Status Feedback ─────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color successBg = Color(0xFF064E3B);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFF451A03);
  static const Color error = Color(0xFFEF4444);
  static const Color errorBg = Color(0xFF450A0A);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoBg = Color(0xFF172554);

  // ─── Legacy aliases (keep for backward compat) ───────────────────────────────
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warningLight = Color(0xFFFEF3C7);

  // ─── Glass / Overlay ─────────────────────────────────────────────────────────
  static const Color glassWhite = Color(0x18FFFFFF);
  static const Color glassWhiteBorder = Color(0x28FFFFFF);
  static const Color glassDark = Color(0x80111419);

  // ─── Vehicle Status ──────────────────────────────────────────────────────────
  static const Color statusAvailable = Color(0xFF10B981);
  static const Color statusRented = Color(0xFF3B82F6);
  static const Color statusMaintenance = Color(0xFFF59E0B);
  static const Color statusInactive = Color(0xFF64748B);

  // ─── Booking Status ──────────────────────────────────────────────────────────
  static const Color bookingPending = Color(0xFFF59E0B);
  static const Color bookingConfirmed = Color(0xFF3B82F6);
  static const Color bookingPickedUp = Color(0xFF8B5CF6);
  static const Color bookingCompleted = Color(0xFF10B981);
  static const Color bookingCancelled = Color(0xFFEF4444);
}
