// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// SCREEN            : S12 - Admin Booking Management
// USE CASE          : UC-08 - Manage & Transition Booking Status (Admin Booking State Transition)
// BUSINESS RULES    : BR-16 (State Machine: PENDING -> CONFIRMED -> PICKED_UP -> COMPLETED / CANCELLED),
//                     BR-18 (Admin override & mandatory reason), BR-21 (Log performer)
// ------------------------------------------------------------------------------
// FLOW:
// 1. Load bookings: Watch adminBookingsControllerProvider -> Call GET /api/admin/bookings?status=...
// 2. Filter by status: Filter Chips (All, PENDING, CONFIRMED, PICKED_UP, COMPLETED, CANCELLED)
// 3. State Transition: BottomSheet opens with valid next statuses per BR-16.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/widgets/vehica_async_view.dart';
import 'package:vehica_mobile/core/widgets/vehica_back_button.dart';
import 'package:vehica_mobile/features/bookings/domain/entities/booking_entity.dart';
import 'package:vehica_mobile/features/bookings/presentation/controllers/booking_controllers.dart';
import 'package:vehica_mobile/features/bookings/presentation/widgets/admin_booking_card.dart';
import 'package:vehica_mobile/features/bookings/presentation/widgets/admin_booking_transition_sheet.dart';
import 'package:vehica_mobile/features/bookings/presentation/widgets/booking_status_filter_bar.dart';

/// Admin Booking Management Screen (S12)
class AdminBookingManagementPage extends ConsumerWidget {
  const AdminBookingManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final adminBookingsState = ref.watch(adminBookingsControllerProvider);
    final bookingsState = adminBookingsState.bookings;
    final currentFilter = adminBookingsState.statusFilter;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/admin/dashboard');
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          leading: VehicaBackButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/admin/dashboard');
              }
            },
          ),
          title: const Text('Quản lý đơn đặt xe'),
        ),
        body: Column(
          children: [
            // ── Filter tabs ──────────────────────────────────────────────────
            BookingStatusFilterBar(
              currentFilter: currentFilter,
              onFilterChanged: (filter) => ref
                  .read(adminBookingsControllerProvider.notifier)
                  .filterByStatus(filter),
            ),

            // ── Bookings list ─────────────────────────────────────────────────
            Expanded(
              child: VehicaAsyncView<List<BookingSummaryEntity>>(
                isLoading: bookingsState.isLoading,
                errorMessage: bookingsState.error != null
                    ? 'Không thể tải danh sách đơn đặt xe. Vui lòng thử lại.'
                    : null,
                isEmpty: bookingsState.value?.isEmpty ?? true,
                emptyMessage: 'Không có đơn đặt xe nào',
                onRetry: () =>
                    ref.read(adminBookingsControllerProvider.notifier).loadBookings(),
                dataBuilder: (context) {
                  final list = bookingsState.value!;
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 1150
                          ? 3
                          : constraints.maxWidth > 700
                              ? 2
                              : 1;
                      if (crossAxisCount > 1) {
                        return GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: crossAxisCount == 3 ? 1.85 : 1.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final booking = list[index];
                            return AdminBookingCard(
                              booking: booking,
                              margin: EdgeInsets.zero,
                              onTap: () => context.push('/bookings/${booking.id}'),
                              onTransition: () =>
                                  AdminBookingTransitionSheet.show(context, booking),
                            );
                          },
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final booking = list[index];
                          return AdminBookingCard(
                            booking: booking,
                            margin: EdgeInsets.zero,
                            onTap: () => context.push('/bookings/${booking.id}'),
                            onTransition: () =>
                                AdminBookingTransitionSheet.show(context, booking),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
