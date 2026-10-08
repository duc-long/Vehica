import 'package:vehica_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:vehica_mobile/features/users/data/datasources/user_admin_remote_data_source.dart';
import 'package:vehica_mobile/features/users/domain/repositories/user_admin_repository.dart';

// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// LAYER             : Data Layer (Repository Implementation)
// USE CASES         : UC-08 (Admin User CRUD), UC-08b (Toggle Active/Blocked & Delete)
// ==============================================================================

class UserAdminRepositoryImpl implements UserAdminRepository {
  final UserAdminRemoteDataSource remoteDataSource;

  UserAdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<UserEntity>> searchUsers({
    String? search,
    String? status,
    int page = 0,
    int size = 10,
  }) {
    return remoteDataSource.searchUsers(search: search, status: status, page: page, size: size);
  }

  @override
  Future<UserEntity> createUser(Map<String, dynamic> data) => remoteDataSource.createUser(data);

  @override
  Future<UserEntity> updateUser(String id, Map<String, dynamic> data) =>
      remoteDataSource.updateUser(id, data);

  @override
  Future<UserEntity> updateUserStatus(String id, String status) =>
      remoteDataSource.updateUserStatus(id, status);

  @override
  Future<void> deleteUser(String id) => remoteDataSource.deleteUser(id);
}
