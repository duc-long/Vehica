import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/utils/formatters.dart';
import 'package:vehica_mobile/core/widgets/vehica_image.dart';
import 'package:vehica_mobile/core/widgets/vehica_status_chip.dart';
import 'package:vehica_mobile/features/fleet/domain/entities/fleet_schedule_entity.dart';
import 'package:vehica_mobile/features/fleet/presentation/controllers/fleet_schedule_controller.dart';
import 'package:vehica_mobile/features/vehicles/domain/entities/vehicle_entity.dart';

class FleetVehicleTile extends ConsumerStatefulWidget {
  final VehicleEntity vehicle;
  final DateTime startDate;
  final DateTime endDate;
  final bool isDark;

  const FleetVehicleTile({
    super.key,
    required this.vehicle,
    required this.startDate,
    required this.endDate,
    required this.isDark,
  });

  @override
  ConsumerState<FleetVehicleTile> createState() => _FleetVehicleTileState();
}

class _FleetVehicleTileState extends ConsumerState<FleetVehicleTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final vehicle = widget.vehicle;

    final scheduleQuery = VehicleScheduleQuery(
      vehicleId: vehicle.id,
      startDate: widget.startDate,
      endDate: widget.endDate,
    );

    final scheduleAsync = (vehicle.status == 'MAINTENANCE' || vehicle.status == 'INACTIVE')
        ? null
        : ref.watch(vehicleScheduleFamilyProvider(scheduleQuery));

    return Container(
      padding: const EdgeInsets.all(14.0),
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
          // ── Header: Thumbnail, Name, License Plate & Status ─────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: VehicaImage(
                    imageUrl: vehicle.primaryImageUrl,
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
                    const SizedBox(height: 3),
                    Text(
                      'Biển số: ${vehicle.licensePlate} · ${vehicle.brand} ${vehicle.model}',
                      style: TextStyle(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              VehicaStatusChip(
                status: vehicle.status,
                type: VehicaChipType.vehicleStatus,
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 0.8),
          const SizedBox(height: 10),

          // ── Schedule & Availability Info for Date Range ─────────────────────
          if (vehicle.status == 'MAINTENANCE')
            _buildInfoBanner(
              icon: Icons.build_circle_outlined,
              color: AppColors.warning,
              bgColor: isDark ? AppColors.warningBg : const Color(0xFFFEF3C7),
              text: 'Xe đang trong xưởng bảo dưỡng định kỳ',
            )
          else if (vehicle.status == 'INACTIVE')
            _buildInfoBanner(
              icon: Icons.block_rounded,
              color: AppColors.textDisabled,
              bgColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
              text: 'Xe đang ở trạng thái ngừng hoạt động',
            )
          else if (scheduleAsync != null)
            scheduleAsync.when(
              data: (slots) {
                if (slots.isEmpty) {
                  return _buildInfoBanner(
                    icon: Icons.check_circle_outline_rounded,
                    color: AppColors.primaryLight,
                    bgColor: isDark ? AppColors.primaryMuted : AppColors.primaryMutedLight,
                    text: 'Trống lịch · Sẵn sàng cho thuê (${VehicaFormatters.formatDate(widget.startDate)} - ${VehicaFormatters.formatDate(widget.endDate)})',
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => setState(() => _isExpanded = !_isExpanded),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF332211) : const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? const Color(0xFF7C2D12) : const Color(0xFFFFEDD5),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.event_busy_rounded,
                              size: 18,
                              color: AppColors.tertiary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Có ${slots.length} đơn đặt trong khoảng ngày này',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFFFDBA74) : const Color(0xFFC2410C),
                                ),
                              ),
                            ),
                            Icon(
                              _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                              size: 20,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_isExpanded) ...[
                      const SizedBox(height: 8),
                      ...slots.map(
                        (slot) => _buildBookingSlotItem(slot, isDark, context),
                      ),
                    ],
                  ],
                );
              },
              loading: () => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Đang kiểm tra lịch trình xe...',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              error: (err, _) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.errorBg : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.error),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Không thể kiểm tra lịch: $err',
                        style: const TextStyle(fontSize: 11.5, color: AppColors.error),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSlotItem(VehicleScheduleSlot slot, bool isDark, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          if (slot.id.isNotEmpty) {
            context.push('/bookings/${slot.id}');
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.confirmation_number_outlined, size: 14, color: AppColors.primaryLight),
                    const SizedBox(width: 4),
                    Text(
                      '#${slot.bookingCode}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ],
                ),
                VehicaStatusChip(
                  status: slot.status,
                  type: VehicaChipType.bookingStatus,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.date_range_rounded, size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${VehicaFormatters.formatDate(slot.startDate)} → ${VehicaFormatters.formatDate(slot.endDate)}',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.person_outline_rounded, size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  slot.customerName,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
