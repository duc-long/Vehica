import 'package:flutter/material.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/widgets/vehica_text_field.dart';
import 'package:vehica_mobile/features/auth/domain/entities/user_entity.dart';

class ProfileInfoCard extends StatelessWidget {
  final UserEntity user;
  final bool isDark;

  const ProfileInfoCard({
    super.key,
    required this.user,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thông tin cá nhân',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              VehicaTextField(
                label: 'Địa chỉ Email',
                initialValue: user.email,
                readOnly: true,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 14),
              VehicaTextField(
                label: 'Họ và tên',
                initialValue: user.fullName,
                readOnly: true,
                prefixIcon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 14),
              VehicaTextField(
                label: 'Số điện thoại liên hệ',
                initialValue: user.phone.isNotEmpty ? user.phone : 'Chưa cập nhật',
                readOnly: true,
                prefixIcon: Icons.phone_outlined,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
