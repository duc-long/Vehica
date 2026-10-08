import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/features/vehicles/domain/entities/vehicle_entity.dart';

class VehicleCatalogFilterBar extends StatelessWidget {
  final AsyncValue<List<VehicleTypeEntity>> typesState;
  final String? selectedTypeId;
  final int? selectedSeatCapacity;
  final List<int> availableSeatCapacities;
  final ValueChanged<String?> onTypeSelected;
  final ValueChanged<int?> onSeatCapacitySelected;
  final bool? isDark;

  const VehicleCatalogFilterBar({
    super.key,
    required this.typesState,
    required this.selectedTypeId,
    required this.selectedSeatCapacity,
    this.availableSeatCapacities = const [4, 5, 7],
    required this.onTypeSelected,
    required this.onSeatCapacitySelected,
    this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final dark = isDark ?? (Theme.of(context).brightness == Brightness.dark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Horizontal Type Filter Pills (From DB vehicle_types)
        typesState.when(
          data: (types) => SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: types.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isSelected = selectedTypeId == null;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterPill(
                      label: 'Tất cả phân khúc',
                      selected: isSelected,
                      isDark: dark,
                      onTap: () => onTypeSelected(null),
                    ),
                  );
                }
                final type = types[index - 1];
                final isSelected = selectedTypeId == type.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterPill(
                    label: type.name,
                    selected: isSelected,
                    isDark: dark,
                    onTap: () => onTypeSelected(isSelected ? null : type.id),
                  ),
                );
              },
            ),
          ),
          loading: () => const SizedBox(height: 38),
          error: (_, __) => const SizedBox.shrink(),
        ),

        const SizedBox(height: 10),

        // Horizontal Dynamic Seat Capacity Pills (From vehicles in DB)
        if (availableSeatCapacities.isNotEmpty)
          SizedBox(
            height: 34,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: availableSeatCapacities.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isSelected = selectedSeatCapacity == null;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _SeatPill(
                      label: 'Tất cả số chỗ',
                      selected: isSelected,
                      isDark: dark,
                      onTap: () => onSeatCapacitySelected(null),
                    ),
                  );
                }
                final seats = availableSeatCapacities[index - 1];
                final isSelected = selectedSeatCapacity == seats;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _SeatPill(
                    label: '$seats chỗ',
                    selected: isSelected,
                    isDark: dark,
                    onTap: () => onSeatCapacitySelected(isSelected ? null : seats),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: selected ? 1.5 : 1.0,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? Colors.white
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

class _SeatPill extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _SeatPill({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight)
              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.primaryLight
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? AppColors.primaryLight
                  : (isDark ? AppColors.textDisabledDark : AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}
