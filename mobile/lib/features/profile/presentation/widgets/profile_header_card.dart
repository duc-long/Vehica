import 'package:flutter/material.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/widgets/vehica_image.dart';
import 'package:vehica_mobile/core/widgets/vehica_status_chip.dart';
import 'package:vehica_mobile/features/auth/domain/entities/user_entity.dart';

class ProfileHeaderCard extends StatelessWidget {
  final UserEntity user;
  final bool isUploadingAvatar;
  final bool isEditing;
  final VoidCallback onTapAvatar;
  final VoidCallback onToggleEdit;
  final bool isDark;

  const ProfileHeaderCard({
    super.key,
    required this.user,
    required this.isUploadingAvatar,
    required this.isEditing,
    required this.onTapAvatar,
    required this.onToggleEdit,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvatar = user.avatarUrl != null && user.avatarUrl!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar with Camera Edit Badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: isUploadingAvatar ? null : onTapAvatar,
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      hasAvatar
                          ? VehicaImage(
                              imageUrl: user.avatarUrl!,
                              fit: BoxFit.cover,
                              width: 84,
                              height: 84,
                              fallbackIcon: Icons.person_rounded,
                            )
                          : Center(
                              child: Text(
                                user.fullName.isNotEmpty
                                    ? user.fullName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                      if (isUploadingAvatar)
                        Container(
                          width: 84,
                          height: 84,
                          color: Colors.black54,
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: GestureDetector(
                  onTap: isUploadingAvatar ? null : onTapAvatar,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            user.fullName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            user.email,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              VehicaStatusChip(status: user.role),
              const SizedBox(width: 8),
              VehicaStatusChip(status: user.status, type: VehicaChipType.userStatus),
            ],
          ),
          const SizedBox(height: 14),
          // Thumb-friendly Edit Button inside profile card
          SizedBox(
            height: 38,
            child: OutlinedButton.icon(
              onPressed: onToggleEdit,
              icon: Icon(
                isEditing ? Icons.close_rounded : Icons.edit_note_rounded,
                size: 18,
                color: isEditing ? AppColors.error : AppColors.primaryLight,
              ),
              label: Text(
                isEditing ? 'Hủy chỉnh sửa' : 'Chỉnh sửa thông tin',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isEditing
                      ? AppColors.error
                      : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isEditing
                      ? AppColors.error.withValues(alpha: 0.5)
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
