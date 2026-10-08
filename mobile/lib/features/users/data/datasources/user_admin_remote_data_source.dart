// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// LAYER             : Data Layer (Remote Data Source)
// USE CASES         : UC-08 (Admin User CRUD), UC-08b (Toggle Active/Blocked & Delete)
// ENDPOINTS         : /api/admin/users
// ==============================================================================

import 'package:vehica_mobile/core/constants/api_endpoints.dart';
import 'package:vehica_mobile/core/network/api_client.dart';
import 'package:vehica_mobile/features/auth/data/models/user_model.dart';

/// Performs raw HTTP calls for admin user management. Contains no business logic.
class UserAdminRemoteDataSource {
  final ApiClient apiClient;

  UserAdminRemoteDataSource({required this.apiClient});

  Future<List<UserModel>> searchUsers({
    String? search,
    String? status,
    int page = 0,
    int size = 10,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'size': size,
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null && status.isNotEmpty) 'status': status,
    };
    final response = await apiClient.get(ApiEndpoints.adminUsers, queryParameters: query);
    final data = response['data'] as Map<String, dynamic>;
    final list = data['content'] as List;
    return list.map((item) => UserModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<UserModel> createUser(Map<String, dynamic> data) async {
    final response = await apiClient.post(ApiEndpoints.adminUsers, data: data);
    return UserModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<UserModel> updateUser(String id, Map<String, dynamic> data) async {
    final response = await apiClient.put(ApiEndpoints.adminUserDetail(id), data: data);
    return UserModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<UserModel> updateUserStatus(String id, String status) async {
    final response = await apiClient.patch(
      ApiEndpoints.adminUserStatus(id),
      data: {'status': status},
    );
    return UserModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> deleteUser(String id) async {
    await apiClient.delete(ApiEndpoints.adminDeleteUser(id));
  }
}
