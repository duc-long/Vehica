import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/widgets/vehica_button.dart';
import 'package:vehica_mobile/core/widgets/vehica_image_picker_field.dart';
import 'package:vehica_mobile/core/widgets/vehica_text_field.dart';
import 'package:vehica_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:vehica_mobile/features/users/presentation/controllers/user_admin_controller.dart';

class AdminUserFormSheet {
  static void show(BuildContext context, WidgetRef ref, [UserEntity? user]) {
    final isEditing = user != null;
    final emailController = TextEditingController(text: user?.email ?? '');
    final nameController = TextEditingController(text: user?.fullName ?? '');
    final phoneController = TextEditingController(text: user?.phone ?? '');
    final passController = TextEditingController();
    final avatarController = TextEditingController(text: user?.avatarUrl ?? '');

    String selectedRole = user?.role ?? 'USER';
    String selectedStatus = user?.status ?? 'ACTIVE';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              top: 20,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'Sửa thông tin tài khoản' : 'Tạo tài khoản người dùng',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Email
                  VehicaTextField(
                    label: 'Email tài khoản *',
                    hint: 'example@vehica.com',
                    controller: emailController,
                    readOnly: isEditing,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),

                  // Password (only for new user)
                  if (!isEditing) ...[
                    VehicaTextField(
                      label: 'Mật khẩu khởi tạo *',
                      hint: 'Tối thiểu 8 ký tự',
                      controller: passController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Full Name
                  VehicaTextField(
                    label: 'Họ và tên *',
                    hint: 'Nguyễn Văn A',
                    controller: nameController,
                  ),
                  const SizedBox(height: 12),

                  // Phone Number
                  VehicaTextField(
                    label: 'Số điện thoại *',
                    hint: '0901234567',
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),

                  // Avatar Image Picker
                  VehicaImagePickerField(
                    label: 'Ảnh đại diện tài khoản',
                    urlController: avatarController,
                    folder: 'avatars',
                  ),
                  const SizedBox(height: 12),

                  // Role & Status Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Phân quyền *',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: selectedRole,
                                  items: const [
                                    DropdownMenuItem(value: 'USER', child: Text('Khách hàng')),
                                    DropdownMenuItem(value: 'ADMIN', child: Text('Quản trị viên')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) setModalState(() => selectedRole = val);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trạng thái *',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: selectedStatus,
                                  items: const [
                                    DropdownMenuItem(value: 'ACTIVE', child: Text('Hoạt động')),
                                    DropdownMenuItem(value: 'BLOCKED', child: Text('Đã khóa')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) setModalState(() => selectedStatus = val);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  VehicaButton(
                    text: isEditing ? 'Lưu cập nhật' : 'Tạo tài khoản',
                    onPressed: () async {
                      if (nameController.text.trim().isEmpty ||
                          phoneController.text.trim().isEmpty ||
                          (!isEditing && (emailController.text.trim().isEmpty || passController.text.trim().isEmpty))) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vui lòng điền đầy đủ các thông tin bắt buộc (*)')),
                        );
                        return;
                      }

                      Navigator.of(ctx).pop();

                      bool ok;
                      if (isEditing) {
                        ok = await ref.read(userAdminControllerProvider).updateUser(
                              user.id,
                              {
                                'fullName': nameController.text.trim(),
                                'phone': phoneController.text.trim(),
                                'avatarUrl': avatarController.text.trim().isNotEmpty ? avatarController.text.trim() : null,
                                'role': selectedRole,
                                'status': selectedStatus,
                              },
                            );
                      } else {
                        ok = await ref.read(userAdminControllerProvider).createUser(
                              {
                                'email': emailController.text.trim(),
                                'password': passController.text.trim(),
                                'fullName': nameController.text.trim(),
                                'phone': phoneController.text.trim(),
                                'role': selectedRole,
                                'status': selectedStatus,
                              },
                            );
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? (isEditing ? 'Đã cập nhật thông tin người dùng' : 'Đã tạo tài khoản thành công')
                                  : 'Thao tác thất bại. Vui lòng kiểm tra lại.',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
