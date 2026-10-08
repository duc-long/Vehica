import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/utils/formatters.dart';
import 'package:vehica_mobile/core/widgets/vehica_button.dart';
import 'package:vehica_mobile/features/vehicles/domain/entities/vehicle_entity.dart';

class BookingSuccessStep extends StatelessWidget {
  final String? createdBookingId;
  final String? createdBookingCode;
  final VehicleEntity vehicle;
  final DateTime startDate;
  final DateTime endDate;
  final int rentalDays;
  final double totalAmount;
  final bool isDark;

  const BookingSuccessStep({
    super.key,
    required this.createdBookingId,
    required this.createdBookingCode,
    required this.vehicle,
    required this.startDate,
    required this.endDate,
    required this.rentalDays,
    required this.totalAmount,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Success animated badge
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.primaryLight,
              size: 44,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Đặt xe thành công!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Yêu cầu thuê xe đã được hệ thống ghi nhận.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 24),

          // Receipt Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mã đơn đặt xe',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      createdBookingCode ?? '#VH-RENTAL',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(
                    height: 1,
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                BookingReceiptRow(
                  label: 'Trạng thái',
                  valueWidget: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Chờ duyệt cọc',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                BookingReceiptRow(
                  label: 'Phương tiện',
                  value: vehicle.name,
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                BookingReceiptRow(
                  label: 'Thời gian thuê',
                  value: '${DateFormat('dd/MM').format(startDate)} ➔ ${DateFormat('dd/MM/yyyy').format(endDate)} ($rentalDays ngày)',
                  isDark: isDark,
                ),

                const SizedBox(height: 10),
                BookingReceiptRow(
                  label: 'Địa điểm nhận xe',
                  value: 'Gara Vehica Center (Q.1, TP.HCM)',
                  isDark: isDark,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(
                    height: 1,
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tổng thanh toán',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      Formatters.currency(totalAmount),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Notice callout
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131D2A) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? const Color(0xFF22354B) : const Color(0xFFBFDBFE),
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF38BDF8)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Đội ngũ Vehica sẽ liên hệ quý khách trong vòng 15 phút để hoàn tất thủ tục xác nhận và đặt cọc.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF94A3B8),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Actions
          VehicaButton(
            text: 'Xem chi tiết đơn đặt',
            icon: Icons.receipt_long_rounded,
            height: 48,
            borderRadius: 14,
            onPressed: () {
              if (createdBookingId != null) {
                context.go('/bookings/$createdBookingId');
              } else {
                context.go('/bookings');
              }
            },
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 46),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            onPressed: () => context.go('/home'),
            child: Text(
              'Về trang chủ',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BookingReceiptRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  final bool isDark;

  const BookingReceiptRow({
    super.key,
    required this.label,
    this.value,
    this.valueWidget,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
        if (valueWidget != null)
          valueWidget!
        else
          Text(
            value ?? '',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
      ],
    );
  }
}
