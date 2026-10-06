// ==============================================================================
// VEHICA Design System — Skeleton Loading Widget
// Shimmer animation using pure AnimationController, no extra packages needed
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';

/// Skeleton shimmer wrapper — wraps child widget with shimmer wave effect.
class VehicaSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const VehicaSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius,
  });

  @override
  State<VehicaSkeleton> createState() => _VehicaSkeletonState();
}

class _VehicaSkeletonState extends State<VehicaSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: isDark
                  ? const [
                      Color(0xFF1B202B),
                      Color(0xFF262D3D),
                      Color(0xFF1B202B),
                    ]
                  : const [
                      AppColors.surfaceVariantLight,
                      Color(0xFFF4F6FC),
                      AppColors.surfaceVariantLight,
                    ],
            ),
          ),
        );
      },
    );
  }
}

// ── Pre-built skeleton card shapes ─────────────────────────────────────────────

/// Skeleton cho vehicle list card
class VehicleCardSkeleton extends StatelessWidget {
  const VehicleCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          const VehicaSkeleton(
            height: 140,
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    VehicaSkeleton(width: 140, height: 16),
                    VehicaSkeleton(width: 80, height: 16),
                  ],
                ),
                const SizedBox(height: 8),
                const VehicaSkeleton(width: 180, height: 12),
                const SizedBox(height: 10),
                Divider(
                  height: 1,
                  color: isDark ? AppColors.borderDark : AppColors.divider,
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    VehicaSkeleton(width: 60, height: 11),
                    SizedBox(width: 10),
                    VehicaSkeleton(width: 50, height: 11),
                    SizedBox(width: 10),
                    VehicaSkeleton(width: 60, height: 11),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton cho booking card
class BookingCardSkeleton extends StatelessWidget {
  const BookingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                VehicaSkeleton(width: 120, height: 14),
                VehicaSkeleton(
                  width: 70,
                  height: 22,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: isDark ? AppColors.borderDark : AppColors.divider,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const VehicaSkeleton(
                  width: 56,
                  height: 56,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    VehicaSkeleton(width: 140, height: 14),
                    SizedBox(height: 6),
                    VehicaSkeleton(width: 100, height: 11),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                VehicaSkeleton(width: 130, height: 12),
                VehicaSkeleton(width: 80, height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton cho booking detail page
class BookingDetailSkeleton extends StatelessWidget {
  const BookingDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          VehicaSkeleton(
            height: 70,
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          SizedBox(height: 16),
          VehicaSkeleton(width: 100, height: 14),
          SizedBox(height: 8),
          VehicaSkeleton(
            height: 90,
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          SizedBox(height: 16),
          VehicaSkeleton(width: 140, height: 14),
          SizedBox(height: 8),
          VehicaSkeleton(
            height: 160,
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          SizedBox(height: 16),
          VehicaSkeleton(width: 100, height: 14),
          SizedBox(height: 8),
          VehicaSkeleton(
            height: 60,
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          SizedBox(height: 16),
          VehicaSkeleton(width: 120, height: 14),
          SizedBox(height: 8),
          VehicaSkeleton(
            height: 120,
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ],
      ),
    );
  }
}

/// Skeleton cho vehicle detail page
class VehicleDetailSkeleton extends StatelessWidget {
  const VehicleDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const VehicaSkeleton(
            height: 220,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              VehicaSkeleton(width: 180, height: 22),
              VehicaSkeleton(width: 100, height: 22),
            ],
          ),
          const SizedBox(height: 8),
          const VehicaSkeleton(width: 220, height: 14),
          const SizedBox(height: 20),
          const VehicaSkeleton(width: 140, height: 14),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.15,
            children: List.generate(
              6,
              (_) => const VehicaSkeleton(
                height: 70,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const VehicaSkeleton(
            height: 72,
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          const SizedBox(height: 20),
          const VehicaSkeleton(
            height: 90,
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ],
      ),
    );
  }
}

/// Skeleton cho hot deal card (horizontal list)
class HotDealSkeleton extends StatelessWidget {
  const HotDealSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 14, bottom: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const VehicaSkeleton(
            height: 105,
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                VehicaSkeleton(width: 100, height: 13),
                SizedBox(height: 4),
                VehicaSkeleton(width: 70, height: 10),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    VehicaSkeleton(width: 60, height: 11),
                    VehicaSkeleton(
                      width: 65,
                      height: 22,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton cho brand chip (horizontal)
class BrandChipSkeleton extends StatelessWidget {
  const BrandChipSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const VehicaSkeleton(
            width: 36,
            height: 36,
            borderRadius: BorderRadius.all(Radius.circular(9)),
          ),
          const VehicaSkeleton(width: 50, height: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              VehicaSkeleton(width: 60, height: 12),
              SizedBox(height: 3),
              VehicaSkeleton(width: 40, height: 10),
            ],
          ),
        ],
      ),
    );
  }
}
