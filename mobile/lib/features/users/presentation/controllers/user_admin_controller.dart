// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// LAYER             : Presentation Layer (Controller & Family FutureProvider)
// USE CASES         : UC-10 - Admin User Management (User Management & Lock)
// BUSINESS RULES    : BR-01, BR-03 (Account SUSPENDED/BLOCKED), BR-20 (Cannot lock oneself)
// ------------------------------------------------------------------------------
// DATA FLOW:
// UI (AdminUserManagementPage S09)
//   --> UserAdminController
//   --> UserAdminRepository (Domain Interface)
//   --> UserAdminRepositoryImpl (Data Layer)
//   --> UserAdminRemoteDataSource (Dio HTTP Client)
//   --> Spring Boot REST API (/api/admin/users)
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/app/providers.dart';
import 'package:vehica_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:vehica_mobile/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:vehica_mobile/features/users/domain/repositories/user_admin_repository.dart';

/// Provider for user list in admin page with Realtime search feature (S09)
final adminUsersListProvider = FutureProvider.family<List<UserEntity>, String?>((ref, search) async {
  final repo = ref.watch(userAdminRepositoryProvider);
  return repo.searchUsers(search: search);
});

/// Controller handling admin user account tasks (S09)
class UserAdminController {
  final UserAdminRepository repository;
  final Ref ref;

  UserAdminController({
    required this.repository,
    required this.ref,
  });

  /// Lock or Unlock user account (UC-10, BR-03, BR-20)
  /// Flow: PATCH /api/admin/users/:id/status -> Invalidate admin users list & dashboard KPI metrics
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

  /// Create new user account (S09 Admin CRUD)
  Future<bool> createUser(Map<String, dynamic> data) async {
    try {
      await repository.createUser(data);
      _invalidateAll();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Update user information (S09 Admin CRUD)
  Future<bool> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await repository.updateUser(userId, data);
      _invalidateAll();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Delete user (Soft delete = Lock if booked, Hard delete if not booked)
  Future<bool> deleteUser(String userId) async {
    try {
      await repository.deleteUser(userId);
      _invalidateAll();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _invalidateAll() {
    ref.invalidate(adminUsersListProvider);
    ref.invalidate(adminDashboardSummaryProvider);
  }
}

final userAdminControllerProvider = Provider<UserAdminController>((ref) {
  final repo = ref.watch(userAdminRepositoryProvider);
  return UserAdminController(repository: repo, ref: ref);
});
