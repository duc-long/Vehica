import 'package:flutter/material.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/utils/formatters.dart';

class VehicaDateRangePicker extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime start, DateTime end)? onDateRangeSelected;

  const VehicaDateRangePicker({
    super.key,
    this.startDate,
    this.endDate,
    this.onDateRangeSelected,
  });

  Future<void> _pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    final initialDateRange = (startDate != null && endDate != null)
        ? DateTimeRange(start: startDate!, end: endDate!)
        : DateTimeRange(
            start: now,
            end: now.add(const Duration(days: 2)),
          );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
      initialDateRange: initialDateRange,
      saveText: 'Chọn',
      helpText: 'Chọn thời gian thuê xe',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surfaceLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && onDateRangeSelected != null) {
      onDateRangeSelected!(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasDates = startDate != null && endDate != null;
    final rentalDays = hasDates ? endDate!.difference(startDate!).inDays : 0;

    return GestureDetector(
      onTap: () => _pickDateRange(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariantLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryMuted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thời gian thuê xe',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasDates
                        ? '${VehicaFormatters.formatDate(startDate)} → ${VehicaFormatters.formatDate(endDate)}  ·  $rentalDays ngày'
                        : 'Chọn ngày nhận và trả xe',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: hasDates ? AppColors.textPrimary : AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}
