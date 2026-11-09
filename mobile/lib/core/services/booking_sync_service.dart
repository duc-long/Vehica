import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehica_mobile/app/providers.dart';
import 'package:vehica_mobile/core/services/notification_service.dart';
import 'package:vehica_mobile/core/services/vehica_feedback.dart';
import 'package:vehica_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:vehica_mobile/features/bookings/domain/repositories/booking_repository.dart';
import 'package:vehica_mobile/features/bookings/presentation/controllers/booking_controllers.dart';
import 'package:vehica_mobile/features/dashboard/presentation/controllers/dashboard_controller.dart';

class BookingSyncService {
  final Ref ref;
  final BookingRepository repository;

  Timer? _syncTimer;
  bool _isSyncing = false;
  bool _isFirstRun = true;

  final Set<String> _knownAdminBookingIds = {};
  final Map<String, String> _knownAdminBookingStatuses = {};
  final Map<String, String> _knownUserBookingStatuses = {};

  BookingSyncService({required this.ref, required this.repository}) {
    _initListener();
  }

  void _initListener() {
    ref.listen(authControllerProvider, (prev, next) {
      if (next.isAuthenticated && next.user != null) {
        _startSync();
      } else {
        _stopSync();
      }
    });

    final currentAuth = ref.read(authControllerProvider);
    if (currentAuth.isAuthenticated && currentAuth.user != null) {
      _startSync();
    }
  }

  void _startSync() {
    _syncTimer?.cancel();
    _isFirstRun = true;
    _knownAdminBookingIds.clear();
    _knownAdminBookingStatuses.clear();
    _knownUserBookingStatuses.clear();

    // Run first sync immediately to populate baseline
    _runSync();

    // Background interval: sync every 8 seconds
    _syncTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      _runSync();
    });
  }

  void _stopSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
    _isFirstRun = true;
    _knownAdminBookingIds.clear();
    _knownAdminBookingStatuses.clear();
    _knownUserBookingStatuses.clear();
  }

  Future<void> _runSync() async {
    if (_isSyncing) return;
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;

    _isSyncing = true;
    try {
      if (user.role.toUpperCase() == 'ADMIN') {
        await _syncAdminBookings();
      } else {
        await _syncUserBookings();
      }
    } catch (_) {
      // Silently ignore background polling errors to not disturb user
    } finally {
      _isFirstRun = false;
      _isSyncing = false;
    }
  }

  Future<void> _syncAdminBookings() async {
    final bookings = await repository.getAdminBookings(page: 0, size: 20);

    if (_isFirstRun) {
      for (final b in bookings) {
        _knownAdminBookingIds.add(b.id);
        _knownAdminBookingStatuses[b.id] = b.status;
      }
      return;
    }

    bool shownPush = false;
    bool needsRefresh = false;

    for (final b in bookings) {
      // Case 1: Đơn đặt xe hoàn toàn mới
      if (!_knownAdminBookingIds.contains(b.id)) {
        _knownAdminBookingIds.add(b.id);
        _knownAdminBookingStatuses[b.id] = b.status;

        final title = 'Đơn đặt xe mới!';
        final message = '${b.customerName} vừa đặt xe ${b.vehicleName} (Mã: ${b.bookingCode})';

        // 1. Lưu vào notification inbox cục bộ
        ref.read(notificationListProvider.notifier).addNotification(
          title: title,
          message: message,
          bookingId: b.id,
          bookingCode: b.bookingCode,
          type: 'NEW_BOOKING',
        );

        // 2. Bắn In-App Push Banner nổi (tối đa 1 banner mỗi lần sync)
        if (!shownPush) {
          VehicaFeedback.showInAppPush(
            title: title,
            message: message,
            icon: Icons.notifications_active_rounded,
            onTap: () {
              VehicaFeedback.navigatorKey.currentContext?.push('/bookings/${b.id}');
            },
          );
          shownPush = true;
        }

        needsRefresh = true;
      } else {
        // Case 2: Đơn đã có nhưng thay đổi trạng thái (ví dụ khách hủy đơn)
        final oldStatus = _knownAdminBookingStatuses[b.id];
        if (oldStatus != null && oldStatus.toUpperCase() != b.status.toUpperCase()) {
          _knownAdminBookingStatuses[b.id] = b.status;

          final isCancelled = b.status.toUpperCase() == 'CANCELLED';
          final title = isCancelled ? 'Khách đã hủy đơn đặt xe' : 'Cập nhật đơn đặt xe';
          final message = isCancelled
              ? '${b.customerName} đã hủy đơn xe ${b.vehicleName} (Mã: ${b.bookingCode})'
              : 'Đơn xe ${b.vehicleName} (${b.bookingCode}) đã chuyển sang ${_translateStatus(b.status)}';

          // 1. Lưu vào notification inbox
          ref.read(notificationListProvider.notifier).addNotification(
            title: title,
            message: message,
            bookingId: b.id,
            bookingCode: b.bookingCode,
            type: 'STATUS_CHANGE',
          );

          // 2. Bắn In-App Push Banner
          if (!shownPush) {
            VehicaFeedback.showInAppPush(
              title: title,
              message: message,
              icon: isCancelled ? Icons.cancel_outlined : Icons.info_outline_rounded,
              onTap: () {
                VehicaFeedback.navigatorKey.currentContext?.push('/bookings/${b.id}');
              },
            );
            shownPush = true;
          }

          ref.invalidate(bookingDetailProvider(b.id));
          ref.invalidate(bookingHistoryProvider(b.id));
          needsRefresh = true;
        } else {
          _knownAdminBookingStatuses[b.id] = b.status;
        }
      }
    }

    if (needsRefresh) {
      ref.invalidate(adminBookingsControllerProvider);
      ref.invalidate(adminDashboardSummaryProvider);
    }
  }

  Future<void> _syncUserBookings() async {
    final bookings = await repository.getMyBookings(page: 0, size: 20);

    if (_isFirstRun) {
      for (final b in bookings) {
        _knownUserBookingStatuses[b.id] = b.status;
      }
      return;
    }

    bool shownPush = false;
    bool needsRefresh = false;

    for (final b in bookings) {
      final oldStatus = _knownUserBookingStatuses[b.id];
      if (oldStatus != null && oldStatus.toUpperCase() != b.status.toUpperCase()) {
        _knownUserBookingStatuses[b.id] = b.status;

        final title = 'Cập nhật đơn đặt xe';
        final message = 'Đơn xe ${b.vehicleName} (${b.bookingCode}) đã chuyển sang ${_translateStatus(b.status)}';

        // 1. Save to local notification inbox
        ref.read(notificationListProvider.notifier).addNotification(
          title: title,
          message: message,
          bookingId: b.id,
          bookingCode: b.bookingCode,
          type: 'STATUS_CHANGE',
        );

        // 2. Immediate In-App Push Notification for Customer (tối đa 1 banner mỗi lần sync)
        if (!shownPush) {
          VehicaFeedback.showInAppPush(
            title: title,
            message: message,
            icon: Icons.check_circle_outline_rounded,
            onTap: () {
              VehicaFeedback.navigatorKey.currentContext?.push('/bookings/${b.id}');
            },
          );
          shownPush = true;
        }

        // Invalidate cả chi tiết đơn cụ thể để màn hình BookingDetailPage tự động render lại ngay
        ref.invalidate(bookingDetailProvider(b.id));
        ref.invalidate(bookingHistoryProvider(b.id));
        needsRefresh = true;
      } else {
        _knownUserBookingStatuses[b.id] = b.status;
      }
    }

    if (needsRefresh) {
      // Invalidate state reactively so user bookings list refreshes instantly
      ref.invalidate(myBookingsControllerProvider);
    }
  }

  String _translateStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Chờ duyệt cọc';
      case 'CONFIRMED':
        return 'Đã duyệt (Chờ nhận xe)';
      case 'PICKED_UP':
      case 'ACTIVE':
        return 'Đang thuê xe (Đã nhận xe)';
      case 'COMPLETED':
        return 'Đã hoàn tất trả xe';
      case 'CANCELLED':
        return 'Đã hủy đơn';
      default:
        return status;
    }
  }

  void dispose() {
    _stopSync();
  }
}

final bookingSyncServiceProvider = Provider<BookingSyncService>((ref) {
  final repo = ref.watch(bookingRepositoryProvider);
  final service = BookingSyncService(ref: ref, repository: repo);
  ref.onDispose(() => service.dispose());
  return service;
});
