import 'package:flutter/material.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';

class HomeTrustBadgesSection extends StatelessWidget {
  final bool isDark;

  const HomeTrustBadgesSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.sizeOf(context).width;
        final isNarrow = screenWidth < 340;
        final isVeryNarrow = screenWidth < 280;

        final badges = [
          _TrustBadgeCard(
            icon: Icons.verified_user_rounded,
            title: 'Bảo hiểm 2 chiều',
            subtitle: 'An tâm trọn vẹn',
            isDark: isDark,
            isCompact: isNarrow,
          ),
          _TrustBadgeCard(
            icon: Icons.electric_car_rounded,
            title: 'Xe đời mới 100%',
            subtitle: 'Bảo dưỡng định kỳ',
            isDark: isDark,
            isCompact: isNarrow,
          ),
          _TrustBadgeCard(
            icon: Icons.badge_rounded,
            title: 'Thủ tục 5 phút',
            subtitle: 'Chỉ cần CCCD/GPLX',
            isDark: isDark,
            isCompact: isNarrow,
          ),
          _TrustBadgeCard(
            icon: Icons.support_agent_rounded,
            title: 'Hỗ trợ 24/7',
            subtitle: 'Cứu hộ toàn quốc',
            isDark: isDark,
            isCompact: isNarrow,
          ),
        ];

        Widget badgesGrid;
        if (constraints.maxWidth > 600) {
          badgesGrid = Row(
            children: badges
                .map((b) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: b,
                      ),
                    ))
                .toList(),
          );
        } else if (constraints.maxWidth < 320) {
          // 1 column on narrow screens so text has full width and is never truncated
          badgesGrid = Column(
            children: badges
                .map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: b,
                    ))
                .toList(),
          );
        } else {
          badgesGrid = Column(
            children: [
              Row(children: [
                Expanded(child: badges[0]),
                const SizedBox(width: 8),
                Expanded(child: badges[1]),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: badges[2]),
                const SizedBox(width: 8),
                Expanded(child: badges[3]),
              ]),
            ],
          );
        }

        return Padding(
          padding: EdgeInsets.fromLTRB(
            isVeryNarrow ? 10 : (isNarrow ? 14 : 20),
            16,
            isVeryNarrow ? 10 : (isNarrow ? 14 : 20),
            12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cam kết chất lượng Vehica',
                style: TextStyle(
                  fontSize: isNarrow ? 14 : 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              badgesGrid,
            ],
          ),
        );
      },
    );
  }
}

class _TrustBadgeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final bool isCompact;

  const _TrustBadgeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isCompact ? 6 : 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: isCompact ? 18 : 20,
              color: AppColors.primaryLight,
            ),
          ),
          SizedBox(width: isCompact ? 6 : 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isCompact ? 11 : 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: isCompact ? 9 : 10,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
