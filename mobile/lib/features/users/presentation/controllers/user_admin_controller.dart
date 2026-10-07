import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/app/providers.dart';
import 'package:vehica_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:vehica_mobile/features/users/domain/repositories/user_admin_repository.dart';

final adminUsersListProvider = FutureProvider.family<List<UserEntity>, String?>((ref, search) async {
  final repo = ref.watch(userAdminRepositoryProvider);
  return repo.searchUsers(search: search);
});

class UserAdminController {
  final UserAdminRepository repository;
  final Ref ref;

  UserAdminController({
    required this.repository,
    required this.ref,
  });

  Future<bool> toggleUserStatus(UserEntity user) async {
    final nextStatus = user.status == 'ACTIVE' ? 'BLOCKED' : 'ACTIVE';
    try {
      await repository.updateUserStatus(user.id, nextStatus);
      _invalidateAll();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> createUser(Map<String, dynamic> data) async {
    try {
      await repository.createUser(data);
      _invalidateAll();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await repository.updateUser(userId, data);
      _invalidateAll();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _invalidateAll() {
    ref.invalidate(adminUsersListProvider);
  }
}

final userAdminControllerProvider = Provider<UserAdminController>((ref) {
  final repo = ref.watch(userAdminRepositoryProvider);
  return UserAdminController(repository: repo, ref: ref);
});
