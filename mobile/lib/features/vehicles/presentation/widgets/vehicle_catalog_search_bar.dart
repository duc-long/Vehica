import 'package:flutter/material.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';

class VehicleCatalogSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool? isDark;

  const VehicleCatalogSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final dark = isDark ?? (Theme.of(context).brightness == Brightness.dark);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Container(
        decoration: BoxDecoration(
          color: dark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: dark ? AppColors.borderDark : AppColors.borderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.2 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: dark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Tìm kiếm theo tên, hãng, dòng xe...',
            hintStyle: TextStyle(
              color: dark ? AppColors.textDisabledDark : AppColors.textDisabled,
              fontSize: 14,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 13,
            ),
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search_rounded,
              color: dark ? AppColors.textDisabledDark : AppColors.textSecondary,
              size: 20,
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: onClear,
                  )
                : null,
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
