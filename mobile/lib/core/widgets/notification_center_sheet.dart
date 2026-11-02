import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/services/notification_service.dart';
import 'package:vehica_mobile/core/utils/formatters.dart';

/// Modal bottom sheet for viewing and managing system in-app notifications
class NotificationCenterSheet extends ConsumerWidget {
  const NotificationCenterSheet({super.key});

  static Future<void> show(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const NotificationCenterSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notifications = ref.watch(notificationListProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            const SizedBox(height: 12),
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
            const SizedBox(height: 14),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Hộp thư thông báo',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              ),
                            ),
                            if (unreadCount > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$unreadCount mới',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Cập nhật trạng thái đơn đặt xe & tiến trình',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (notifications.isNotEmpty)
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        size: 20,
                      ),
                      onSelected: (value) {
                        if (value == 'read_all') {
                          ref.read(notificationListProvider.notifier).markAllAsRead();
                        } else if (value == 'clear_all') {
                          ref.read(notificationListProvider.notifier).clearAll();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'read_all',
                          child: Row(
                            children: [
                              Icon(Icons.done_all_rounded, size: 16),
                              SizedBox(width: 8),
                              Text('Đánh dấu đã đọc tất cả', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'clear_all',
                          child: Row(
                            children: [
                              Icon(Icons.delete_sweep_rounded, size: 16, color: AppColors.error),
                              SizedBox(width: 8),
                              Text('Xóa tất cả thông báo',
                                  style: TextStyle(fontSize: 13, color: AppColors.error)),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.divider),

            // Notification list
            Expanded(
              child: notifications.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.notifications_none_rounded,
                                size: 32,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Chưa có thông báo nào',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Các thông báo đặt xe mới và cập nhật trạng thái sẽ được lưu trữ tự động tại đây.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = notifications[index];
                        final isNewBooking = item.type == 'NEW_BOOKING';
                        final iconColor = isNewBooking ? const Color(0xFF3B82F6) : AppColors.primary;

                        return InkWell(
                          onTap: () {
                            ref.read(notificationListProvider.notifier).markAsRead(item.id);
                            if (item.bookingId != null && item.bookingId!.isNotEmpty) {
                              Navigator.of(context).pop();
                              context.push('/bookings/${item.bookingId}');
                            }
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: item.isRead
                                  ? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
                                  : (isDark
                                      ? AppColors.primary.withValues(alpha: 0.1)
                                      : AppColors.primaryMuted),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: item.isRead
                                    ? (isDark ? AppColors.borderDark : AppColors.borderLight)
                                    : AppColors.primaryLight.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: iconColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    isNewBooking
                                        ? Icons.add_shopping_cart_rounded
                                        : Icons.sync_rounded,
                                    size: 18,
                                    color: iconColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.title,
                                              style: TextStyle(
                                                fontSize: 13.5,
                                                fontWeight:
                                                    item.isRead ? FontWeight.w600 : FontWeight.w800,
                                                color: isDark
                                                    ? AppColors.textPrimaryDark
                                                    : AppColors.textPrimary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (!item.isRead)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              margin: const EdgeInsets.only(left: 6),
                                              decoration: const BoxDecoration(
                                                color: AppColors.primary,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        item.message,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: isDark
                                              ? AppColors.textSecondaryDark
                                              : AppColors.textSecondary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            VehicaFormatters.formatDateTime(item.timestamp),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark
                                                  ? AppColors.textSecondaryDark.withValues(alpha: 0.7)
                                                  : AppColors.textSecondary.withValues(alpha: 0.7),
                                            ),
                                          ),
                                          if (item.bookingId != null)
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'Xem chi tiết',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: isDark
                                                        ? AppColors.primaryLight
                                                        : AppColors.primary,
                                                  ),
                                                ),
                                                const SizedBox(width: 2),
                                                Icon(
                                                  Icons.arrow_forward_ios_rounded,
                                                  size: 9,
                                                  color: isDark
                                                      ? AppColors.primaryLight
                                                      : AppColors.primary,
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// Reusable Notification Bell Icon Button with dynamic unread badge
class NotificationBellButton extends ConsumerWidget {
  final Color? color;

  const NotificationBellButton({super.key, this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          tooltip: 'Thông báo',
          icon: Icon(
            unreadCount > 0 ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
            color: color,
            size: 22,
          ),
          onPressed: () => NotificationCenterSheet.show(context),
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                unreadCount > 9 ? '9+' : '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

