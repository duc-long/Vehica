import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehica_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:vehica_mobile/features/auth/presentation/controllers/auth_state.dart';
import 'package:vehica_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:vehica_mobile/features/profile/presentation/pages/profile_page.dart';

// ── Transition builders ────────────────────────────────────────────────────────

CustomTransitionPage<T> _slideUpPage<T>(Widget child, GoRouterState state) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(begin: const Offset(0, 0.06), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic));
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(opacity: fade, child: SlideTransition(position: animation.drive(tween), child: child));
    },
  );
}

CustomTransitionPage<T> _slideRightPage<T>(Widget child, GoRouterState state) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic));
      final fade = CurvedAnimation(parent: animation, curve: const Interval(0, 0.6));
      return FadeTransition(opacity: fade, child: SlideTransition(position: animation.drive(tween), child: child));
    },
  );
}

CustomTransitionPage<T> _fadePage<T>(Widget child, GoRouterState state) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 260),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut), child: child);
    },
  );
}

class AppRouterNotifier extends ChangeNotifier {
  final Ref _ref;
  AppRouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authControllerProvider,
      (previous, next) {
        if (previous?.isAuthenticated != next.isAuthenticated ||
            previous?.isAdmin != next.isAdmin) {
          notifyListeners();
        }
      },
    );
  }

  bool get isAuthenticated => _ref.read(authControllerProvider).isAuthenticated;
  bool get isAdmin => _ref.read(authControllerProvider).isAdmin;
}

final appRouterNotifierProvider = Provider<AppRouterNotifier>((ref) {
  return AppRouterNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final routerNotifier = ref.watch(appRouterNotifierProvider);

  return GoRouter(
    refreshListenable: routerNotifier,
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuth = routerNotifier.isAuthenticated;
      final isGuestAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isForgotPasswordRoute = state.matchedLocation == '/forgot-password';

      if (!isAuth && !isGuestAuthRoute && !isForgotPasswordRoute) return '/login';
      if (isAuth && isGuestAuthRoute) {
        return '/profile';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _fadePage(const LoginPage(), state),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => _slideRightPage(const ProfilePage(), state),
      ),
    ],
  );
});

// Fix [#1]: Route to profile screen upon successful login in Phase 1
