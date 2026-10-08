// ==============================================================================
// VEHICA Design System — Badge / Label Widget
// Used to attach prominent labels: "New", "Hot", "Discount", "EV", "Priority", ...
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';

enum VehicaBadgeStyle { solid, subtle, outline }
enum VehicaBadgeSize { sm, md }

class VehicaBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final VehicaBadgeStyle style;
  final VehicaBadgeSize size;

  const VehicaBadge({
    super.key,
    required this.label,
    this.icon,
    this.color = AppColors.primary,
    this.style = VehicaBadgeStyle.subtle,
    this.size = VehicaBadgeSize.sm,
  });

  const VehicaBadge.subtle({
    super.key,
    required this.label,
    this.icon,
    this.color = AppColors.primary,
    this.size = VehicaBadgeSize.sm,
  }) : style = VehicaBadgeStyle.subtle;

  // ── Factory constructors ───────────────────────────────────────────────────
  const VehicaBadge.hot({super.key, this.size = VehicaBadgeSize.sm})
      : label = 'Hot',
        icon = Icons.local_fire_department_rounded,
        color = AppColors.error,
        style = VehicaBadgeStyle.solid;

  const VehicaBadge.newTag({super.key, this.size = VehicaBadgeSize.sm})
      : label = 'Mới',
        icon = Icons.fiber_new_rounded,
        color = AppColors.primary,
        style = VehicaBadgeStyle.solid;

  const VehicaBadge.isNew({super.key, this.size = VehicaBadgeSize.sm})
      : label = 'Mới',
        icon = Icons.fiber_new_rounded,
        color = AppColors.primary,
        style = VehicaBadgeStyle.solid;

  const VehicaBadge.ev({super.key, this.size = VehicaBadgeSize.sm})
      : label = 'EV',
        icon = Icons.electric_bolt_rounded,
        color = AppColors.secondary,
        style = VehicaBadgeStyle.solid;

  const VehicaBadge.available({super.key, this.size = VehicaBadgeSize.sm})
      : label = 'Sẵn sàng',
        icon = Icons.check_circle_outline_rounded,
        color = AppColors.success,
        style = VehicaBadgeStyle.subtle;

  const VehicaBadge.discount({
    super.key,
    required this.label,
    this.size = VehicaBadgeSize.sm,
  })  : icon = Icons.local_offer_rounded,
        color = AppColors.tertiary,
        style = VehicaBadgeStyle.solid;

  const VehicaBadge.admin({super.key, this.size = VehicaBadgeSize.sm})
      : label = 'Admin',
        icon = Icons.shield_rounded,
        color = AppColors.primary,
        style = VehicaBadgeStyle.subtle;

  const VehicaBadge.customer({super.key, this.size = VehicaBadgeSize.sm})
      : label = 'Khách hàng',
        icon = Icons.person_outline_rounded,
        color = AppColors.textSecondary,
        style = VehicaBadgeStyle.subtle;

  @override
  Widget build(BuildContext context) {
    final isSmall = size == VehicaBadgeSize.sm;
    final hPad = isSmall ? 7.0 : 10.0;
    final vPad = isSmall ? 3.0 : 5.0;
    final fontSize = isSmall ? 10.0 : 12.0;
    final iconSize = isSmall ? 10.0 : 12.0;

    Color bgColor;
    Color textColor;
    Border? border;

    switch (style) {
      case VehicaBadgeStyle.solid:
        bgColor = color;
        textColor = Colors.white;
        border = null;
        break;
      case VehicaBadgeStyle.subtle:
        bgColor = color.withValues(alpha: 0.12);
        textColor = color;
        border = null;
        break;
      case VehicaBadgeStyle.outline:
        bgColor = Colors.transparent;
        textColor = color;
        border = Border.all(color: color, width: 1);
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
        border: border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: textColor),
            SizedBox(width: isSmall ? 3 : 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
