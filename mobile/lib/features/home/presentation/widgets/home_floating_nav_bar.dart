import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';

class HomeFloatingNavBar extends StatelessWidget {
  final bool isDark;

  const HomeFloatingNavBar({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.sizeOf(context).width;
        final isNarrow = screenWidth < 340;
        final isVeryNarrow = screenWidth < 280;

        return SafeArea(
          top: false,
          child: Center(
            heightFactor: 1.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Container(
                margin: EdgeInsets.fromLTRB(
                  isVeryNarrow ? 6 : (isNarrow ? 10 : 16),
                  0,
                  isVeryNarrow ? 6 : (isNarrow ? 10 : 16),
                  isNarrow ? 8 : 12,
                ),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.surfaceDark : Colors.white).withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: NavigationBar(
                  height: isNarrow ? 56 : 64,
                  selectedIndex: 0,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  labelBehavior: isNarrow
                      ? NavigationDestinationLabelBehavior.onlyShowSelected
                      : NavigationDestinationLabelBehavior.alwaysShow,
                  onDestinationSelected: (index) {
                    if (index == 1) context.push('/vehicles');
                    if (index == 2) context.push('/bookings');
                    if (index == 3) context.push('/profile');
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home_rounded, color: AppColors.primaryLight),
                      label: 'Trang chủ',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.explore_outlined),
                      selectedIcon: Icon(Icons.explore_rounded, color: AppColors.primaryLight),
                      label: 'Khám phá',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.receipt_long_outlined),
                      selectedIcon: Icon(Icons.receipt_long_rounded, color: AppColors.primaryLight),
                      label: 'Đơn đặt',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_outline_rounded),
                      selectedIcon: Icon(Icons.person_rounded, color: AppColors.primaryLight),
                      label: 'Tài khoản',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
