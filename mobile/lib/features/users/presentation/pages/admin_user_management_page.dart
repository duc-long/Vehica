import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/widgets/vehica_back_button.dart';
import 'package:vehica_mobile/core/widgets/vehica_skeleton.dart';
import 'package:vehica_mobile/features/users/presentation/controllers/user_admin_controller.dart';
import 'package:vehica_mobile/features/users/presentation/widgets/admin_user_card.dart';
import 'package:vehica_mobile/features/users/presentation/widgets/admin_user_delete_dialog.dart';
import 'package:vehica_mobile/features/users/presentation/widgets/admin_user_form_sheet.dart';
import 'package:vehica_mobile/features/users/presentation/widgets/admin_user_toggle_dialog.dart';

/// Admin User Management Screen (S09)
/// Architecture: Clean coordinator page for user account management, search filter, and CRUD delegation.
class AdminUserManagementPage extends ConsumerStatefulWidget {
  const AdminUserManagementPage({super.key});

  @override
  ConsumerState<AdminUserManagementPage> createState() =>
      _AdminUserManagementPageState();
}

class _AdminUserManagementPageState
    extends ConsumerState<AdminUserManagementPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(
      adminUsersListProvider(_searchQuery.isEmpty ? null : _searchQuery),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: const VehicaBackButton(),
        title: const Text('Quản lý người dùng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(adminUsersListProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text(
          'Thêm người dùng',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        onPressed: () => AdminUserFormSheet.show(context, ref),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tìm người dùng theo tên, email, sđt...',
                    hintStyle: const TextStyle(color: AppColors.textDisabled, fontSize: 13.5),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),

            // Users List
            Expanded(
              child: usersState.when(
                data: (users) {
                  if (users.isEmpty) {
                    return const Center(
                      child: Text(
                        'Không tìm thấy người dùng phù hợp',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 1100
                          ? 3
                          : constraints.maxWidth > 650
                              ? 2
                              : 1;

                      if (crossAxisCount > 1) {
                        return GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: crossAxisCount == 3 ? 3.8 : 3.4,
                          ),
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return AdminUserCard(
                              user: user,
                              isDark: isDark,
                              onEditTap: () => AdminUserFormSheet.show(context, ref, user),
                              onToggleStatusTap: () => AdminUserToggleDialog.show(context, ref, user),
                              onDeleteTap: () => AdminUserDeleteDialog.show(context, ref, user),
                            );
                          },
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                        physics: const BouncingScrollPhysics(),
                        itemCount: users.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return AdminUserCard(
                            user: user,
                            isDark: isDark,
                            onEditTap: () => AdminUserFormSheet.show(context, ref, user),
                            onToggleStatusTap: () => AdminUserToggleDialog.show(context, ref, user),
                            onDeleteTap: () => AdminUserDeleteDialog.show(context, ref, user),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: 6,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, __) => const VehicaSkeleton(height: 72),
                ),
                error: (e, _) => Center(
                  child: Text('Lỗi tải danh sách người dùng: $e'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
