import 'package:flutter/material.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/features/vehicles/domain/entities/vehicle_entity.dart';

class VehicleDetailSpecsCard extends StatelessWidget {
  final VehicleEntity vehicle;
  final bool isDark;

  const VehicleDetailSpecsCard({
    super.key,
    required this.vehicle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thông số kỹ thuật',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _QuickSpecTile(
                icon: Icons.airline_seat_recline_normal_rounded,
                label: '${vehicle.seatCapacity} Chỗ',
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _QuickSpecTile(
                icon: Icons.directions_car_rounded,
                label: vehicle.type.name,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _QuickSpecTile(
                icon: Icons.confirmation_number_outlined,
                label: vehicle.licensePlate,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _QuickSpecTile(
                icon: Icons.calendar_today_outlined,
                label: 'Năm ${vehicle.year}',
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _QuickSpecTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _QuickSpecTile({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primaryLight,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
