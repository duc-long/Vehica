import 'package:vehica_mobile/core/constants/api_endpoints.dart';
import 'package:vehica_mobile/core/network/api_client.dart';
import 'package:vehica_mobile/features/auth/data/models/user_model.dart';

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
}
