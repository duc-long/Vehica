import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/app/providers.dart';
import 'package:vehica_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:vehica_mobile/features/auth/presentation/controllers/auth_state.dart';

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  final Ref ref;

  AuthController({
    required this.authRepository,
    required this.ref,
  }) : super(const AuthState()) {
    checkAuthStatus();
  }

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

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await authRepository.logout();
      state = const AuthState(status: AuthStatus.unauthenticated, user: null);
    } catch (_) {
      state = const AuthState(status: AuthStatus.unauthenticated, user: null);
    }
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: repo, ref: ref);
});
