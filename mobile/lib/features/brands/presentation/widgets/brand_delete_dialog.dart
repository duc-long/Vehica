import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/features/brands/domain/entities/brand_entity.dart';
import 'package:vehica_mobile/features/brands/presentation/controllers/brand_admin_controller.dart';

class BrandDeleteDialog {
  static void show(BuildContext context, WidgetRef ref, BrandEntity brand) {
    if (brand.offerCount > 0) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.accentGold),
              SizedBox(width: 8),
              Text('Không thể xóa hãng xe', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hãng "${brand.name}" đang liên kết với ${brand.offerCount} xe trong hệ thống.'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariantLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Vui lòng điều chuyển hoặc xóa tất cả xe thuộc hãng này trước khi thực hiện xóa.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Đã hiểu'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Xác nhận xóa hãng', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text('Hãng "${brand.name}" chưa có xe liên kết. Thao tác này sẽ xóa vĩnh viễn hãng khỏi hệ thống.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final ok = await ref
                  .read(brandAdminControllerProvider)
                  .deleteBrand(brand.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok
                          ? 'Đã xóa hãng xe thành công'
                          : 'Không thể xóa hãng xe. Vui lòng thử lại.',
                    ),
                  ),
                );
              }
            },
            child: const Text('Xóa vĩnh viễn', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
