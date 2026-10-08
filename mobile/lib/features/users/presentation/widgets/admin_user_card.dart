import 'package:flutter/material.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/widgets/vehica_badge.dart';
import 'package:vehica_mobile/core/widgets/vehica_image.dart';
import 'package:vehica_mobile/features/auth/domain/entities/user_entity.dart';

class AdminUserCard extends StatelessWidget {
  final UserEntity user;
  final bool isDark;
  final VoidCallback onEditTap;
  final VoidCallback onToggleStatusTap;
  final VoidCallback onDeleteTap;

  const AdminUserCard({
    super.key,
    required this.user,
    required this.isDark,
    required this.onEditTap,
    required this.onToggleStatusTap,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.role.toUpperCase() == 'ADMIN';
    final isActive = user.status == 'ACTIVE';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isAdmin
                  ? AppColors.primaryMuted
                  : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight),
            ),
            child: ClipOval(
              child: VehicaImage(
                imageUrl: user.avatarUrl,
                fit: BoxFit.cover,
                fallbackIcon: isAdmin
                    ? Icons.admin_panel_settings_rounded
                    : Icons.person_rounded,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // User details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user.fullName,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (isAdmin)
                      VehicaBadge.admin()
                    else
                      const VehicaBadge(label: 'Khách'),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  user.email,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'SĐT: ${user.phone.isNotEmpty ? user.phone : "Chưa cập nhật"}',
                  style: TextStyle(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    fontSize: 11.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Actions (Edit, Status, Delete) with accessible hit region
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                color: AppColors.primary,
                tooltip: 'Sửa tài khoản',
                onPressed: onEditTap,
              ),
              IconButton(
                icon: Icon(
                  isActive
                      ? Icons.lock_open_rounded
                      : Icons.lock_outline_rounded,
                  size: 20,
                  color: isActive ? AppColors.primary : AppColors.error,
                ),
                tooltip: isActive ? 'Khóa tài khoản' : 'Mở khóa tài khoản',
                onPressed: onToggleStatusTap,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                color: AppColors.error,
                tooltip: 'Xóa tài khoản',
                onPressed: onDeleteTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
