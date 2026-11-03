import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/utils/formatters.dart';
import 'package:vehica_mobile/core/widgets/vehica_button.dart';
import 'package:vehica_mobile/features/bookings/domain/entities/booking_entity.dart';
import 'package:vehica_mobile/features/bookings/presentation/controllers/booking_controllers.dart';

/// Modal bottom sheet for Admin vehicle return inspection & check-out (UC-08, BR-16)
class AdminReturnInspectionSheet extends ConsumerStatefulWidget {
  final BookingSummaryEntity booking;

  const AdminReturnInspectionSheet({super.key, required this.booking});

  static Future<void> show(BuildContext context, BookingSummaryEntity booking) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => AdminReturnInspectionSheet(booking: booking),
    );
  }

  @override
  ConsumerState<AdminReturnInspectionSheet> createState() => _AdminReturnInspectionSheetState();
}

class _AdminReturnInspectionSheetState extends ConsumerState<AdminReturnInspectionSheet> {
  final _odoController = TextEditingController();
  final _surchargeController = TextEditingController(text: '0');
  final _noteController = TextEditingController();
  String _fuelLevel = '100% (Đầy)';
  bool _isLoading = false;

  @override
  void dispose() {
    _odoController.dispose();
    _surchargeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirmReturn() async {
    setState(() => _isLoading = true);
    final odo = _odoController.text.trim().isEmpty ? 'N/A' : '${_odoController.text.trim()} km';
    final fee = _surchargeController.text.trim().isEmpty ? '0' : _surchargeController.text.trim();
    final note = _noteController.text.trim().isEmpty ? 'Hoàn tất trả xe thành công' : _noteController.text.trim();
    final reason = 'Nghiệm thu trả xe: ODO $odo | Xăng: $_fuelLevel | Phụ phí: $fee ₫ | $note';

    final success = await ref
        .read(adminBookingsControllerProvider.notifier)
        .updateStatus(widget.booking.id, 'COMPLETED', reason: reason);

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Nghiệm thu trả xe & hoàn tất hợp đồng thành công!' : 'Lỗi khi nghiệm thu trả xe.',
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

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final returnDue = DateTime(booking.endDate.year, booking.endDate.month, booking.endDate.day);
    final isLate = today.isAfter(returnDue);
    final lateDays = isLate ? today.difference(returnDue).inDays : 0;
    final suggestedLateFee = lateDays * booking.pricePerDay;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.task_alt_rounded, color: AppColors.success, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nghiệm thu trả xe & Hoàn tất',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '${booking.bookingCode} · ${booking.vehicleName}',
                        style: const TextStyle(fontSize: 12, color: AppColors.primaryLight, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (isLate) ...[
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.alarm_on_rounded, color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Khách trả trễ $lateDays ngày! Gợi ý phụ phí phạt trễ: ${VehicaFormatters.formatCurrency(suggestedLateFee)}.',
                        style: const TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 18),
                    SizedBox(width: 8),
                    Text('Khách hàng trả xe đúng hạn quy định.',
                        style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
            TextField(
              controller: _odoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Số Odometer lúc trả (km) *',
                hintText: 'VD: 35650',
                prefixIcon: const Icon(Icons.speed_rounded, size: 18),
                filled: true,
                fillColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              style: const TextStyle(fontSize: 13.5),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _fuelLevel,
              decoration: InputDecoration(
                labelText: 'Mức nhiên liệu / Pin lúc trả',
                prefixIcon: const Icon(Icons.local_gas_station_rounded, size: 18),
                filled: true,
                fillColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: const [
                DropdownMenuItem(value: '100% (Đầy)', child: Text('100% (Đầy)')),
                DropdownMenuItem(value: '75%', child: Text('75%')),
                DropdownMenuItem(value: '50%', child: Text('50%')),
                DropdownMenuItem(value: '25%', child: Text('25%')),
              ],
              onChanged: (val) => setState(() => _fuelLevel = val ?? _fuelLevel),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _surchargeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Phụ phí phát sinh thu thêm (₫)',
                hintText: '0 (Phí trễ, xăng, rửa xe, hư hại...)',
                prefixIcon: const Icon(Icons.payments_outlined, size: 18),
                filled: true,
                fillColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              style: const TextStyle(fontSize: 13.5),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Ghi chú nghiệm thu xe',
                hintText: 'VD: Xe sạch sẽ, đầy đủ thiết bị, hoàn tất quyết toán...',
                filled: true,
                fillColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 18),
            VehicaButton(
              text: 'Xác nhận hoàn tất trả xe',
              icon: Icons.check_circle_rounded,
              height: 48,
              borderRadius: 14,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _handleConfirmReturn,
            ),
          ],
        ),
      ),
    );
  }
}

