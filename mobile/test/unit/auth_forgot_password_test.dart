import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vehica_mobile/app/providers.dart';
import 'package:vehica_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:vehica_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:vehica_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:vehica_mobile/features/auth/presentation/controllers/auth_state.dart';

class MockAuthRepository implements AuthRepository {
  String? lastForgotEmail;
  String? lastResetEmail;
  String? lastResetOtp;
  String? lastResetPassword;

  bool shouldThrowError = false;

  @override
  Future<UserEntity> login({required String email, required String password}) async {
    return const UserEntity(
      id: 'usr-1',
      email: 'test@vehica.com',
      fullName: 'Test User',
      phone: '0901234567',
      role: 'USER',
      status: 'ACTIVE',
    );
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    return const UserEntity(
      id: 'usr-1',
      email: 'test@vehica.com',
      fullName: 'Test User',
      phone: '0901234567',
      role: 'USER',
      status: 'ACTIVE',
    );
  }

  @override
  Future<UserEntity?> getCurrentUser() async => null;

  @override
  Future<UserEntity> updateProfile({
    required String fullName,
    required String phone,
    String? avatarUrl,
  }) async {
    return const UserEntity(
      id: 'usr-1',
      email: 'test@vehica.com',
      fullName: 'Test User',
      phone: '0901234567',
      role: 'USER',
      status: 'ACTIVE',
    );
  }

  @override
  Future<void> logout() async {}

  @override
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    if (shouldThrowError) {
      throw Exception('Email không tồn tại trong hệ thống');
    }
    lastForgotEmail = email;
    return {'message': 'OTP sent', 'otp': '654321'};
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    if (shouldThrowError) {
      throw Exception('Mã OTP không hợp lệ');
    }
    lastResetEmail = email;
    lastResetOtp = otp;
    lastResetPassword = newPassword;
  }
}

void main() {
  group('AuthController Forgot & Reset Password Flow Tests', () {
    late MockAuthRepository mockAuthRepository;
    late ProviderContainer container;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('forgotPassword sends email and returns OTP', () async {
      final controller = container.read(authControllerProvider.notifier);

      final otp = await controller.forgotPassword('customer@vehica.com');

      expect(otp, equals('654321'));
      expect(mockAuthRepository.lastForgotEmail, equals('customer@vehica.com'));
      expect(container.read(authControllerProvider).status, equals(AuthStatus.unauthenticated));
    });

    test('forgotPassword handles error properly', () async {
      mockAuthRepository.shouldThrowError = true;
      final controller = container.read(authControllerProvider.notifier);

      final otp = await controller.forgotPassword('nonexistent@vehica.com');

      expect(otp, isNull);
      expect(container.read(authControllerProvider).status, equals(AuthStatus.error));
      expect(container.read(authControllerProvider).errorMessage, contains('Email không tồn tại'));
    });

    test('resetPassword sends new password and updates state to unauthenticated', () async {
      final controller = container.read(authControllerProvider.notifier);

      final success = await controller.resetPassword(
        email: 'customer@vehica.com',
        otp: '654321',
        newPassword: 'NewPassword123',
      );

      expect(success, isTrue);
      expect(mockAuthRepository.lastResetEmail, equals('customer@vehica.com'));
      expect(mockAuthRepository.lastResetOtp, equals('654321'));
      expect(mockAuthRepository.lastResetPassword, equals('NewPassword123'));
      expect(container.read(authControllerProvider).status, equals(AuthStatus.unauthenticated));
    });
  });
}
