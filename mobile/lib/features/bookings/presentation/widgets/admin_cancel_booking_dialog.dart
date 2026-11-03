import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/widgets/vehica_button.dart';
import 'package:vehica_mobile/features/bookings/domain/entities/booking_entity.dart';
import 'package:vehica_mobile/features/bookings/presentation/controllers/booking_controllers.dart';

/// Dialog for Admin to reject or cancel booking with mandatory reasons (UC-08, BR-16, BR-18)
class AdminCancelBookingDialog extends ConsumerStatefulWidget {
  final BookingSummaryEntity booking;

  const AdminCancelBookingDialog({super.key, required this.booking});

  static Future<void> show(BuildContext context, BookingSummaryEntity booking) {
    return showDialog(
      context: context,
      builder: (_) => AdminCancelBookingDialog(booking: booking),
    );
  }

  @override
  ConsumerState<AdminCancelBookingDialog> createState() => _AdminCancelBookingDialogState();
}

class _AdminCancelBookingDialogState extends ConsumerState<AdminCancelBookingDialog> {
  final _reasonController = TextEditingController();
  String _selectedChip = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _handleCancel(bool isReject) async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) return;

    setState(() => _isLoading = true);
    final success = await ref
        .read(adminBookingsControllerProvider.notifier)
        .updateStatus(widget.booking.id, 'CANCELLED', reason: reason);

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? (isReject ? 'Đã từ chối đơn đặt xe thành công!' : 'Đã hủy đơn đặt xe thành công!')
                : 'Lỗi khi hủy đơn đặt xe.',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isReject = widget.booking.status.toUpperCase() == 'PENDING';

    final chips = isReject
        ? [
            'Khách không thanh toán tiền cọc',
            'Không liên lạc được với khách hàng',
            'Xe đột xuất gặp sự cố kỹ thuật',
            'GPLX / Hồ sơ không hợp lệ',
            'Khách yêu cầu hủy qua hotline',
          ]
        : [
            'Khách yêu cầu hủy chuyến qua hotline',
            'Sự cố kỹ thuật đột xuất từ phía xe',
            'Khách không đến nhận xe (No-show)',
            'Bất khả kháng do thời tiết',
          ];

    return AlertDialog(
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.cancel_outlined, color: AppColors.error, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isReject ? 'Từ chối duyệt đơn (Reject)' : 'Hủy đơn đặt xe (Cancel)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: const Text(
                'Lưu ý: Hành động này sẽ hủy đơn và mở lại slot xe trên lịch cho khách khác.',
                style: TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600),
              ),
            ),
            const Text(
              'Chọn nhanh lý do:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: chips.map((c) {
                final isSelected = _selectedChip == c;
                return ChoiceChip(
                  label: Text(c, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : null)),
                  selected: isSelected,
                  selectedColor: AppColors.error,
                  onSelected: (val) {
                    setState(() {
                      _selectedChip = val ? c : '';
                      if (val) _reasonController.text = c;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Lý do hủy chi tiết *',
                hintText: 'Nhập lý do gửi thông báo cho khách hàng...',
                filled: true,
                fillColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              style: const TextStyle(fontSize: 13),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
        VehicaButton(
          text: isReject ? 'Từ chối đơn' : 'Xác nhận hủy',
          type: VehicaButtonType.danger,
          height: 40,
          borderRadius: 12,
          isLoading: _isLoading,
          onPressed: _reasonController.text.trim().isNotEmpty && !_isLoading ? () => _handleCancel(isReject) : null,
        ),
      ],
    );
  }
}

