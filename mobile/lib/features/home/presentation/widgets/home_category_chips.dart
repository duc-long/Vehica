import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/widgets/vehica_image.dart';
import 'package:vehica_mobile/core/widgets/vehica_skeleton.dart';
import 'package:vehica_mobile/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:vehica_mobile/features/vehicles/presentation/controllers/vehicle_list_controller.dart';

class HomeCategoryChips extends ConsumerWidget {
  final bool isDark;

  const HomeCategoryChips({super.key, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleTypesState = ref.watch(vehicleTypesProvider);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isNarrow = screenWidth < 340;
    final isVeryNarrow = screenWidth < 280;
    final horizontalPad = isVeryNarrow ? 10.0 : (isNarrow ? 14.0 : 20.0);

    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(horizontalPad, 0, horizontalPad, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Dịch vụ theo loại xe',
                    style: TextStyle(
                      fontSize: isNarrow ? 14 : 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
          vehicleTypesState.when(
            data: (types) {
              if (types.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 66,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: horizontalPad),
                  physics: const BouncingScrollPhysics(),
                  itemCount: types.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final type = types[index];
                    return VehicleTypeServiceCard(
                      type: type,
                      isDark: isDark,
                      onTap: () => context.push('/vehicles?typeId=${type.id}'),
                    );
                  },
                ),
              );
            },
            loading: () => SizedBox(
              height: 66,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, __) => const VehicaSkeleton(
                  width: 146,
                  height: 66,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Không thể tải loại xe',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => ref.invalidate(vehicleTypesProvider),
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
        ],
      ),
    );
  }
}

class VehicleTypeServiceCard extends StatelessWidget {
  final VehicleTypeEntity type;
  final bool isDark;
  final VoidCallback onTap;

  const VehicleTypeServiceCard({
    super.key,
    required this.type,
    required this.isDark,
    required this.onTap,
  });

  String _getCategoryHint() {
    if (type.description != null && type.description!.trim().isNotEmpty) {
      return type.description!.trim();
    }
    return 'Khám phá';
  }

  @override
  Widget build(BuildContext context) {
    final imgUrl = type.imageUrl;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 146,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : AppColors.primaryMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: VehicaImage(
                  imageUrl: imgUrl,
                  fit: BoxFit.contain,
                  fallbackIcon: Icons.directions_car_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.name,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getCategoryHint(),
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
