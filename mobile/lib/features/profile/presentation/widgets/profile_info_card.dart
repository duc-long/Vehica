import 'package:flutter/material.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/utils/validators.dart';
import 'package:vehica_mobile/core/widgets/vehica_button.dart';
import 'package:vehica_mobile/core/widgets/vehica_text_field.dart';
import 'package:vehica_mobile/features/auth/domain/entities/user_entity.dart';

class ProfileInfoCard extends StatelessWidget {
  final UserEntity user;
  final TextEditingController fullNameController;
  final TextEditingController phoneController;
  final bool isEditing;
  final bool isSaving;
  final VoidCallback onSave;
  final bool isDark;

  const ProfileInfoCard({
    super.key,
    required this.user,
    required this.fullNameController,
    required this.phoneController,
    required this.isEditing,
    required this.isSaving,
    required this.onSave,
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
                controller: fullNameController,
                readOnly: !isEditing,
                prefixIcon: Icons.person_outline_rounded,
                validator: VehicaValidators.validateFullName,
              ),
              const SizedBox(height: 14),
              VehicaTextField(
                label: 'Số điện thoại liên hệ',
                controller: phoneController,
                readOnly: !isEditing,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: VehicaValidators.validatePhone,
              ),
              if (isEditing) ...[
                const SizedBox(height: 18),
                VehicaButton(
                  text: 'Lưu thay đổi',
                  isLoading: isSaving,
                  onPressed: onSave,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
