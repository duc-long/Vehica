import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/widgets/vehica_back_button.dart';
import 'package:vehica_mobile/core/widgets/vehica_button.dart';
import 'package:vehica_mobile/core/widgets/vehica_skeleton.dart';
import 'package:vehica_mobile/features/favorites/presentation/controllers/favorite_controller.dart';
import 'package:vehica_mobile/features/favorites/presentation/widgets/favorite_vehicle_card.dart';

class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(favoriteControllerProvider.notifier).loadFavoriteVehicles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favoriteState = ref.watch(favoriteControllerProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: const VehicaBackButton(),
        title: Text(
          'Xe yêu thích',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        actions: [
          if (favoriteState.favoriteVehicles.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${favoriteState.favoriteVehicles.length} xe',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryLight,
        onRefresh: () async {
          await ref.read(favoriteControllerProvider.notifier).loadFavoriteVehicles(refresh: true);
        },
        child: _buildBody(context, favoriteState, isDark),
      ),
    );
  }

  Widget _buildBody(BuildContext context, FavoriteState state, bool isDark) {
    if (state.isVehiclesLoading && state.favoriteVehicles.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: VehicaSkeleton(
            width: double.infinity,
            height: 240,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    }

    if (state.error != null && state.favoriteVehicles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 52, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                'Không thể tải danh sách xe yêu thích',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              VehicaButton(
                text: 'Thử lại',
                type: VehicaButtonType.primary,
                height: 44,
                onPressed: () {
                  ref.read(favoriteControllerProvider.notifier).loadFavoriteVehicles(refresh: true);
                },
              ),
            ],
          ),
        ),
      );
    }

    if (state.favoriteVehicles.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (isDark ? const Color(0xFF1E2430) : const Color(0xFFE2E8F0)).withValues(alpha: 0.6),
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        size: 44,
                        color: AppColors.primaryLight,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Chưa có xe yêu thích',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy nhấn vào biểu tượng trái tim trên bất kỳ chiếc xe nào bạn quan tâm để dễ dàng xem lại tại đây.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    VehicaButton(
                      text: 'Khám phá xe ngay',
                      icon: Icons.explore_outlined,
                      type: VehicaButtonType.primary,
                      height: 48,
                      onPressed: () => context.push('/vehicles'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: state.favoriteVehicles.length,
      itemBuilder: (context, index) {
        final vehicle = state.favoriteVehicles[index];
        return FavoriteVehicleCard(
          key: ValueKey(vehicle.id),
          vehicle: vehicle,
        );
      },
    );
  }
}
