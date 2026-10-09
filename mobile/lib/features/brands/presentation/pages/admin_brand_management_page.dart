import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/widgets/vehica_back_button.dart';
import 'package:vehica_mobile/core/widgets/vehica_skeleton.dart';
import 'package:vehica_mobile/features/brands/presentation/controllers/brand_admin_controller.dart';
import 'package:vehica_mobile/features/brands/presentation/widgets/brand_card.dart';
import 'package:vehica_mobile/features/brands/presentation/widgets/brand_delete_dialog.dart';
import 'package:vehica_mobile/features/brands/presentation/widgets/brand_form_sheet.dart';

/// Admin Brand Management Page (S13)
/// Responsibilities: UI orchestration, search filter, and responsive layout delegation.
class AdminBrandManagementPage extends ConsumerStatefulWidget {
  const AdminBrandManagementPage({super.key});

  @override
  ConsumerState<AdminBrandManagementPage> createState() =>
      _AdminBrandManagementPageState();
}

class _AdminBrandManagementPageState
    extends ConsumerState<AdminBrandManagementPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brandsState = ref.watch(adminBrandsListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: const VehicaBackButton(),
        title: const Text('Quản lý Hãng xe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(adminBrandsListProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Thêm hãng',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        onPressed: () => BrandFormSheet.show(context, ref),
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
                    hintText: 'Tìm hãng xe theo tên, quốc gia...',
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

            // Brands List
            Expanded(
              child: brandsState.when(
                data: (brands) {
                  final filtered = _searchQuery.isEmpty
                      ? brands
                      : brands.where((b) {
                          final q = _searchQuery.toLowerCase();
                          final nameMatch = b.name.toLowerCase().contains(q);
                          final countryMatch = (b.country ?? '').toLowerCase().contains(q);
                          return nameMatch || countryMatch;
                        }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'Không tìm thấy hãng xe phù hợp',
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
                            childAspectRatio: crossAxisCount == 3 ? 4.2 : 3.8,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final brand = filtered[index];
                            return BrandCard(
                              brand: brand,
                              isDark: isDark,
                              onEdit: () => BrandFormSheet.show(context, ref, brand),
                              onDelete: () => BrandDeleteDialog.show(context, ref, brand),
                            );
                          },
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final brand = filtered[index];
                          return BrandCard(
                            brand: brand,
                            isDark: isDark,
                            onEdit: () => BrandFormSheet.show(context, ref, brand),
                            onDelete: () => BrandDeleteDialog.show(context, ref, brand),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 1100
                        ? 3
                        : constraints.maxWidth > 650
                            ? 2
                            : 1;
                    if (crossAxisCount > 1) {
                      return GridView.builder(
                        padding: const EdgeInsets.all(16.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: crossAxisCount == 3 ? 4.2 : 3.8,
                        ),
                        itemCount: crossAxisCount * 3,
                        itemBuilder: (_, __) => const VehicaSkeleton(height: 72),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: 6,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, __) => const VehicaSkeleton(height: 72),
                    );
                  },
                ),
                error: (e, _) => Center(
                  child: Text('Lỗi tải hãng xe: $e'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
