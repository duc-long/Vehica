import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/services/vehica_feedback.dart';
import 'package:vehica_mobile/features/favorites/presentation/controllers/favorite_controller.dart';
import 'package:vehica_mobile/features/vehicles/domain/entities/vehicle_entity.dart';

class VehicaFavoriteButton extends ConsumerStatefulWidget {
  final VehicleEntity vehicle;
  final double size;
  final double iconSize;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool showBackground;

  const VehicaFavoriteButton({
    super.key,
    required this.vehicle,
    this.size = 38,
    this.iconSize = 20,
    this.activeColor,
    this.inactiveColor,
    this.showBackground = true,
  });

  @override
  ConsumerState<VehicaFavoriteButton> createState() => _VehicaFavoriteButtonState();
}

class _VehicaFavoriteButtonState extends ConsumerState<VehicaFavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.28), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.28, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    HapticFeedback.lightImpact();
    _animController.forward(from: 0.0);

    try {
      final isNowFavorite = await ref
          .read(favoriteControllerProvider.notifier)
          .toggleFavorite(widget.vehicle);

      if (mounted) {
        if (isNowFavorite) {
          VehicaFeedback.showSuccess('Đã thêm "${widget.vehicle.name}" vào danh sách yêu thích');
        } else {
          VehicaFeedback.showInfo('Đã bỏ "${widget.vehicle.name}" khỏi danh sách yêu thích');
        }
      }
    } catch (e) {
      if (mounted) {
        VehicaFeedback.showError('Không thể cập nhật danh sách yêu thích. Vui lòng thử lại.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFav = ref.watch(favoriteControllerProvider.select((s) => s.isFavorite(widget.vehicle.id)));

    final heartColor = isFav
        ? (widget.activeColor ?? const Color(0xFFEF4444)) // Vibrant coral red
        : (widget.inactiveColor ?? (isDark ? Colors.white70 : AppColors.textSecondary));

    final childWidget = ScaleTransition(
      scale: _scaleAnimation,
      child: Icon(
        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        size: widget.iconSize,
        color: heartColor,
      ),
    );

    if (!widget.showBackground) {
      return IconButton(
        onPressed: _handleTap,
        icon: childWidget,
        splashRadius: widget.size / 1.5,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(widget.size / 2),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (isDark ? const Color(0xFF141820) : Colors.white).withValues(alpha: 0.85),
            border: Border.all(
              color: isFav
                  ? heartColor.withValues(alpha: 0.35)
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: childWidget,
        ),
      ),
    );
  }
}
