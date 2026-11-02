import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/utils/formatters.dart';
import 'package:vehica_mobile/core/widgets/vehica_button.dart';
import 'package:vehica_mobile/features/bookings/domain/entities/booking_entity.dart';
import 'package:vehica_mobile/features/bookings/presentation/controllers/booking_controllers.dart';

/// Dialog for Admin to verify deposit and approve booking (UC-08, BR-12, BR-16)
class AdminApproveBookingDialog extends ConsumerStatefulWidget {
  final BookingSummaryEntity booking;

  const AdminApproveBookingDialog({super.key, required this.booking});

  static Future<void> show(BuildContext context, BookingSummaryEntity booking) {
    return showDialog(
      context: context,
      builder: (_) => AdminApproveBookingDialog(booking: booking),
    );
  }

  @override
  ConsumerState<AdminApproveBookingDialog> createState() => _AdminApproveBookingDialogState();
}

class _AdminApproveBookingDialogState extends ConsumerState<AdminApproveBookingDialog> {
  late final TextEditingController _noteController;
  bool _depositVerified = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final depositAmount = widget.booking.totalAmount * 0.3;
    _noteController = TextEditingController(
      text: 'Đã xác minh khách hàng & nhận tiền cọc 30% (${VehicaFormatters.formatCurrency(depositAmount)})',
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleApprove() async {
    setState(() => _isLoading = true);
    final success = await ref
        .read(adminBookingsControllerProvider.notifier)
        .updateStatus(
          widget.booking.id,
          'CONFIRMED',
          reason: _noteController.text.trim(),
        );

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Đã duyệt đơn đặt xe thành công!' : 'Lỗi khi duyệt đơn đặt xe.',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final booking = widget.booking;
    final depositAmount = booking.totalAmount * 0.3;
    final isDatePast = booking.startDate.isBefore(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    );

    return AlertDialog(
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.verified_rounded, color: Color(0xFF3B82F6), size: 20),
          ),
          const SizedBox(width: 10),
          const Text(
            'Duyệt xác nhận cọc',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDatePast) ...[
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cảnh báo: Ngày nhận xe đã đến hoặc ở trong quá khứ!',
                        style: TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: Column(
                children: [
                  _row('Mã đơn', booking.bookingCode, isDark),
                  _row('Khách hàng', booking.customerName, isDark),
                  _row('Xe', '${booking.vehicleName} (${booking.vehicleBrand})', isDark),
                  _row(
                    'Lịch thuê',
                    '${VehicaFormatters.formatDate(booking.startDate)} → ${VehicaFormatters.formatDate(booking.endDate)} (${booking.rentalDays} ngày)',
                    isDark,
                  ),
                  _row('Tổng giá trị', VehicaFormatters.formatCurrency(booking.totalAmount), isDark),
                  _row(
                    'Cọc cần thu (30%)',
                    VehicaFormatters.formatCurrency(depositAmount),
                    isDark,
                    isHighlight: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: _depositVerified,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _depositVerified = val ?? false),
                ),
                const Expanded(
                  child: Text(
                    'Đã xác nhận nhận tiền cọc hợp lệ',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Ghi chú duyệt đơn',
                hintText: 'Nhập ghi chú hoặc mã giao dịch cọc...',
                filled: true,
                fillColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        VehicaButton(
          text: 'Xác nhận duyệt',
          height: 40,
          borderRadius: 12,
          isLoading: _isLoading,
          onPressed: _depositVerified && !_isLoading ? _handleApprove : null,
        ),
      ],
    );
  }

  Widget _row(String label, String value, bool isDark, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
              color: isHighlight ? AppColors.primary : (isDark ? Colors.white : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

