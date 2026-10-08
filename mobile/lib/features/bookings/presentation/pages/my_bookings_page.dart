// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// SCREEN       : S06 - My Bookings Screen
// STYLE                   : Dark Slate Luxury, Emerald Teal Accent
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/utils/formatters.dart';
import 'package:vehica_mobile/core/widgets/vehica_async_view.dart';
import 'package:vehica_mobile/core/widgets/vehica_back_button.dart';
import 'package:vehica_mobile/core/widgets/vehica_button.dart';
import 'package:vehica_mobile/core/widgets/vehica_image.dart';
import 'package:vehica_mobile/core/widgets/vehica_skeleton.dart';
import 'package:vehica_mobile/core/widgets/vehica_status_chip.dart';
import 'package:vehica_mobile/features/bookings/domain/entities/booking_entity.dart';
import 'package:vehica_mobile/features/bookings/presentation/controllers/booking_controllers.dart';

class MyBookingsPage extends ConsumerWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookingsState = ref.watch(myBookingsControllerProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Đơn đặt xe của tôi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        leading: const VehicaBackButton(),
      ),
      body: bookingsState.isLoading
          ? LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 1100
                    ? 3
                    : constraints.maxWidth > 650
                        ? 2
                        : 1;
                if (crossAxisCount > 1) {
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.7,
                    ),
                    itemCount: 4,
                    itemBuilder: (_, __) => const BookingCardSkeleton(),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: 4,
                  itemBuilder: (_, __) => const BookingCardSkeleton(),
                );
              },
            )
          : RefreshIndicator(
              color: AppColors.primaryLight,
              onRefresh: () async {
                await ref.read(myBookingsControllerProvider.notifier).loadMyBookings();
              },
              child: VehicaAsyncView<List<BookingSummaryEntity>>(
                isLoading: false,
                errorMessage: bookingsState.error?.toString(),
                isEmpty: bookingsState.value?.isEmpty ?? true,
                emptyMessage: 'Bạn chưa có đơn đặt xe nào',
                emptyIcon: Icons.receipt_long_rounded,
                action: VehicaButton(
                  text: 'Tìm xe ngay',
                  width: 160,
                  onPressed: () => context.go('/home'),
                ),
                onRetry: () => ref.read(myBookingsControllerProvider.notifier).loadMyBookings(),
                dataBuilder: (context) {
                  final list = bookingsState.value!;
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 1100
                          ? 3
                          : constraints.maxWidth > 650
                              ? 2
                              : 1;
                      if (crossAxisCount > 1) {
                        return GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.7,
                          ),
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final booking = list[index];
                            return _BookingCard(
                              booking: booking,
                              isDark: isDark,
                              margin: EdgeInsets.zero,
                            );
                          },
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final booking = list[index];
                          return _BookingCard(
                            booking: booking,
                            isDark: isDark,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingSummaryEntity booking;
  final bool isDark;
  final EdgeInsetsGeometry? margin;

  const _BookingCard({
    required this.booking,
    required this.isDark,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final imgUrl = booking.vehicleImageUrl;

    return GestureDetector(
      onTap: () => context.push('/bookings/${booking.id}'),
      child: Container(
        margin: margin ?? const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // ── Card Header (Booking Code + Status) ─────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          size: 15,
                          color: AppColors.primaryLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        booking.bookingCode,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                  VehicaStatusChip(status: booking.status),
                ],
              ),
            ),

            Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.divider),

            // ── Card Body (Image + Vehicle Info) ────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Vehicle Thumbnail Image
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: VehicaImage(
                      imageUrl: imgUrl,
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.directions_car_rounded,
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Vehicle Name & Model & Dates
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.vehicleName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${booking.vehicleBrand} · ${booking.vehicleModel}',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 13,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '${VehicaFormatters.formatDate(booking.startDate)} → ${VehicaFormatters.formatDate(booking.endDate)}',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Card Footer (Duration, Total Amount, CTA) ───────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceVariantDark.withValues(alpha: 0.6) : AppColors.backgroundLight,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thời gian thuê: ${booking.rentalDays} ngày',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        VehicaFormatters.formatCurrency(booking.totalAmount),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Chi tiết',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
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
  }
}
