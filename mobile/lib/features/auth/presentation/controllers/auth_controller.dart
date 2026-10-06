// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// PRESENTATION LAYER      : AuthController (StateNotifier)
// USE CASES HANDLED       : UC-01 (Authentication/Login), UC-02 (Registration), UC-03 (User Profile), UC-14 (Forgot Password & OTP)
// BUSINESS RULES / BR     : BR-01, BR-02, BR-03 (Account Status ACTIVE/SUSPENDED), BR-23
// ------------------------------------------------------------------------------
// ARCHITECTURAL DATA FLOW :
// UI (Login / Register / Profile / ForgotPassword)
//   --> AuthController (StateNotifier)
//   --> AuthRepository (Domain Interface)
//   --> AuthRepositoryImpl (Data Implementation)
//   --> AuthRemoteDataSource (Dio HTTP Client)
//   --> Spring Boot REST API (/api/auth/* & /api/users/profile)
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/app/providers.dart';
import 'package:vehica_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:vehica_mobile/features/auth/presentation/controllers/auth_state.dart';


/// Manages authentication state, active user session, and credentials lifecycle (UC-01, UC-02, UC-03, UC-14).
class AuthController extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  final Ref ref;

  AuthController({
    required this.authRepository,
    required this.ref,
  }) : super(const AuthState()) {
    checkAuthStatus();
  }

  /// Verifies authenticated session from locally persisted secure storage token (UC-01).
  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
      }
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
    }
  }

  /// Authenticates user and invalidates session providers upon successful login (UC-01, BR-01, BR-03).
  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await authRepository.login(email: email, password: password);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', '').replaceAll('ServerException: ', ''),
      );
      return false;
    }
  }

  /// Registers a new customer account (UC-02, BR-01, BR-02).
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await authRepository.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', '').replaceAll('ServerException: ', ''),
      );
      return false;
    }
  }

  /// Updates authenticated user profile details (UC-03, FR-PRO-02).
  Future<bool> updateProfile({
    required String fullName,
    required String phone,
    String? avatarUrl,
  }) async {
    try {
      final updated = await authRepository.updateProfile(
        fullName: fullName,
        phone: phone,
        avatarUrl: avatarUrl,
      );
      state = state.copyWith(user: updated);
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString().replaceAll('Exception: ', '').replaceAll('ServerException: ', ''),
      );
      return false;
    }
  }

  /// Dispatches a password reset OTP request (UC-14, BR-23).
  Future<String?> forgotPassword(String email) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final res = await authRepository.forgotPassword(email.trim().toLowerCase());
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return res['otp']?.toString() ?? '123456';
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', '').replaceAll('ServerException: ', ''),
      );
      return null;
    }
  }

  /// Resets user password using the verified OTP code (UC-14, BR-02).
  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await authRepository.resetPassword(
        email: email.trim().toLowerCase(),
        otp: otp.trim(),
        newPassword: newPassword,
      );
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', '').replaceAll('ServerException: ', ''),
      );
      return false;
    }
  }

  /// Clears secure token, resets auth state, and invalidates session providers.
  Future<void> logout() async {
    await authRepository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated, user: null);
  }
}


final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepo, ref: ref);
});
