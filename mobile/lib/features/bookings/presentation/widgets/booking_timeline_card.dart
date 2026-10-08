import 'package:flutter/material.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/utils/formatters.dart';
import 'package:vehica_mobile/features/bookings/domain/entities/booking_entity.dart';

/// Card rendering the vertical timeline for booking status transitions.
class BookingTimelineCard extends StatelessWidget {
  final List<BookingStatusHistoryEntity> histories;

  const BookingTimelineCard({
    super.key,
    required this.histories,
  });

  static String getStatusLabel(String rawStatus) {
    switch (rawStatus.toUpperCase()) {
      case 'PENDING':
        return 'Chờ duyệt cọc';
      case 'CONFIRMED':
        return 'Đã xác nhận đặt xe';
      case 'PICKED_UP':
        return 'Đang nhận & sử dụng xe';
      case 'COMPLETED':
        return 'Hoàn tất chuyến đi';
      case 'CANCELLED':
        return 'Đã hủy đơn';
      default:
        return rawStatus;
    }
  }

  static Color getStatusColor(String rawStatus) {
    switch (rawStatus.toUpperCase()) {
      case 'PENDING':
        return const Color(0xFFF59E0B);
      case 'CONFIRMED':
        return const Color(0xFF3B82F6);
      case 'PICKED_UP':
        return AppColors.primaryLight;
      case 'COMPLETED':
        return AppColors.success;
      case 'CANCELLED':
        return AppColors.error;
      default:
        return AppColors.primaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: histories.isEmpty
          ? Text(
              'Chưa có cập nhật trạng thái',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                fontSize: 13,
              ),
            )
          : Column(
              children: List.generate(histories.length, (idx) {
                final h = histories[idx];
                final isLast = idx == histories.length - 1;
                final statusColor = getStatusColor(h.toStatus);
                final statusLabel = getStatusLabel(h.toStatus);

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timeline indicator & line
                      SizedBox(
                        width: 20,
                        child: Column(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              margin: const EdgeInsets.only(top: 3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: statusColor,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                            if (!isLast)
                              Expanded(
                                child: Container(
                                  width: 2,
                                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    statusLabel,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    VehicaFormatters.formatDateTime(h.changedAt),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              if (h.reason != null && h.reason!.trim().isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  h.reason!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
    );
  }
}
