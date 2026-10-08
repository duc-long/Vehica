import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/features/vehicles/domain/entities/vehicle_entity.dart';

enum VehicleSortOption {
  featured('Đề xuất'),
  priceAsc('Giá tăng dần'),
  priceDesc('Giá giảm dần'),
  nameAsc('Tên A-Z');

  final String label;
  const VehicleSortOption(this.label);
}

class VehicleCatalogToolbar extends StatelessWidget {
  final AsyncValue<List<BrandEntity>> brandsState;
  final String? selectedBrand;
  final ValueChanged<String?> onBrandSelected;
  final VehicleSortOption sortOption;
  final ValueChanged<VehicleSortOption> onSortChanged;
  final bool isGridView;
  final VoidCallback onToggleView;

  const VehicleCatalogToolbar({
    super.key,
    required this.brandsState,
    required this.selectedBrand,
    required this.onBrandSelected,
    required this.sortOption,
    required this.onSortChanged,
    required this.isGridView,
    required this.onToggleView,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: brandsState.when(
        data: (brands) {
          final brandNames = ['Tất cả hãng', ...brands.map((b) => b.name)];
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                // Brand filter popup
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: PopupMenuButton<String>(
                    initialValue: selectedBrand ?? 'Tất cả hãng',
                    constraints: const BoxConstraints(maxHeight: 280, minWidth: 160),
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (val) {
                      onBrandSelected(val == 'Tất cả hãng' ? null : val);
                    },
                    itemBuilder: (context) => brandNames.map((name) {
                      final isCurrent = selectedBrand == name ||
                          (selectedBrand == null && name == 'Tất cả hãng');
                      return PopupMenuItem<String>(
                        value: name,
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                            color: isCurrent
                                ? AppColors.primaryLight
                                : (isDark ? Colors.white : AppColors.textPrimary),
                          ),
                        ),
                      );
                    }).toList(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.directions_car_filled_outlined,
                          size: 15,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          selectedBrand ?? 'Tất cả hãng',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Sort dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: PopupMenuButton<VehicleSortOption>(
                    initialValue: sortOption,
                    constraints: const BoxConstraints(maxHeight: 280, minWidth: 160),
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: onSortChanged,
                    itemBuilder: (context) => VehicleSortOption.values.map((opt) {
                      final isCurrent = sortOption == opt;
                      return PopupMenuItem<VehicleSortOption>(
                        value: opt,
                        child: Text(
                          opt.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                            color: isCurrent
                                ? AppColors.primaryLight
                                : (isDark ? Colors.white : AppColors.textPrimary),
                          ),
                        ),
                      );
                    }).toList(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sort_rounded,
                          size: 15,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          sortOption.label,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Grid / List toggle button
                GestureDetector(
                  onTap: onToggleView,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                          size: 16,
                          color: AppColors.primaryLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isGridView ? 'Dạng danh sách' : 'Dạng lưới',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const SizedBox(height: 24),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}
