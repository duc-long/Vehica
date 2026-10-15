// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// LAYER             : Presentation Layer (StateNotifier & Family Providers)
// USE CASES         : UC-06 (Create booking), UC-07 (My bookings & Cancel booking), UC-08 (Admin approve booking)
// BUSINESS RULES    : BR-08, BR-09, BR-10, BR-11, BR-12, BR-14, BR-16, BR-17, BR-18, BR-21
// ------------------------------------------------------------------------------
// DATA FLOW:
// UI (MyBookingsPage S06 / BookingDetailPage S06 / AdminBookingManagementPage S12)
//   --> MyBookingsController / AdminBookingsController
//   --> BookingRepository (Domain Interface)
//   --> BookingRepositoryImpl (Data Layer)
//   --> BookingRemoteDataSource (Dio HTTP Client)
//   --> Spring Boot REST API (/api/bookings & /api/admin/bookings)
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/app/providers.dart';
import 'package:vehica_mobile/features/bookings/domain/entities/booking_entity.dart';
import 'package:vehica_mobile/features/bookings/domain/repositories/booking_repository.dart';
import 'package:vehica_mobile/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:vehica_mobile/features/vehicles/presentation/controllers/vehicle_list_controller.dart';

/// Controller managing customer's booking list (S06)
class MyBookingsController extends StateNotifier<AsyncValue<List<BookingSummaryEntity>>> {
  final BookingRepository repository;
  final Ref ref;

  MyBookingsController({
    required this.repository,
    required this.ref,
  }) : super(const AsyncValue.loading()) {
    loadMyBookings();
  }

  /// Load current user's bookings (UC-07)
  /// Flow: GET /api/bookings/my-bookings -> Update State
  Future<void> loadMyBookings() async {
    state = const AsyncValue.loading();
    try {
      final list = await repository.getMyBookings();
      if (!mounted) return;
      state = AsyncValue.data(list);
    } catch (e, st) {
      if (!mounted) return;
      state = AsyncValue.error(
        e.toString().replaceAll('Exception: ', '').replaceAll('ServerException: ', ''),
        st,
      );
    }
  }

  /// Customer cancels booking (UC-07, BR-14, BR-16, BR-17)
  /// Flow: POST /api/bookings/:id/cancel -> Invalidate all caches for immediate UI update
  Future<bool> cancelBooking(String bookingId, {String? reason}) async {
    try {
      await repository.cancelBooking(bookingId, reason: reason);
      // Automatically refresh all dependent providers system-wide (Realtime Refresh)
      ref.invalidate(bookingDetailProvider(bookingId));
      ref.invalidate(bookingHistoryProvider(bookingId));
      ref.invalidate(adminBookingsControllerProvider);
      ref.invalidate(adminDashboardSummaryProvider);
      ref.invalidate(vehicleListControllerProvider);
      ref.invalidate(adminVehiclesListProvider);
      await loadMyBookings();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final myBookingsControllerProvider =
    StateNotifierProvider<MyBookingsController, AsyncValue<List<BookingSummaryEntity>>>((ref) {
  final repo = ref.watch(bookingRepositoryProvider);
  return MyBookingsController(repository: repo, ref: ref);
});

/// Provider for viewing booking details (S06)
final bookingDetailProvider = FutureProvider.family<BookingDetailEntity, String>((ref, bookingId) async {
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.getBookingDetail(bookingId);
});

/// Provider for viewing status transition history (Audit Timeline) (S06, BR-21)
final bookingHistoryProvider =
    FutureProvider.family<List<BookingStatusHistoryEntity>, String>((ref, bookingId) async {
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.getBookingHistory(bookingId);
});

/// Booking list state for Admin
class AdminBookingsState {
  final AsyncValue<List<BookingSummaryEntity>> bookings;
  final String? statusFilter;

  const AdminBookingsState({
    required this.bookings,
    this.statusFilter,
  });

  AdminBookingsState copyWith({
    AsyncValue<List<BookingSummaryEntity>>? bookings,
    String? Function()? statusFilter,
  }) {
    return AdminBookingsState(
      bookings: bookings ?? this.bookings,
      statusFilter: statusFilter != null ? statusFilter() : this.statusFilter,
    );
  }
}

/// Controller managing approval and status transitions of bookings for Admin (S12)
class AdminBookingsController extends StateNotifier<AdminBookingsState> {
  final BookingRepository repository;
  final Ref ref;

  AdminBookingsController({
    required this.repository,
    required this.ref,
  }) : super(const AdminBookingsState(bookings: AsyncValue.loading())) {
    loadBookings();
  }

  /// Load booking list by status filter (UC-08)
  /// Flow: GET /api/admin/bookings?status=... -> Update State
  Future<void> loadBookings() async {
    state = state.copyWith(bookings: const AsyncValue.loading());
    try {
      final list = await repository.getAdminBookings(status: state.statusFilter);
      if (!mounted) return;
      state = state.copyWith(bookings: AsyncValue.data(list));
    } catch (e, st) {
      if (!mounted) return;
      state = state.copyWith(
        bookings: AsyncValue.error(
          e.toString().replaceAll('Exception: ', '').replaceAll('ServerException: ', ''),
          st,
        ),
      );
    }
  }

  /// Filter list by status (PENDING, CONFIRMED, PICKED_UP, COMPLETED, CANCELLED)
  void filterByStatus(String? status) {
    state = state.copyWith(
      statusFilter: () => status,
    );
    loadBookings();
  }

  /// Administrator updates booking status (UC-08, BR-16, BR-18, BR-21)
  /// Flow: PATCH /api/admin/bookings/:id/status -> Invalidate all caches for immediate UI update
  Future<bool> updateStatus(String bookingId, String newStatus, {String? reason}) async {
    try {
      await repository.updateBookingStatusByAdmin(
        bookingId: bookingId,
        status: newStatus,
        reason: reason,
      );
      // Invalidate system-wide caches
      ref.invalidate(bookingDetailProvider(bookingId));
      ref.invalidate(bookingHistoryProvider(bookingId));
      ref.invalidate(myBookingsControllerProvider);
      ref.invalidate(adminDashboardSummaryProvider);
      ref.invalidate(vehicleListControllerProvider);
      ref.invalidate(adminVehiclesListProvider);
      await loadBookings();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final adminBookingsControllerProvider =
    StateNotifierProvider<AdminBookingsController, AdminBookingsState>((ref) {
  final repo = ref.watch(bookingRepositoryProvider);
  return AdminBookingsController(repository: repo, ref: ref);
});
