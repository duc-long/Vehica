import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:vehica_mobile/features/home/presentation/widgets/home_category_chips.dart';
import 'package:vehica_mobile/features/home/presentation/widgets/home_fleet_cta_banner.dart';
import 'package:vehica_mobile/features/home/presentation/widgets/home_floating_nav_bar.dart';
import 'package:vehica_mobile/features/home/presentation/widgets/home_header_bar.dart';
import 'package:vehica_mobile/features/home/presentation/widgets/home_hot_deals_carousel.dart';
import 'package:vehica_mobile/features/home/presentation/widgets/home_trust_badges_section.dart';
import 'package:vehica_mobile/features/vehicles/presentation/controllers/vehicle_list_controller.dart';

/// Home Page (S03 - Mobility Hub)
/// Architecture: Orchestrates UI sections with single responsibility widgets.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primaryLight,
          onRefresh: () async {
            await Future.wait([
              ref.read(vehicleListControllerProvider.notifier).loadVehicles(),
              Future(() => ref.invalidate(vehicleTypesProvider)),
            ]);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              // 1. User Header with Avatar & Greeting
              SliverToBoxAdapter(
                child: HomeHeaderBar(
                  user: authState.user,
                  isAdmin: authState.isAdmin,
                  isDark: isDark,
                ),
              ),

              // 2. Category Service Chips (Sedan, SUV, EV, etc.)
              SliverToBoxAdapter(
                child: HomeCategoryChips(
                  isDark: isDark,
                ),
              ),

              // 4. Hot Deals & Suggested Vehicles Carousel
              SliverToBoxAdapter(
                child: HomeHotDealsCarousel(
                  isDark: isDark,
                ),
              ),

              // 5. Trust & Quality Badges
              SliverToBoxAdapter(
                child: HomeTrustBadgesSection(
                  isDark: isDark,
                ),
              ),

              // 6. Explore Full Fleet CTA Banner
              const SliverToBoxAdapter(
                child: HomeFleetCtaBanner(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: HomeFloatingNavBar(isDark: isDark),
    );
  }
}
