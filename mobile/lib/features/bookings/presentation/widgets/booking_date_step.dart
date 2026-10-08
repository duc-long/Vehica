import 'package:flutter/material.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/utils/formatters.dart';
import 'package:vehica_mobile/core/widgets/vehica_button.dart';
import 'package:vehica_mobile/core/widgets/vehica_image.dart';
import 'package:vehica_mobile/features/vehicles/domain/entities/vehicle_entity.dart';

class BookingDateStep extends StatelessWidget {
  final VehicleEntity vehicle;
  final TextEditingController startDateController;
  final TextEditingController endDateController;
  final int rentalDays;
  final ValueChanged<String> onStartDateChanged;
  final ValueChanged<String> onEndDateChanged;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickEndDate;
  final bool isDark;

  const BookingDateStep({
    super.key,
    required this.vehicle,
    required this.startDateController,
    required this.endDateController,
    required this.rentalDays,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onPickStartDate,
    required this.onPickEndDate,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle Header Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 60,
                    height: 50,
                    color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                    child: VehicaImage(
                      imageUrl: vehicle.primaryImageUrl,
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.directions_car_rounded,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${vehicle.brand} • ${vehicle.seatCapacity} chỗ • ${vehicle.type.name}',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${Formatters.currency(vehicle.pricePerDay)}/ngày',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                    color: AppColors.primaryLight,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2 Khung điền ngày: Ngày bắt đầu & Ngày kết thúc
          Row(
            children: [
              Expanded(
                child: BookingDateInputField(
                  label: 'Ngày bắt đầu',
                  controller: startDateController,
                  onChanged: onStartDateChanged,
                  onPickDate: onPickStartDate,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BookingDateInputField(
                  label: 'Ngày kết thúc',
                  controller: endDateController,
                  onChanged: onEndDateChanged,
                  onPickDate: onPickEndDate,
                  isDark: isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Total Days Chip
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF132228) : AppColors.primaryMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  size: 15,
                  color: AppColors.primaryLight,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tổng thời gian thuê: $rentalDays ngày',
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Self-drive Rental Terms & Service Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF132228) : AppColors.primaryMuted,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        color: AppColors.primaryLight,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dịch vụ thuê xe tự lái cao cấp',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Bảo hiểm chuyến đi cơ bản · Hỗ trợ cứu hộ 24/7',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 16, color: AppColors.primaryLight),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Nhận & trả xe tại: Gara Vehica Center (Quận 1, TP.HCM)',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class BookingDateInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onPickDate;
  final bool isDark;

  const BookingDateInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
    required this.onPickDate,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  keyboardType: TextInputType.datetime,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'dd/MM/yyyy',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textDisabledDark : AppColors.textDisabled,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              IconButton(
                onPressed: onPickDate,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: 18,
                icon: const Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: AppColors.primaryLight,
                ),
                tooltip: 'Mở lịch chọn',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BookingStep1BottomBar extends StatelessWidget {
  final int rentalDays;
  final double totalAmount;
  final bool isDark;
  final VoidCallback onNext;

  const BookingStep1BottomBar({
    super.key,
    required this.rentalDays,
    required this.totalAmount,
    required this.isDark,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tạm tính ($rentalDays ngày)',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    Formatters.currency(totalAmount),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: VehicaButton(
              text: 'Tiếp tục xem lại',
              trailingIcon: Icons.arrow_forward_rounded,
              height: 48,
              borderRadius: 14,
              onPressed: onNext,
            ),
          ),
        ],
      ),
    );
  }
}
