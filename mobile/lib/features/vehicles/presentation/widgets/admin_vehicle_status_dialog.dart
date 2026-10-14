import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/widgets/vehica_status_chip.dart';
import 'package:vehica_mobile/features/vehicles/presentation/controllers/vehicle_list_controller.dart';
import 'package:vehica_mobile/features/vehicles/domain/entities/vehicle_entity.dart';

class AdminVehicleStatusDialog {
  static void show(BuildContext context, WidgetRef ref, VehicleEntity vehicle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Đổi trạng thái: ${vehicle.name}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['AVAILABLE', 'RENTED', 'MAINTENANCE', 'INACTIVE'].map((status) {
            final isCurrent = vehicle.status == status;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Row(
                children: [
                  VehicaStatusChip(status: status, type: VehicaChipType.vehicleStatus),
                  if (isCurrent) ...[
                    const SizedBox(width: 8),
                    const Text(
                      '(Hiện tại)',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
              trailing: isCurrent
                  ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20)
                  : null,
              onTap: () async {
                Navigator.of(ctx).pop();
                if (vehicle.status != status) {
                  final success = await ref
                      .read(adminVehicleControllerProvider)
                      .updateStatus(vehicle.id, status);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Đã cập nhật trạng thái xe ${vehicle.name} thành $status'
                              : 'Lỗi cập nhật trạng thái xe',
                        ),
                      ),
                    );
                  }
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
