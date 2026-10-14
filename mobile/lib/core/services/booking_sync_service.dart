import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehica_mobile/app/providers.dart';
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
    _knownUserBookingStatuses.clear();

    // Run first sync immediately to populate baseline
    _runSync();

    // Background interval: sync every 10 seconds
    _syncTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _runSync();
    });
  }

  void _stopSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
    _isFirstRun = true;
    _knownAdminBookingIds.clear();
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
    final bookings = await repository.getAdminBookings(page: 0, size: 5);

    if (_isFirstRun) {
      for (final b in bookings) {
        _knownAdminBookingIds.add(b.id);
      }
      return;
    }

    for (final b in bookings) {
      if (!_knownAdminBookingIds.contains(b.id)) {
        _knownAdminBookingIds.add(b.id);

        // Immediate In-App Push Notification for Admin
        VehicaFeedback.showInAppPush(
          title: 'Đơn đặt xe mới!',
          message: '${b.customerName} vừa đặt xe ${b.vehicleName} (Mã: ${b.bookingCode})',
          icon: Icons.notifications_active_rounded,
          onTap: () {
            VehicaFeedback.navigatorKey.currentContext?.push('/admin/bookings');
          },
        );

        // Invalidate state reactively so UI refreshes without manual reload
        ref.invalidate(adminBookingsControllerProvider);
        ref.invalidate(adminDashboardSummaryProvider);
        break; // Show at most 1 banner per poll to prevent screen flooding
      }
    }
  }

  Future<void> _syncUserBookings() async {
    final bookings = await repository.getMyBookings(page: 0, size: 5);

    if (_isFirstRun) {
      for (final b in bookings) {
        _knownUserBookingStatuses[b.id] = b.status;
      }
      return;
    }

    for (final b in bookings) {
      final oldStatus = _knownUserBookingStatuses[b.id];
      if (oldStatus != null && oldStatus.toUpperCase() != b.status.toUpperCase()) {
        _knownUserBookingStatuses[b.id] = b.status;

        // Immediate In-App Push Notification for Customer
        VehicaFeedback.showInAppPush(
          title: 'Cập nhật đơn đặt xe',
          message: 'Đơn xe ${b.vehicleName} (${b.bookingCode}) đã chuyển sang ${_translateStatus(b.status)}',
          icon: Icons.check_circle_outline_rounded,
          onTap: () {
            VehicaFeedback.navigatorKey.currentContext?.push('/bookings/${b.id}');
          },
        );

        // Invalidate state reactively so user bookings refresh instantly
        ref.invalidate(myBookingsControllerProvider);
        break;
      } else {
        _knownUserBookingStatuses[b.id] = b.status;
      }
    }
  }

  String _translateStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Chờ xác nhận';
      case 'CONFIRMED':
        return 'Đã xác nhận';
      case 'ACTIVE':
        return 'Đang thuê xe';
      case 'COMPLETED':
        return 'Đã hoàn thành';
      case 'CANCELLED':
        return 'Đã hủy';
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
