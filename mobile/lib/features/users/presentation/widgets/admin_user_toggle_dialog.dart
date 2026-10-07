import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:vehica_mobile/features/users/presentation/controllers/user_admin_controller.dart';

class AdminUserToggleDialog {
  static Future<void> show(BuildContext context, WidgetRef ref, UserEntity user) async {
    final isBlocking = user.status == 'ACTIVE';
    final actionText = isBlocking ? 'Khóa tài khoản' : 'Mở khóa tài khoản';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isBlocking ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
              color: isBlocking ? AppColors.error : AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(actionText, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          isBlocking
              ? 'Bạn có chắc muốn khóa tài khoản "${user.fullName}" (${user.email})? Người dùng này sẽ không thể đăng nhập hoặc tạo đơn mới.'
              : 'Xác nhận mở khóa tài khoản cho "${user.fullName}" (${user.email})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isBlocking ? AppColors.error : AppColors.primary,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(actionText, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success =
        await ref.read(userAdminControllerProvider).toggleUserStatus(user);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? (isBlocking
                    ? 'Đã khóa tài khoản thành công'
                    : 'Đã mở khóa tài khoản thành công')
                : 'Lỗi cập nhật trạng thái người dùng',
          ),
        ),
      );
    }
  }
}
