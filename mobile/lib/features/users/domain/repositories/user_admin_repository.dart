import 'package:vehica_mobile/features/auth/domain/entities/user_entity.dart';

abstract class UserAdminRepository {
  Future<List<UserEntity>> searchUsers({
    String? search,
    String? status,
    int page = 0,
    int size = 10,
  });

  Future<UserEntity> createUser(Map<String, dynamic> data);
  Future<UserEntity> updateUser(String id, Map<String, dynamic> data);
  Future<UserEntity> updateUserStatus(String id, String status);
  Future<void> deleteUser(String id);
}
