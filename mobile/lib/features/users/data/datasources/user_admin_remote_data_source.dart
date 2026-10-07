import 'package:vehica_mobile/core/constants/api_endpoints.dart';
import 'package:vehica_mobile/core/network/api_client.dart';
import 'package:vehica_mobile/features/auth/data/models/user_model.dart';

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
}
