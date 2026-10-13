// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// SCREEN       : S04 - Vehicle Detail Screen
// STYLE        : Dark Slate Luxury, Emerald Teal Accent (Enterprise Mobile UI)
// ARCHITECTURE : Clean Coordinator Page delegating to presentation widgets
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/widgets/vehica_back_button.dart';
import 'package:vehica_mobile/core/widgets/vehica_skeleton.dart';
import 'package:vehica_mobile/core/widgets/vehica_status_chip.dart';
import 'package:vehica_mobile/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:vehica_mobile/features/vehicles/presentation/controllers/vehicle_detail_controller.dart';
import 'package:vehica_mobile/features/vehicles/presentation/widgets/vehicle_detail_bottom_bar.dart';
import 'package:vehica_mobile/features/vehicles/presentation/widgets/vehicle_detail_features_section.dart';
import 'package:vehica_mobile/features/vehicles/presentation/widgets/vehicle_detail_gallery.dart';
import 'package:vehica_mobile/features/vehicles/presentation/widgets/vehicle_detail_location_card.dart';
import 'package:vehica_mobile/features/vehicles/presentation/widgets/vehicle_detail_specs_card.dart';

class VehicleDetailPage extends ConsumerWidget {
  final String vehicleId;

  const VehicleDetailPage({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final detailAsync = ref.watch(vehicleDetailControllerProvider(vehicleId));

    return detailAsync.when(
      data: (detailState) => _VehicleDetailContent(
        vehicle: detailState.vehicle,
        isDark: isDark,
      ),
      loading: () => const Scaffold(
        body: SafeArea(
          child: VehicleDetailSkeleton(),
        ),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(leading: const VehicaBackButton()),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                const SizedBox(height: 12),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VehicleDetailContent extends StatelessWidget {
  final VehicleEntity vehicle;
  final bool isDark;

  const _VehicleDetailContent({
    required this.vehicle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: const VehicaBackButton(),
        title: Text(
          vehicle.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Gallery Carousel with Thumbnails
            VehicleDetailGallery(
              vehicle: vehicle,
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // 2. Title, Meta & Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${vehicle.brand} • ${vehicle.year} • ${vehicle.licensePlate}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                VehicaStatusChip(
                  status: vehicle.status,
                  type: VehicaChipType.vehicleStatus,
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 3. Technical Specs Card
            VehicleDetailSpecsCard(
              vehicle: vehicle,
              isDark: isDark,
            ),

            // 4. Dynamic Features & Amenities Section (From Database)
            VehicleDetailFeaturesSection(
              features: vehicle.features,
              isDark: isDark,
            ),

            // 5. Description (if any)
            if (vehicle.description != null && vehicle.description!.trim().isNotEmpty) ...[
              Text(
                'Mô tả chi tiết',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Text(
                  vehicle.description!.trim(),
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 6. Hub Location & Operating Hours
            VehicleDetailLocationCard(isDark: isDark),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: VehicleDetailBottomBar(
        vehicle: vehicle,
        isDark: isDark,
      ),
    );
  }
}
