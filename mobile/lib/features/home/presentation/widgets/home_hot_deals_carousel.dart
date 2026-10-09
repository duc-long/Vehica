import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/widgets/vehica_skeleton.dart';
import 'package:vehica_mobile/features/vehicles/presentation/controllers/vehicle_list_controller.dart';
import 'package:vehica_mobile/features/vehicles/presentation/widgets/hot_deal_card.dart';

class HomeHotDealsCarousel extends ConsumerWidget {
  final bool isDark;

  const HomeHotDealsCarousel({super.key, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleListState = ref.watch(vehicleListControllerProvider);
    final vehicleState = vehicleListState.vehicles;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isNarrow = screenWidth < 340;
    final isVeryNarrow = screenWidth < 280;
    final horizontalPad = isVeryNarrow ? 10.0 : (isNarrow ? 14.0 : 20.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: EdgeInsets.fromLTRB(horizontalPad, 8, horizontalPad, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Xe đề xuất hôm nay',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isNarrow ? 14 : 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => context.push('/vehicles'),
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Carousel List
        SizedBox(
          height: (244 * MediaQuery.textScalerOf(context).scale(1.0)).clamp(244.0, 280.0),
          child: vehicleState.when(
            data: (vehicles) {
              final hotDeals = vehicles.take(5).toList();
              if (hotDeals.isEmpty) {
                return Center(
                  child: Text(
                    'Chưa có xe khả dụng',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                );
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: horizontalPad),
                physics: const BouncingScrollPhysics(),
                itemCount: hotDeals.length,
                itemBuilder: (context, index) {
                  final vehicle = hotDeals[index];
                  return HotDealCard(
                    vehicle: vehicle,
                    onTap: () => context.push('/vehicles/${vehicle.id}'),
                    onRentNow: () => context.push('/vehicles/${vehicle.id}'),
                  );
                },
              );
            },
            loading: () => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 3,
              itemBuilder: (_, __) => const HotDealSkeleton(),
            ),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      size: 28,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Không thể tải xe đề xuất',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => ref.read(vehicleListControllerProvider.notifier).loadVehicles(),
                      child: const Text(
                        'Thử lại',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
