import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/widgets/vehica_button.dart';
import 'package:vehica_mobile/core/widgets/vehica_image_picker_field.dart';
import 'package:vehica_mobile/core/widgets/vehica_text_field.dart';
import 'package:vehica_mobile/features/brands/domain/entities/brand_entity.dart';
import 'package:vehica_mobile/features/brands/presentation/controllers/brand_admin_controller.dart';

class BrandFormSheet {
  static void show(BuildContext context, WidgetRef ref, [BrandEntity? brand]) {
    final isEditing = brand != null;
    final nameController = TextEditingController(text: brand?.name ?? '');
    final countryController = TextEditingController(text: brand?.country ?? '');
    final logoUrlController = TextEditingController(text: brand?.logoUrl ?? '');
    final descController = TextEditingController(text: brand?.description ?? '');
    final orderController =
        TextEditingController(text: '${brand?.displayOrder ?? 0}');
    bool isPopular = brand?.isPopular ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
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
                        isEditing ? 'Chỉnh sửa hãng xe' : 'Thêm hãng xe mới',
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
                  const SizedBox(height: 16),
                  VehicaTextField(
                    label: 'Tên hãng xe *',
                    hint: 'Nhập tên thương hiệu xe...',
                    controller: nameController,
                  ),
                  const SizedBox(height: 12),
                  VehicaTextField(
                    label: 'Quốc gia',
                    hint: 'Quốc gia xuất xứ (tùy chọn)',
                    controller: countryController,
                  ),
                  const SizedBox(height: 12),
                  VehicaImagePickerField(
                    label: 'Logo thương hiệu (Upload lên Supabase)',
                    folder: 'brands',
                    urlController: logoUrlController,
                  ),
                  const SizedBox(height: 12),
                  VehicaTextField(
                    label: 'Mô tả ngắn',
                    hint: 'Mô tả về phong cách, thế mạnh của hãng...',
                    controller: descController,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  VehicaTextField(
                    label: 'Thứ tự hiển thị',
                    hint: '0, 1, 2...',
                    controller: orderController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Hãng xe phổ biến (Hiển thị tab nổi bật)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                    value: isPopular,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => setModalState(() => isPopular = val),
                  ),
                  const SizedBox(height: 20),
                  VehicaButton(
                    text: isEditing ? 'Lưu thay đổi' : 'Tạo hãng xe',
                    onPressed: () async {
                      if (nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vui lòng nhập tên hãng xe')),
                        );
                        return;
                      }

                      final order = int.tryParse(orderController.text.trim()) ?? 0;
                      Navigator.of(ctx).pop();

                      bool ok;
                      if (isEditing) {
                        ok = await ref.read(brandAdminControllerProvider).updateBrand(
                              brand.id,
                              name: nameController.text.trim(),
                              country: countryController.text.trim(),
                              logoUrl: logoUrlController.text.trim(),
                              description: descController.text.trim(),
                              isPopular: isPopular,
                              displayOrder: order,
                            );
                      } else {
                        ok = await ref.read(brandAdminControllerProvider).createBrand(
                              name: nameController.text.trim(),
                              country: countryController.text.trim(),
                              logoUrl: logoUrlController.text.trim(),
                              description: descController.text.trim(),
                              isPopular: isPopular,
                              displayOrder: order,
                            );
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? (isEditing
                                      ? 'Đã cập nhật hãng xe'
                                      : 'Đã tạo hãng xe thành công')
                                  : 'Thao tác thất bại. Vui lòng thử lại.',
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
