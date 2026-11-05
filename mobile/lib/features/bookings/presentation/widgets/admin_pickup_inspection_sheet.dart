import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/widgets/vehica_button.dart';
import 'package:vehica_mobile/features/bookings/domain/entities/booking_entity.dart';
import 'package:vehica_mobile/features/bookings/presentation/controllers/booking_controllers.dart';

/// Modal bottom sheet for Admin vehicle pickup inspection & check-in (UC-08, BR-16)
class AdminPickupInspectionSheet extends ConsumerStatefulWidget {
  final BookingSummaryEntity booking;

  const AdminPickupInspectionSheet({super.key, required this.booking});

  static Future<void> show(BuildContext context, BookingSummaryEntity booking) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AdminPickupInspectionSheet(booking: booking),
    );
  }

  @override
  ConsumerState<AdminPickupInspectionSheet> createState() =>
      _AdminPickupInspectionSheetState();
}

class _AdminPickupInspectionSheetState
    extends ConsumerState<AdminPickupInspectionSheet> {
  final _odoController = TextEditingController();
  final _noteController = TextEditingController();
  String _fuelLevel = '100% (Đầy)';
  bool _checkLicense = true;
  bool _checkKeys = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _odoController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirmPickup() async {
    setState(() => _isLoading = true);
    final odo = _odoController.text.trim().isEmpty
        ? 'N/A'
        : '${_odoController.text.trim()} km';
    final note = _noteController.text.trim().isEmpty
        ? 'Ngoại quan bình thường'
        : _noteController.text.trim();
    final reason =
        'Bàn giao xe: ODO $odo | Xăng: $_fuelLevel | GPLX: ${_checkLicense ? "Đã đối chiếu" : "Chưa"} | $note';

    final success = await ref
        .read(adminBookingsControllerProvider.notifier)
        .updateStatus(widget.booking.id, 'PICKED_UP', reason: reason);

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Bàn giao xe cho khách thành công!'
                : 'Lỗi khi cập nhật bàn giao xe.',
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

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
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
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.key_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Biên bản bàn giao xe (Check-in)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${booking.bookingCode} · ${booking.vehicleName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _odoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Số Odometer bàn giao (km) *',
                hintText: 'VD: 35200',
                prefixIcon: const Icon(Icons.speed_rounded, size: 18),
                filled: true,
                fillColor: isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariantLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: const TextStyle(fontSize: 13.5),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _fuelLevel,
              decoration: InputDecoration(
                labelText: 'Mức nhiên liệu / Pin lúc giao',
                prefixIcon: const Icon(
                  Icons.local_gas_station_rounded,
                  size: 18,
                ),
                filled: true,
                fillColor: isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariantLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: '100% (Đầy)',
                  child: Text('100% (Đầy)'),
                ),
                DropdownMenuItem(value: '75%', child: Text('75%')),
                DropdownMenuItem(value: '50%', child: Text('50%')),
                DropdownMenuItem(value: '25%', child: Text('25%')),
              ],
              onChanged: (val) =>
                  setState(() => _fuelLevel = val ?? _fuelLevel),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: _checkLicense,
              dense: true,
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
              title: const Text(
                'Đã đối chiếu bản gốc GPLX & CCCD của khách',
                style: TextStyle(fontSize: 12.5),
              ),
              onChanged: (val) => setState(() => _checkLicense = val ?? false),
            ),
            CheckboxListTile(
              value: _checkKeys,
              dense: true,
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
              title: const Text(
                'Đã bàn giao đủ 2 chìa khóa & giấy tờ lưu hành xe',
                style: TextStyle(fontSize: 12.5),
              ),
              onChanged: (val) => setState(() => _checkKeys = val ?? false),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Ghi chú hiện trạng ngoại thất',
                hintText: 'VD: Xe sạch sẽ, không trầy xước mới...',
                filled: true,
                fillColor: isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariantLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 18),
            VehicaButton(
              text: 'Xác nhận bàn giao xe',
              icon: Icons.key_rounded,
              height: 48,
              borderRadius: 14,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _handleConfirmPickup,
            ),
          ],
        ),
      ),
    );
  }
}
