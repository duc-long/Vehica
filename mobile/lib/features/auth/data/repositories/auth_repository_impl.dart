import 'dart:convert';
import 'package:vehica_mobile/core/storage/secure_storage_service.dart';
import 'package:vehica_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:vehica_mobile/features/auth/data/models/user_model.dart';
import 'package:vehica_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:vehica_mobile/features/auth/domain/repositories/auth_repository.dart';

// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// LAYER             : Data Layer (Repository Implementation)
// USE CASES         : UC-01 (Login), UC-02 (Register), UC-01b (Forgot/Reset Password), UC-03 (Profile)
// ==============================================================================

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageService storageService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.storageService,
  });

  @override
  Future<UserEntity> login({required String email, required String password}) async {
    final data = await remoteDataSource.login(email: email, password: password);
    final token = data['accessToken'] as String;
    final userJson = data['user'] as Map<String, dynamic>;
    final user = UserModel.fromJson(userJson);

    await storageService.saveToken(token);
    await storageService.saveUserData(jsonEncode(user.toJson()));

    return user;
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    return await remoteDataSource.register(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
    );
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final token = await storageService.getToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final user = await remoteDataSource.getProfile();
      await storageService.saveUserData(jsonEncode(user.toJson()));
      return user;
    } catch (_) {
      final cachedJson = await storageService.getUserData();
      if (cachedJson != null && cachedJson.isNotEmpty) {
        return UserModel.fromJson(jsonDecode(cachedJson) as Map<String, dynamic>);
      }
      return null;
    }
  }

  @override
  Future<UserEntity> updateProfile({
    required String fullName,
    required String phone,
    String? avatarUrl,
  }) async {
    final updated = await remoteDataSource.updateProfile(
      fullName: fullName,
      phone: phone,
      avatarUrl: avatarUrl,
    );
    await storageService.saveUserData(jsonEncode(updated.toJson()));
    return updated;
  }

  @override
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    return await remoteDataSource.forgotPassword(email);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await remoteDataSource.resetPassword(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> logout() async {
    await storageService.clearAll();
  }
}

