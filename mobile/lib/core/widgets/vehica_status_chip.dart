import 'package:flutter/material.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';

enum VehicaChipType { vehicleStatus, bookingStatus, userStatus }

class VehicaStatusChip extends StatelessWidget {
  final String status;
  final VehicaChipType type;

  const VehicaStatusChip({
    super.key,
    required this.status,
    this.type = VehicaChipType.bookingStatus,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label = status;

    switch (status.toUpperCase()) {
      // Vehicle Status
      case 'AVAILABLE':
        bg = AppColors.statusAvailable.withValues(alpha: 0.15);
        fg = AppColors.statusAvailable;
        label = 'Sẵn sàng';
        break;
      case 'RENTED':
        bg = AppColors.statusRented.withValues(alpha: 0.15);
        fg = AppColors.statusRented;
        label = 'Đang cho thuê';
        break;
      case 'MAINTENANCE':
        bg = AppColors.statusMaintenance.withValues(alpha: 0.15);
        fg = AppColors.statusMaintenance;
        label = 'Bảo dưỡng';
        break;
      case 'INACTIVE':
        bg = AppColors.statusInactive.withValues(alpha: 0.15);
        fg = AppColors.statusInactive;
        label = 'Ngừng hoạt động';
        break;

      // Booking Status
      case 'PENDING':
        bg = AppColors.bookingPending.withValues(alpha: 0.15);
        fg = AppColors.bookingPending;
        label = 'Chờ xác nhận';
        break;
      case 'CONFIRMED':
        bg = AppColors.bookingConfirmed.withValues(alpha: 0.15);
        fg = AppColors.bookingConfirmed;
        label = 'Đã xác nhận';
        break;
      case 'PICKED_UP':
        bg = AppColors.bookingPickedUp.withValues(alpha: 0.15);
        fg = AppColors.bookingPickedUp;
        label = 'Đang nhận xe';
        break;
      case 'COMPLETED':
        bg = AppColors.bookingCompleted.withValues(alpha: 0.15);
        fg = AppColors.bookingCompleted;
        label = 'Hoàn thành';
        break;
      case 'CANCELLED':
        bg = AppColors.bookingCancelled.withValues(alpha: 0.15);
        fg = AppColors.bookingCancelled;
        label = 'Đã hủy';
        break;

      // User Status
      case 'ACTIVE':
        bg = AppColors.statusAvailable.withValues(alpha: 0.15);
        fg = AppColors.statusAvailable;
        label = 'Hoạt động';
        break;
      case 'BLOCKED':
        bg = AppColors.bookingCancelled.withValues(alpha: 0.15);
        fg = AppColors.bookingCancelled;
        label = 'Đã khóa';
        break;

      default:
        bg = Colors.grey.withValues(alpha: 0.15);
        fg = Colors.grey.shade700;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
