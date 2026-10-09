import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/widgets/vehica_back_button.dart';
import 'package:vehica_mobile/core/widgets/vehica_skeleton.dart';
import 'package:vehica_mobile/features/vehicles/presentation/controllers/vehicle_list_controller.dart';
import 'package:vehica_mobile/features/vehicles/presentation/widgets/admin_vehicle_card.dart';
import 'package:vehica_mobile/features/vehicles/presentation/widgets/admin_vehicle_delete_dialog.dart';
import 'package:vehica_mobile/features/vehicles/presentation/widgets/admin_vehicle_form_sheet.dart';
import 'package:vehica_mobile/features/vehicles/presentation/widgets/admin_vehicle_status_dialog.dart';

/// Admin Vehicle Management Screen (S07)
/// Architecture: Clean coordinator page for vehicle fleet inventory, status filtering, and CRUD delegation.
class AdminVehicleManagementPage extends ConsumerStatefulWidget {
  const AdminVehicleManagementPage({super.key});

  @override
  ConsumerState<AdminVehicleManagementPage> createState() =>
      _AdminVehicleManagementPageState();
}

class _AdminVehicleManagementPageState
    extends ConsumerState<AdminVehicleManagementPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _statusFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesState = ref.watch(adminVehiclesListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: const VehicaBackButton(),
        title: const Text('Quản lý danh mục xe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(adminVehiclesListProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Thêm xe mới',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        onPressed: () => AdminVehicleFormSheet.show(context, ref),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search box
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
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
                    hintText: 'Tìm theo tên xe, hãng, biển số...',
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

            // Status filter chips
            Container(
              height: 40,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                children: [
                  _filterChip(label: 'Tất cả', status: null),
                  _filterChip(label: 'Sẵn sàng', status: 'AVAILABLE'),
                  _filterChip(label: 'Đang thuê', status: 'RENTED'),
                  _filterChip(label: 'Bảo dưỡng', status: 'MAINTENANCE'),
                  _filterChip(label: 'Ngừng hoạt động', status: 'INACTIVE'),
                ],
              ),
            ),

            // Vehicle list
            Expanded(
              child: vehiclesState.when(
                data: (vehicles) {
                  final filtered = vehicles.where((v) {
                    final matchSearch = _searchQuery.isEmpty ||
                        v.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        v.brand.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        v.licensePlate.toLowerCase().contains(_searchQuery.toLowerCase());
                    final matchStatus = _statusFilter == null || v.status == _statusFilter;
                    return matchSearch && matchStatus;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'Không có xe nào khớp với tìm kiếm',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isTabletOrDesktop = constraints.maxWidth > 700;
                      if (isTabletOrDesktop) {
                        return GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2.05,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final vehicle = filtered[index];
                            return AdminVehicleCard(
                              vehicle: vehicle,
                              isDark: isDark,
                              onStatusTap: () => AdminVehicleStatusDialog.show(context, ref, vehicle),
                              onEditTap: () => AdminVehicleFormSheet.show(context, ref, vehicle),
                              onDeleteTap: () => AdminVehicleDeleteDialog.show(context, ref, vehicle),
                            );
                          },
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final vehicle = filtered[index];
                          return AdminVehicleCard(
                            vehicle: vehicle,
                            isDark: isDark,
                            onStatusTap: () => AdminVehicleStatusDialog.show(context, ref, vehicle),
                            onEditTap: () => AdminVehicleFormSheet.show(context, ref, vehicle),
                            onDeleteTap: () => AdminVehicleDeleteDialog.show(context, ref, vehicle),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: 6,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, __) => const VehicaSkeleton(height: 110),
                ),
                error: (e, _) => Center(child: Text('Lỗi tải danh sách xe: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip({required String label, required String? status}) {
    final isSelected = _statusFilter == status;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _statusFilter = status),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
