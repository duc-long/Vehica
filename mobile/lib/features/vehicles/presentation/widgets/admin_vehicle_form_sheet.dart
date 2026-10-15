import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/widgets/vehica_button.dart';
import 'package:vehica_mobile/core/widgets/vehica_image_picker_field.dart';
import 'package:vehica_mobile/core/widgets/vehica_text_field.dart';
import 'package:vehica_mobile/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:vehica_mobile/features/vehicles/presentation/controllers/vehicle_list_controller.dart';

class AdminVehicleFormSheet {
  static void show(BuildContext context, WidgetRef ref, [VehicleEntity? vehicle]) {
    final isEditing = vehicle != null;
    final typesAsync = ref.read(vehicleTypesProvider);
    final brandsAsync = ref.read(brandsProvider);

    final nameController = TextEditingController(text: vehicle?.name ?? '');
    final modelController = TextEditingController(text: vehicle?.model ?? '');
    final plateController = TextEditingController(text: vehicle?.licensePlate ?? '');
    final yearController = TextEditingController(text: '${vehicle?.year ?? DateTime.now().year}');
    final seatsController = TextEditingController(text: '${vehicle?.seatCapacity ?? 5}');
    final priceController = TextEditingController(
      text: vehicle != null ? vehicle.pricePerDay.toStringAsFixed(0) : '1000000',
    );
    final descController = TextEditingController(text: vehicle?.description ?? '');
    final imageController = TextEditingController(text: vehicle?.primaryImageUrl ?? '');
    final customFeatureController = TextEditingController();
    final selectedFeatures = List<String>.from(vehicle?.features ?? []);

    String? selectedBrand = vehicle?.brand;
    String? selectedTypeId = vehicle?.type.id;
    String selectedStatus = vehicle?.status ?? 'AVAILABLE';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          final types = typesAsync.value ?? [];
          final brands = brandsAsync.value ?? [];

          if (selectedTypeId == null && types.isNotEmpty) {
            selectedTypeId = types.first.id;
          }
          if (selectedBrand == null && brands.isNotEmpty) {
            selectedBrand = brands.first.name;
          }

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
                        isEditing ? 'Chỉnh sửa thông tin xe' : 'Thêm xe mới vào đội xe',
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

                  // Vehicle Name
                  VehicaTextField(
                    label: 'Tên hiển thị của xe *',
                    hint: 'Nhập tên xe...',
                    controller: nameController,
                  ),
                  const SizedBox(height: 12),

                  // Brand & Type Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hãng xe *',
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
                                  value: selectedBrand,
                                  items: brands.map((b) {
                                    return DropdownMenuItem(
                                      value: b.name,
                                      child: Text(b.name, style: const TextStyle(fontSize: 13.5)),
                                    );
                                  }).toList(),
                                  onChanged: (val) => setModalState(() => selectedBrand = val),
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
                              'Phân khúc / Dòng xe *',
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
                                  value: selectedTypeId,
                                  items: types.map((t) {
                                    return DropdownMenuItem(
                                      value: t.id,
                                      child: Text(t.name, style: const TextStyle(fontSize: 13.5)),
                                    );
                                  }).toList(),
                                  onChanged: (val) => setModalState(() => selectedTypeId = val),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Model & Plate Row
                  Row(
                    children: [
                      Expanded(
                        child: VehicaTextField(
                          label: 'Dòng xe (Model) *',
                          hint: 'Nhập dòng/phiên bản xe...',
                          controller: modelController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: VehicaTextField(
                          label: 'Biển số xe *',
                          hint: 'VD: 30A-123.45',
                          controller: plateController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Year, Seats, Price Row
                  Row(
                    children: [
                      Expanded(
                        child: VehicaTextField(
                          label: 'Năm SX *',
                          hint: '2024',
                          controller: yearController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: VehicaTextField(
                          label: 'Số chỗ *',
                          hint: '5, 7...',
                          controller: seatsController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: VehicaTextField(
                          label: 'Giá thuê/ngày (VNĐ) *',
                          hint: '1200000',
                          controller: priceController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Description
                  VehicaTextField(
                    label: 'Mô tả tính năng xe',
                    hint: 'Trang bị động cơ, nội thất da, cửa sổ trời, gói ADAS...',
                    controller: descController,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),

                  // Image Upload to Supabase Storage
                  VehicaImagePickerField(
                    label: 'Hình ảnh đại diện xe (Upload lên Supabase)',
                    folder: 'vehicles',
                    urlController: imageController,
                  ),
                  const SizedBox(height: 12),

                  // Status
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trạng thái hoạt động',
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
                              DropdownMenuItem(value: 'AVAILABLE', child: Text('Sẵn sàng (AVAILABLE)')),
                              DropdownMenuItem(value: 'RENTED', child: Text('Đang cho thuê (RENTED)')),
                              DropdownMenuItem(value: 'MAINTENANCE', child: Text('Đang bảo dưỡng (MAINTENANCE)')),
                              DropdownMenuItem(value: 'INACTIVE', child: Text('Ngừng hoạt động (INACTIVE)')),
                            ],
                            onChanged: (val) {
                              if (val != null) setModalState(() => selectedStatus = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Tính năng & Trang bị xe (Dynamic Features) ────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tính năng & Tiện nghi xe',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${selectedFeatures.length} đã chọn',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Selected & Preset Feature Chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...[
                            'Cửa sổ trời toàn cảnh',
                            'Camera 360°',
                            'Sưởi & làm mát ghế',
                            'Định vị GPS / CarPlay',
                            'Âm thanh vòm cao cấp',
                            'Hệ thống trợ lái ADAS',
                            'Cốp điện thông minh',
                            'Sạc không dây Qi',
                            'Bảo hiểm thân vỏ 2 chiều 100%',
                            ...selectedFeatures.where((f) => ![
                              'Cửa sổ trời toàn cảnh',
                              'Camera 360°',
                              'Sưởi & làm mát ghế',
                              'Định vị GPS / CarPlay',
                              'Âm thanh vòm cao cấp',
                              'Hệ thống trợ lái ADAS',
                              'Cốp điện thông minh',
                              'Sạc không dây Qi',
                              'Bảo hiểm thân vỏ 2 chiều 100%',
                            ].contains(f)),
                          ].map((feat) {
                            final isSelected = selectedFeatures.contains(feat);
                            return FilterChip(
                              label: Text(
                                feat,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: AppColors.primary,
                              backgroundColor: isDark
                                  ? AppColors.surfaceVariantDark
                                  : AppColors.surfaceVariantLight,
                              checkmarkColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                                ),
                              ),
                              onSelected: (selected) {
                                setModalState(() {
                                  if (selected) {
                                    if (!selectedFeatures.contains(feat)) selectedFeatures.add(feat);
                                  } else {
                                    selectedFeatures.remove(feat);
                                  }
                                });
                              },
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Add custom feature input
                      Row(
                        children: [
                          Expanded(
                            child: VehicaTextField(
                              label: 'Thêm tính năng tùy chỉnh',
                              controller: customFeatureController,
                              hint: 'VD: Cửa hít tự động...',
                              prefixIcon: Icons.add_circle_outline_rounded,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: IconButton.filled(
                              icon: const Icon(Icons.check_rounded),
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                final text = customFeatureController.text.trim();
                                if (text.isNotEmpty && !selectedFeatures.contains(text)) {
                                  setModalState(() {
                                    selectedFeatures.add(text);
                                    customFeatureController.clear();
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Submit button
                  VehicaButton(
                    text: isEditing ? 'Lưu cập nhật xe' : 'Tạo thông tin xe',
                    onPressed: () async {
                      if (nameController.text.trim().isEmpty ||
                          modelController.text.trim().isEmpty ||
                          plateController.text.trim().isEmpty ||
                          selectedTypeId == null ||
                          selectedBrand == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vui lòng điền đầy đủ các trường bắt buộc (*)')),
                        );
                        return;
                      }

                      final year = int.tryParse(yearController.text.trim()) ?? 2024;
                      final seats = int.tryParse(seatsController.text.trim()) ?? 5;
                      final price = double.tryParse(priceController.text.trim()) ?? 1000000;

                      final payload = {
                        'name': nameController.text.trim(),
                        'brand': selectedBrand,
                        'model': modelController.text.trim(),
                        'licensePlate': plateController.text.toUpperCase().trim(),
                        'year': year,
                        'seatCapacity': seats,
                        'pricePerDay': price,
                        'typeId': selectedTypeId,
                        'status': selectedStatus,
                        'description': descController.text.trim(),
                        'imageUrl': imageController.text.trim().isNotEmpty ? imageController.text.trim() : null,
                        'features': selectedFeatures,
                      };

                      Navigator.of(ctx).pop();

                      bool ok;
                      if (isEditing) {
                        ok = await ref.read(adminVehicleControllerProvider).updateVehicle(vehicle.id, payload);
                      } else {
                        ok = await ref.read(adminVehicleControllerProvider).createVehicle(payload);
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? (isEditing ? 'Đã cập nhật thông tin xe' : 'Đã thêm xe mới vào đội xe thành công')
                                  : 'Thao tác thất bại. Vui lòng kiểm tra lại biển số xe.',
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
