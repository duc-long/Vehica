import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehica_mobile/core/services/vehica_feedback.dart';
import 'package:vehica_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:vehica_mobile/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:vehica_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:vehica_mobile/features/auth/presentation/pages/register_page.dart';
import 'package:vehica_mobile/features/bookings/presentation/pages/admin_booking_management_page.dart';
import 'package:vehica_mobile/features/bookings/presentation/pages/booking_detail_page.dart';
import 'package:vehica_mobile/features/bookings/presentation/pages/create_booking_page.dart';
import 'package:vehica_mobile/features/bookings/presentation/pages/my_bookings_page.dart';
import 'package:vehica_mobile/features/brands/presentation/pages/admin_brand_management_page.dart';
import 'package:vehica_mobile/features/dashboard/presentation/pages/admin_dashboard_page.dart';
import 'package:vehica_mobile/features/fleet/presentation/pages/fleet_availability_page.dart';
import 'package:vehica_mobile/features/home/presentation/pages/home_page.dart';
import 'package:vehica_mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:vehica_mobile/features/users/presentation/pages/admin_user_management_page.dart';
import 'package:vehica_mobile/features/vehicles/presentation/pages/admin_vehicle_management_page.dart';
import 'package:vehica_mobile/features/vehicles/presentation/pages/vehicle_catalog_page.dart';
import 'package:vehica_mobile/features/vehicles/presentation/pages/vehicle_detail_page.dart';


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
      final fade = CurvedAnimation(parent: animation, curve: const Interval(0, 0.6));
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
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: VehicaFeedback.navigatorKey,
    initialLocation: '/home',
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';

      if (!isAuth && !isLoggingIn) return '/login';
      if (isAuth && isLoggingIn) {
        return authState.isAdmin ? '/admin/dashboard' : '/home';
      }
      return null;
    },
    routes: [
      // ── Auth ──────────────────────────────────────────────────────────────
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _fadePage(const LoginPage(), state),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => _slideRightPage(
          Scaffold(
            appBar: AppBar(
              title: const Text('Tạo tài khoản'),
            ),
            body: const RegisterPage(),
          ),
          state,
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) {
          final email = state.uri.queryParameters['email'];
          return _slideRightPage(ForgotPasswordPage(initialEmail: email), state);
        },
      ),

      // ── Home ──────────────────────────────────────────────────────────────
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => _fadePage(const HomePage(), state),
      ),

      // ── Vehicles ──────────────────────────────────────────────────────────
      GoRoute(
        path: '/vehicles',
        pageBuilder: (context, state) {
          final typeId = state.uri.queryParameters['typeId'];
          final brand = state.uri.queryParameters['brand'];
          final keyword = state.uri.queryParameters['keyword'];
          final seats = int.tryParse(state.uri.queryParameters['seats'] ?? '');
          return _slideRightPage(
            VehicleCatalogPage(
              initialTypeId: typeId,
              initialBrand: brand,
              initialKeyword: keyword,
              initialSeatCapacity: seats,
            ),
            state,
          );
        },
      ),

      GoRoute(
        path: '/vehicles/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _slideRightPage(VehicleDetailPage(vehicleId: id), state);
        },
      ),

      // ── Bookings ──────────────────────────────────────────────────────────
      GoRoute(
        path: '/bookings/create',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return _slideUpPage(CreateBookingPage(extraData: extra), state);
        },
      ),
      GoRoute(
        path: '/bookings',
        pageBuilder: (context, state) =>
            _slideRightPage(const MyBookingsPage(), state),
      ),
      GoRoute(
        path: '/bookings/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _slideRightPage(BookingDetailPage(bookingId: id), state);
        },
      ),

      // ── Profile ───────────────────────────────────────────────────────────
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) =>
            _slideRightPage(const ProfilePage(), state),
      ),

      // ── Admin ─────────────────────────────────────────────────────────────
      GoRoute(
        path: '/admin/dashboard',
        pageBuilder: (context, state) =>
            _fadePage(const AdminDashboardPage(), state),
      ),
      GoRoute(
        path: '/admin/vehicles',
        pageBuilder: (context, state) =>
            _slideRightPage(const AdminVehicleManagementPage(), state),
      ),
      GoRoute(
        path: '/admin/fleet',
        pageBuilder: (context, state) =>
            _slideRightPage(const FleetAvailabilityPage(), state),
      ),
      GoRoute(
        path: '/admin/brands',
        pageBuilder: (context, state) =>
            _slideRightPage(const AdminBrandManagementPage(), state),
      ),
      GoRoute(
        path: '/admin/users',
        pageBuilder: (context, state) =>
            _slideRightPage(const AdminUserManagementPage(), state),
      ),
      GoRoute(
        path: '/admin/bookings',
        pageBuilder: (context, state) =>
            _slideRightPage(const AdminBookingManagementPage(), state),
      ),
    ],
  );
});
