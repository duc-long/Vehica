import 'package:vehica_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:vehica_mobile/features/users/data/datasources/user_admin_remote_data_source.dart';
import 'package:vehica_mobile/features/users/domain/repositories/user_admin_repository.dart';

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
}
