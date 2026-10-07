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

  void _invalidateAll() {
    ref.invalidate(adminUsersListProvider);
  }
}

final userAdminControllerProvider = Provider<UserAdminController>((ref) {
  final repo = ref.watch(userAdminRepositoryProvider);
  return UserAdminController(repository: repo, ref: ref);
});
