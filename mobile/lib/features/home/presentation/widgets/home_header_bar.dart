import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/widgets/vehica_image.dart';
import 'package:vehica_mobile/features/auth/domain/entities/user_entity.dart';

class HomeHeaderBar extends StatelessWidget {
  final UserEntity? user;
  final bool isAdmin;
  final bool isDark;

  const HomeHeaderBar({
    super.key,
    required this.user,
    required this.isAdmin,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final userName = user?.fullName ?? 'Khách hàng';
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isNarrow = screenWidth < 340;
    final isVeryNarrow = screenWidth < 280;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isVeryNarrow ? 10 : (isNarrow ? 14 : 20),
        12,
        isVeryNarrow ? 10 : (isNarrow ? 14 : 20),
        8,
      ),
      child: Row(
        children: [
          // User Avatar & Greeting (Clickable to Profile)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.push('/profile'),
              child: Row(
                children: [
                  Container(
                    width: isNarrow ? 40 : 48,
                    height: isNarrow ? 40 : 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: user?.avatarUrl != null && user!.avatarUrl!.trim().isNotEmpty
                        ? VehicaImage(
                            imageUrl: user!.avatarUrl!,
                            fit: BoxFit.cover,
                            fallbackIcon: Icons.person_rounded,
                          )
                        : Center(
                            child: Text(
                              userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isNarrow ? 16 : 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(width: isNarrow ? 8 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xin chào 👋',
                          style: TextStyle(
                            fontSize: isNarrow ? 11 : 12,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: isNarrow ? 15 : 17,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                            letterSpacing: -0.2,
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
          // Admin Portal Shortcut (Only shown for Admin)
          if (isAdmin)
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.admin_panel_settings_outlined, size: 22),
                color: AppColors.primary,
                tooltip: 'Trang quản trị',
                onPressed: () => context.push('/admin/dashboard'),
              ),
            ),
        ],
      ),
    );
  }
}
