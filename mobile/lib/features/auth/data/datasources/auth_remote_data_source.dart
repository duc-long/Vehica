import 'package:vehica_mobile/core/constants/api_endpoints.dart';
import 'package:vehica_mobile/core/network/api_client.dart';
import 'package:vehica_mobile/features/auth/data/models/user_model.dart';

// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// LAYER             : Data Layer (Remote Data Source)
// USE CASES         : UC-01 (Login), UC-02 (Register), UC-01b (Forgot & Reset Password), UC-03 (Profile)
// ==============================================================================

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource({required this.apiClient});

  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final response = await apiClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    return response['data'] as Map<String, dynamic>;
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.register,
      data: {
        'email': email,
        'password': password,
        'fullName': fullName,
        'phone': phone,
      },
    );
    return UserModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<UserModel> getProfile() async {
    final response = await apiClient.get(ApiEndpoints.profile);
    return UserModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<UserModel> updateProfile({
    required String fullName,
    required String phone,
    String? avatarUrl,
  }) async {
    final response = await apiClient.put(
      ApiEndpoints.profile,
      data: {
        'fullName': fullName,
        'phone': phone,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      },
    );
    return UserModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await apiClient.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
    return response['data'] as Map<String, dynamic>;
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await apiClient.post(
      ApiEndpoints.resetPassword,
      data: {
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      },
    );
  }
}

