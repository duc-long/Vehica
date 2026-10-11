import 'package:flutter/material.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';

/// Horizontal status filter chip bar for admin/user booking list pages.
class BookingStatusFilterBar extends StatelessWidget {
  final String? currentFilter;
  final ValueChanged<String?> onFilterChanged;

  const BookingStatusFilterBar({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  static const List<String> statuses = [
    'PENDING',
    'CONFIRMED',
    'PICKED_UP',
    'COMPLETED',
    'CANCELLED',
  ];

  static String statusLabel(String s) {
    const map = {
      'PENDING': 'Chờ xác nhận',
      'CONFIRMED': 'Đã xác nhận',
      'PICKED_UP': 'Đang thuê',
      'COMPLETED': 'Hoàn thành',
      'CANCELLED': 'Đã hủy',
    };
    return map[s] ?? s;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              children: [
                _StatusFilterChip(
                  label: 'Tất cả',
                  selected: currentFilter == null,
                  onTap: () => onFilterChanged(null),
                ),
                const SizedBox(width: 8),
                ...statuses.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _StatusFilterChip(
                      label: statusLabel(s),
                      selected: currentFilter == s,
                      onTap: () => onFilterChanged(s),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? AppColors.borderDark : AppColors.divider,
          ),
        ],
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StatusFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected
                ? Colors.white
                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
