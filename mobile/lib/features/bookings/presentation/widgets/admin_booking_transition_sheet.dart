import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/widgets/vehica_status_chip.dart';
import 'package:vehica_mobile/features/bookings/domain/entities/booking_entity.dart';
import 'package:vehica_mobile/features/bookings/presentation/controllers/booking_controllers.dart';

/// Modal bottom sheet allowing admins to transition booking state per BR-16.
class AdminBookingTransitionSheet extends ConsumerWidget {
  final BookingSummaryEntity booking;

  const AdminBookingTransitionSheet({
    super.key,
    required this.booking,
  });

  static Future<void> show(BuildContext context, BookingSummaryEntity booking) {
    final status = booking.status.toUpperCase();
    final allowedNextStatuses = <String>[];

    if (status == 'PENDING') allowedNextStatuses.addAll(['CONFIRMED', 'CANCELLED']);
    if (status == 'CONFIRMED') allowedNextStatuses.addAll(['PICKED_UP', 'CANCELLED']);
    if (status == 'PICKED_UP') allowedNextStatuses.add('COMPLETED');

    if (allowedNextStatuses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đơn đã ở trạng thái kết thúc, không thể chuyển tiếp.'),
        ),
      );
      return Future.value();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AdminBookingTransitionSheet(booking: booking),
    );
  }

  static Map<String, dynamic> getActionDetails(String status) {
    switch (status) {
      case 'CONFIRMED':
        return {
          'title': 'Duyệt xác nhận cọc',
          'subtitle': 'Khách đã cọc, sẵn sàng giữ xe trong lịch',
          'icon': Icons.verified_rounded,
          'color': const Color(0xFF3B82F6),
          'isDestructive': false,
        };
      case 'PICKED_UP':
        return {
          'title': 'Bàn giao xe cho khách (Pick-up)',
          'subtitle': 'Khách đã nhận xe tại Hub và bắt đầu chuyến đi',
          'icon': Icons.key_rounded,
          'color': AppColors.primary,
          'isDestructive': false,
        };
      case 'COMPLETED':
        return {
          'title': 'Khách trả xe & Hoàn tất hợp đồng',
          'subtitle': 'Kiểm tra xe xong, kết thúc chu kỳ thuê',
          'icon': Icons.task_alt_rounded,
          'color': AppColors.success,
          'isDestructive': false,
        };
      case 'CANCELLED':
        return {
          'title': 'Từ chối / Hủy đơn đặt xe',
          'subtitle': 'Hủy đơn và mở lại slot xe cho khách khác',
          'icon': Icons.cancel_outlined,
          'color': AppColors.error,
          'isDestructive': true,
        };
      default:
        return {
          'title': 'Chuyển trạng thái: $status',
          'subtitle': 'Cập nhật tiến trình đơn',
          'icon': Icons.arrow_forward_rounded,
          'color': AppColors.primary,
          'isDestructive': false,
        };
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = booking.status.toUpperCase();
    final allowedNextStatuses = <String>[];

    if (status == 'PENDING') allowedNextStatuses.addAll(['CONFIRMED', 'CANCELLED']);
    if (status == 'CONFIRMED') allowedNextStatuses.addAll(['PICKED_UP', 'CANCELLED']);
    if (status == 'PICKED_UP') allowedNextStatuses.add('COMPLETED');

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cập nhật tiến trình đơn',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      booking.bookingCode,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              VehicaStatusChip(status: booking.status),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: isDark ? AppColors.borderDark : AppColors.divider),
          const SizedBox(height: 10),
          Text(
            'Chọn thao tác điều phối tiếp theo:',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          ...allowedNextStatuses.map((nextStatus) {
            final action = getActionDetails(nextStatus);
            final isDestructive = action['isDestructive'] as bool;
            final color = action['color'] as Color;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () async {
                  Navigator.of(context).pop();
                  final success = await ref
                      .read(adminBookingsControllerProvider.notifier)
                      .updateStatus(
                        booking.id,
                        nextStatus,
                        reason: 'Quản trị viên thực hiện: ${action['title']}',
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Đã thực hiện: ${action['title']}!'
                              : 'Lỗi cập nhật trạng thái',
                        ),
                        backgroundColor: success ? AppColors.success : AppColors.error,
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDestructive
                          ? AppColors.error.withValues(alpha: 0.3)
                          : (isDark ? AppColors.borderDark : AppColors.borderLight),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          action['icon'] as IconData,
                          size: 18,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              action['title'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                                color: isDestructive
                                    ? AppColors.error
                                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              action['subtitle'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
