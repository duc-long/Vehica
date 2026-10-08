// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// SCREEN       : S06 - Booking Detail Page
// STYLE        : Dark Slate Luxury, Emerald Teal Accent, Image Banner
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/utils/formatters.dart';
import 'package:vehica_mobile/core/widgets/vehica_back_button.dart';
import 'package:vehica_mobile/core/widgets/vehica_button.dart';
import 'package:vehica_mobile/core/widgets/vehica_image.dart';
import 'package:vehica_mobile/core/widgets/vehica_skeleton.dart';
import 'package:vehica_mobile/core/widgets/vehica_status_chip.dart';
import 'package:vehica_mobile/features/bookings/presentation/controllers/booking_controllers.dart';
import 'package:vehica_mobile/features/bookings/presentation/widgets/booking_cancel_sheet.dart';
import 'package:vehica_mobile/features/bookings/presentation/widgets/booking_detail_card.dart';
import 'package:vehica_mobile/features/bookings/presentation/widgets/booking_timeline_card.dart';

class BookingDetailPage extends ConsumerStatefulWidget {
  final String bookingId;

  const BookingDetailPage({super.key, required this.bookingId});

  @override
  ConsumerState<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends ConsumerState<BookingDetailPage> {
  bool _isCancelling = false;

  Future<void> _handleCancel(String vehicleName) async {
    final reason = await BookingCancelSheet.show(context, vehicleName: vehicleName);

    if (reason != null && reason.isNotEmpty) {
      setState(() => _isCancelling = true);
      final success = await ref
          .read(myBookingsControllerProvider.notifier)
          .cancelBooking(widget.bookingId, reason: reason);

      setState(() => _isCancelling = false);

      if (mounted) {
        ref.invalidate(bookingDetailProvider(widget.bookingId));
        ref.invalidate(bookingHistoryProvider(widget.bookingId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Đã hủy đơn đặt xe thành công!' : 'Không thể hủy đơn lúc này.',
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final detailState = ref.watch(bookingDetailProvider(widget.bookingId));
    final historyState = ref.watch(bookingHistoryProvider(widget.bookingId));

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: const VehicaBackButton(),
        title: Text(
          'Chi tiết đơn đặt xe',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
      ),
      body: detailState.when(
        data: (booking) {
          final vehicle = booking.vehicle;
          final imgUrl = vehicle.primaryImageUrl ??
              (vehicle.images.isNotEmpty ? vehicle.images.first.imageUrl : '');

          return RefreshIndicator(
            color: AppColors.primaryLight,
            onRefresh: () async {
              ref.invalidate(bookingDetailProvider(widget.bookingId));
              ref.invalidate(bookingHistoryProvider(widget.bookingId));
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 36),
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero Vehicle Banner ──────────────────────────────────
                  GestureDetector(
                    onTap: () => context.push('/vehicles/${vehicle.id}'),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Car Image Header
                          Stack(
                            children: [
                              Container(
                                height: 160,
                                width: double.infinity,
                                color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                                child: VehicaImage(
                                  imageUrl: imgUrl,
                                  fit: BoxFit.cover,
                                  fallbackIcon: Icons.directions_car_outlined,
                                ),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: VehicaStatusChip(status: booking.status),
                              ),
                            ],
                          ),

                          // Vehicle Info Inside Card
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vehicle.name,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${vehicle.brand} ${vehicle.model} · ${vehicle.licensePlate}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${vehicle.seatCapacity} chỗ',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Order Code & Date Card ───────────────────────────────
                  BookingDetailCard(
                    child: Column(
                      children: [
                        BookingDetailRow(
                          icon: Icons.receipt_long_rounded,
                          label: 'Mã đơn đặt xe',
                          value: booking.bookingCode,
                          isHighlight: true,
                        ),
                        const Divider(height: 18),
                        BookingDetailRow(
                          icon: Icons.access_time_rounded,
                          label: 'Thời gian tạo đơn',
                          value: VehicaFormatters.formatDateTime(booking.createdAt),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Rental Schedule Card ─────────────────────────────────
                  const BookingSectionHeader(title: 'Lịch trình thuê xe'),
                  const SizedBox(height: 8),
                  BookingDetailCard(
                    child: Column(
                      children: [
                        const BookingDetailRow(
                          icon: Icons.location_on_rounded,
                          label: 'Địa điểm nhận & trả',
                          value: 'Gara Vehica Center · Quận 1, TP.HCM',
                        ),
                        const Divider(height: 18),
                        BookingDetailRow(
                          icon: Icons.event_available_rounded,
                          label: 'Ngày nhận xe',
                          value: VehicaFormatters.formatDate(booking.startDate),
                        ),
                        const Divider(height: 18),
                        BookingDetailRow(
                          icon: Icons.event_busy_rounded,
                          label: 'Ngày trả xe',
                          value: VehicaFormatters.formatDate(booking.endDate),
                        ),
                        const Divider(height: 18),
                        BookingDetailRow(
                          icon: Icons.timelapse_rounded,
                          label: 'Tổng thời gian thuê',
                          value: '${booking.rentalDays} ngày (24h / ngày)',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Payment Breakdown Card ───────────────────────────────
                  const BookingSectionHeader(title: 'Chi tiết thanh toán'),
                  const SizedBox(height: 8),
                  BookingDetailCard(
                    child: Column(
                      children: [
                        BookingDetailRow(
                          icon: Icons.sell_outlined,
                          label: 'Đơn giá thuê',
                          value: '${VehicaFormatters.formatCurrency(booking.pricePerDay)} / ngày',
                        ),
                        const Divider(height: 18),
                        BookingDetailRow(
                          icon: Icons.calculate_outlined,
                          label: 'Thời gian tính giá',
                          value: '${booking.rentalDays} ngày',
                        ),
                        const Divider(height: 18),
                        BookingDetailRow(
                          icon: Icons.monetization_on_rounded,
                          label: 'Tổng tiền thanh toán',
                          value: VehicaFormatters.formatCurrency(booking.totalAmount),
                          isHighlight: true,
                        ),
                      ],
                    ),
                  ),

                  // ── Customer Notes if any ────────────────────────────────
                  if (booking.note != null && booking.note!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const BookingSectionHeader(title: 'Ghi chú của bạn'),
                    const SizedBox(height: 8),
                    BookingDetailCard(
                      child: Text(
                        booking.note!,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],

                  // ── Status History Timeline ──────────────────────────────
                  const SizedBox(height: 16),
                  const BookingSectionHeader(title: 'Lịch sử tiến trình'),
                  const SizedBox(height: 8),
                  historyState.when(
                    data: (histories) => BookingTimelineCard(histories: histories),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  // ── Cancel Action Button ─────────────────────────────────
                  if (booking.isCancellable) ...[
                    const SizedBox(height: 24),
                    VehicaButton(
                      type: VehicaButtonType.danger,
                      text: 'Hủy đơn đặt xe này',
                      icon: Icons.cancel_outlined,
                      isLoading: _isCancelling,
                      height: 48,
                      borderRadius: 14,
                      onPressed: _isCancelling ? null : () => _handleCancel(vehicle.name),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
        loading: () => const BookingDetailSkeleton(),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 44, color: AppColors.error),
                const SizedBox(height: 12),
                const Text(
                  'Không thể tải chi tiết đơn đặt xe',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Vui lòng thử lại sau giây lát',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    ref.invalidate(bookingDetailProvider(widget.bookingId));
                    ref.invalidate(bookingHistoryProvider(widget.bookingId));
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
