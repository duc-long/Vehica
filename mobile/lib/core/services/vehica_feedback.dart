import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';

class VehicaFeedback {
  VehicaFeedback._();

  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static OverlayEntry? _currentOverlayEntry;
  static Timer? _overlayTimer;

  /// Hiển thị thông báo thành công dạng Luxury SnackBar
  static void showSuccess(String message, {String? title, BuildContext? context}) {
    _showSnackBar(
      message: message,
      title: title,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle_rounded,
      context: context,
    );
  }

  /// Hiển thị thông báo thất bại / lỗi dạng Luxury SnackBar
  static void showError(String message, {String? title, BuildContext? context}) {
    _showSnackBar(
      message: message,
      title: title,
      backgroundColor: AppColors.error,
      icon: Icons.error_outline_rounded,
      context: context,
    );
  }

  /// Hiển thị thông báo thông tin / cảnh báo
  static void showInfo(String message, {String? title, BuildContext? context}) {
    _showSnackBar(
      message: message,
      title: title,
      backgroundColor: AppColors.primary,
      icon: Icons.info_outline_rounded,
      context: context,
    );
  }

  static void _showSnackBar({
    required String message,
    String? title,
    required Color backgroundColor,
    required IconData icon,
    BuildContext? context,
  }) {
    final state = messengerKey.currentState;
    if (state == null && context == null) return;

    final messenger = state ?? ScaffoldMessenger.of(context!);
    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        elevation: 6,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        duration: const Duration(milliseconds: 3200),
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) ...[
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Hiển thị In-App Push Notification dạng Banner trượt từ đỉnh màn hình
  /// Tự động thay thế thông báo cũ để tránh tràn màn hình (Anti-Spam / Debounce)
  static void showInAppPush({
    required String title,
    required String message,
    IconData icon = Icons.notifications_active_rounded,
    VoidCallback? onTap,
    Duration duration = const Duration(milliseconds: 4000),
  }) {
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    // Hủy bỏ thông báo đang hiển thị trước đó để không bị dồn ứ / tràn màn hình
    _dismissCurrentPush();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _TopPushNotificationBanner(
        title: title,
        message: message,
        icon: icon,
        onTap: () {
          _dismissCurrentPush();
          onTap?.call();
        },
        onDismiss: _dismissCurrentPush,
      ),
    );

    _currentOverlayEntry = entry;
    overlay.insert(entry);

    _overlayTimer = Timer(duration, () {
      _dismissCurrentPush();
    });
  }

  static void _dismissCurrentPush() {
    _overlayTimer?.cancel();
    _overlayTimer = null;
    _currentOverlayEntry?.remove();
    _currentOverlayEntry = null;
  }
}

class _TopPushNotificationBanner extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _TopPushNotificationBanner({
    required this.title,
    required this.message,
    required this.icon,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_TopPushNotificationBanner> createState() =>
      _TopPushNotificationBannerState();
}

class _TopPushNotificationBannerState
    extends State<_TopPushNotificationBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 320),
      reverseDuration: const Duration(milliseconds: 240),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleDismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _offsetAnimation,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Dismissible(
              key: const Key('vehica_top_push_banner'),
              direction: DismissDirection.up,
              onDismissed: (_) => widget.onDismiss(),
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: widget.onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161B22) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            widget.icon,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.message,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          color: isDark ? Colors.white54 : Colors.black45,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          onPressed: _handleDismiss,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
