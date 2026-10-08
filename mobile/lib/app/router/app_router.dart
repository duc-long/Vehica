import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehica_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:vehica_mobile/features/auth/presentation/controllers/auth_state.dart';
import 'package:vehica_mobile/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:vehica_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:vehica_mobile/features/auth/presentation/pages/register_page.dart';
import 'package:vehica_mobile/features/dashboard/presentation/pages/admin_dashboard_page.dart';
import 'package:vehica_mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:vehica_mobile/features/users/presentation/pages/admin_user_management_page.dart';

// ── Transition builders ────────────────────────────────────────────────────────

/// Slide-up from bottom — used for modal/bottom action pages
CustomTransitionPage<T> _slideUpPage<T>(Widget child, GoRouterState state) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: animation.drive(tween), child: child),
      );
    },
  );
}

/// Slide-right from right — used for standard push pages
CustomTransitionPage<T> _slideRightPage<T>(Widget child, GoRouterState state) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      final fade = CurvedAnimation(
        parent: animation,
        curve: const Interval(0, 0.6),
      );
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: animation.drive(tween), child: child),
      );
    },
  );
}

/// Fade — used for root pages (login, home)
CustomTransitionPage<T> _fadePage<T>(Widget child, GoRouterState state) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 260),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      );
    },
  );
}

// ── Router provider ────────────────────────────────────────────────────────────

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (previous?.isAuthenticated != next.isAuthenticated) {
        notifyListeners();
      }
    });
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authControllerProvider);
    final isAuth = authState.isAuthenticated;
    final isLoggingIn =
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/register' ||
        state.matchedLocation == '/forgot-password';

    if (!isAuth && !isLoggingIn) return '/login';
    if (isAuth && isLoggingIn) return '/profile';
    return null;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      // ── Auth ──────────────────────────────────────────────────────────────
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _fadePage(const LoginPage(), state),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) =>
            _slideRightPage(const RegisterPage(), state),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) =>
            _slideRightPage(const ForgotPasswordPage(), state),
      ),

      // ── Profile ───────────────────────────────────────────────────────────
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) =>
            _slideUpPage(const ProfilePage(), state),
      ),

      // ── Admin ─────────────────────────────────────────────────────────────
      GoRoute(
        path: '/admin/dashboard',
        pageBuilder: (context, state) =>
            _fadePage(const AdminDashboardPage(), state),
      ),
      GoRoute(
        path: '/admin/users',
        pageBuilder: (context, state) =>
            _slideRightPage(const AdminUserManagementPage(), state),
      ),
    ],
  );
});
