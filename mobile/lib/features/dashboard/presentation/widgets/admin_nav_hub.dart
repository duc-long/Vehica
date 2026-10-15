import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';

/// Navigation grid linking to the 5 core Admin modules: Vehicles, Brands, Users, Bookings, Fleet.
class AdminNavHub extends StatelessWidget {
  const AdminNavHub({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quản lý hệ thống',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 900
                ? 5
                : (constraints.maxWidth > 580 ? 3 : 2);
            final childAspectRatio = constraints.maxWidth > 900
                ? 1.9
                : (constraints.maxWidth > 580 ? 2.5 : 2.2);

            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: childAspectRatio,
              children: [
                _buildNavCard(
                  context,
                  Icons.directions_car_rounded,
                  'Quản lý xe',
                  'CRUD đội xe & Trạng thái',
                  '/admin/vehicles',
                ),
                _buildNavCard(
                  context,
                  Icons.branding_watermark_rounded,
                  'Hãng xe (Brand)',
                  'CRUD thương hiệu xe',
                  '/admin/brands',
                ),
                _buildNavCard(
                  context,
                  Icons.people_alt_rounded,
                  'Người dùng',
                  'CRUD tài khoản & Khóa/Mở',
                  '/admin/users',
                ),
                _buildNavCard(
                  context,
                  Icons.receipt_long_rounded,
                  'Đơn đặt xe',
                  'Duyệt & Quản lý đơn',
                  '/admin/bookings',
                ),
                _buildNavCard(
                  context,
                  Icons.event_available_rounded,
                  'Lịch đội xe',
                  'Khảo sát tính khả dụng',
                  '/admin/fleet',
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildNavCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    String route,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.push(route),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMuted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
