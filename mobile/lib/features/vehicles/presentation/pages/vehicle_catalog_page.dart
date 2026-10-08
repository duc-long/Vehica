import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/widgets/vehica_back_button.dart';
import 'package:vehica_mobile/core/widgets/vehica_button.dart';
import 'package:vehica_mobile/core/widgets/vehica_empty_view.dart';
import 'package:vehica_mobile/core/widgets/vehica_skeleton.dart';
import 'package:vehica_mobile/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:vehica_mobile/features/vehicles/presentation/controllers/vehicle_list_controller.dart';
import 'package:vehica_mobile/features/vehicles/presentation/widgets/vehicle_card.dart';
import 'package:vehica_mobile/features/vehicles/presentation/widgets/vehicle_catalog_filter_bar.dart';
import 'package:vehica_mobile/features/vehicles/presentation/widgets/vehicle_catalog_grid_card.dart';
import 'package:vehica_mobile/features/vehicles/presentation/widgets/vehicle_catalog_search_bar.dart';
import 'package:vehica_mobile/features/vehicles/presentation/widgets/vehicle_catalog_toolbar.dart';

class VehicleCatalogPage extends ConsumerStatefulWidget {
  final String? initialTypeId;
  final String? initialBrand;
  final String? initialKeyword;
  final int? initialSeatCapacity;

  const VehicleCatalogPage({
    super.key,
    this.initialTypeId,
    this.initialBrand,
    this.initialKeyword,
    this.initialSeatCapacity,
  });

  @override
  ConsumerState<VehicleCatalogPage> createState() => _VehicleCatalogPageState();
}

class _VehicleCatalogPageState extends ConsumerState<VehicleCatalogPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isGridView = false;
  bool _showScrollToTop = false;
  VehicleSortOption _sortOption = VehicleSortOption.featured;
  String? _selectedBrand;

  @override
  void initState() {
    super.initState();
    if (widget.initialKeyword != null && widget.initialKeyword!.isNotEmpty) {
      _searchController.text = widget.initialKeyword!;
    }
    _selectedBrand = widget.initialBrand;
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(vehicleListControllerProvider.notifier);
      if (widget.initialTypeId != null) {
        controller.setTypeFilter(widget.initialTypeId);
      }
      if (widget.initialSeatCapacity != null) {
        controller.setSeatCapacityFilter(widget.initialSeatCapacity);
      }
      if (widget.initialKeyword != null && widget.initialKeyword!.isNotEmpty) {
        controller.search(widget.initialKeyword!);
      }
    });
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      if (_scrollController.offset > 450 && !_showScrollToTop) {
        setState(() => _showScrollToTop = true);
      } else if (_scrollController.offset <= 450 && _showScrollToTop) {
        setState(() => _showScrollToTop = false);
      }
    }
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 250) {
      ref.read(vehicleListControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<VehicleEntity> _sortVehicles(List<VehicleEntity> list) {
    final copy = List<VehicleEntity>.from(list);
    switch (_sortOption) {
      case VehicleSortOption.priceAsc:
        copy.sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
        break;
      case VehicleSortOption.priceDesc:
        copy.sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
        break;
      case VehicleSortOption.nameAsc:
        copy.sort((a, b) => a.name.compareTo(b.name));
        break;
      case VehicleSortOption.featured:
        break;
    }
    return copy;
  }

  List<VehicleEntity> _filterByBrand(List<VehicleEntity> list) {
    if (_selectedBrand == null || _selectedBrand == 'Tất cả' || _selectedBrand == 'Tất cả hãng') {
      return list;
    }
    return list
        .where((v) => v.brand.trim().toLowerCase() == _selectedBrand!.trim().toLowerCase())
        .toList();
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _selectedBrand = null;
      _sortOption = VehicleSortOption.featured;
    });
    ref.read(vehicleListControllerProvider.notifier).setTypeFilter(null);
    ref.read(vehicleListControllerProvider.notifier).setSeatCapacityFilter(null);
    ref.read(vehicleListControllerProvider.notifier).search('');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vehicleListState = ref.watch(vehicleListControllerProvider);
    final vehicleState = vehicleListState.vehicles;
    final selectedTypeId = vehicleListState.filter.typeId;
    final selectedSeatCapacity = vehicleListState.filter.seatCapacity;
    final typesState = ref.watch(vehicleTypesProvider);
    final brandsState = ref.watch(brandsProvider);

    // Extract real distinct seat capacities from loaded vehicles
    final loadedVehicles = vehicleState.value ?? [];
    final dynamicSeatCapacities = loadedVehicles
        .map((v) => v.seatCapacity)
        .toSet()
        .toList()
      ..sort();
    final availableSeats = dynamicSeatCapacities.isNotEmpty ? dynamicSeatCapacities : const [4, 5, 7];

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton.small(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              tooltip: 'Lên đầu trang',
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.easeOutCubic,
                );
              },
              child: const Icon(Icons.arrow_upward_rounded, size: 20),
            )
          : null,
      appBar: AppBar(
        leading: const VehicaBackButton(),
        title: Text(
          'Danh mục xe',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryLight,
          onRefresh: () async {
            await Future.wait([
              ref.read(vehicleListControllerProvider.notifier).loadVehicles(),
              Future(() => ref.invalidate(brandsProvider)),
              Future(() => ref.invalidate(vehicleTypesProvider)),
            ]);
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              // Search Bar
              SliverToBoxAdapter(
                child: VehicleCatalogSearchBar(
                  controller: _searchController,
                  onChanged: (val) {
                    ref.read(vehicleListControllerProvider.notifier).search(val.trim());
                  },
                  onClear: () {
                    _searchController.clear();
                    ref.read(vehicleListControllerProvider.notifier).search('');
                  },
                ),
              ),

              // Types & Dynamic Seats Filter Bar
              SliverToBoxAdapter(
                child: VehicleCatalogFilterBar(
                  typesState: typesState,
                  selectedTypeId: selectedTypeId,
                  availableSeatCapacities: availableSeats,
                  onTypeSelected: (typeId) {
                    ref.read(vehicleListControllerProvider.notifier).setTypeFilter(typeId);
                  },
                  selectedSeatCapacity: selectedSeatCapacity,
                  onSeatCapacitySelected: (seatCapacity) {
                    ref.read(vehicleListControllerProvider.notifier).setSeatCapacityFilter(seatCapacity);
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 10)),

              // Brand & Sort Toolbar
              SliverToBoxAdapter(
                child: VehicleCatalogToolbar(
                  brandsState: brandsState,
                  selectedBrand: _selectedBrand,
                  onBrandSelected: (brand) => setState(() => _selectedBrand = brand),
                  sortOption: _sortOption,
                  onSortChanged: (opt) => setState(() => _sortOption = opt),
                  isGridView: _isGridView,
                  onToggleView: () => setState(() => _isGridView = !_isGridView),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // Results Counter
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
                  child: vehicleState.when(
                    data: (vehicles) {
                      final filtered = _sortVehicles(_filterByBrand(vehicles));
                      final hasFilter = selectedTypeId != null ||
                          selectedSeatCapacity != null ||
                          _selectedBrand != null ||
                          _searchController.text.isNotEmpty;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Hiển thị ${filtered.length} xe khả dụng',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                            ),
                          ),
                          if (hasFilter)
                            GestureDetector(
                              onTap: _resetFilters,
                              child: const Text(
                                'Đặt lại lọc',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryLight,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),
              ),

              // Vehicles Content
              vehicleState.when(
                data: (vehicles) {
                  final filtered = _sortVehicles(_filterByBrand(vehicles));
                  if (filtered.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: VehicaEmptyView(
                        message: 'Không tìm thấy xe phù hợp với bộ lọc hiện tại',
                        icon: Icons.search_off_rounded,
                        action: VehicaButton(
                          text: 'Xóa bộ lọc',
                          width: 140,
                          height: 42,
                          borderRadius: 12,
                          onPressed: _resetFilters,
                        ),
                      ),
                    );
                  }

                  if (_isGridView) {
                    return SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.crossAxisExtent;
                        final crossAxisCount = width > 1200
                            ? 5
                            : width > 900
                                ? 4
                                : width > 600
                                    ? 3
                                    : 2;
                        final childAspectRatio = width > 900 ? 0.78 : (width > 380 ? 0.65 : 0.60);
                        return SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          sliver: SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: childAspectRatio,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final vehicle = filtered[index];
                                return VehicleCatalogGridCard(
                                  vehicle: vehicle,
                                  onTap: () => context.push('/vehicles/${vehicle.id}'),
                                );
                              },
                              childCount: filtered.length,
                            ),
                          ),
                        );
                      },
                    );
                  }

                  // Responsive List View
                  return SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.crossAxisExtent;
                      if (width > 650) {
                        final crossAxisCount = width > 1100 ? 3 : 2;
                        final childAspectRatio = width > 1100 ? 0.88 : 0.94;
                        return SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          sliver: SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: childAspectRatio,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final vehicle = filtered[index];
                                return VehicleCard(
                                  vehicle: vehicle,
                                  margin: EdgeInsets.zero,
                                  onTap: () => context.push('/vehicles/${vehicle.id}'),
                                );
                              },
                              childCount: filtered.length,
                            ),
                          ),
                        );
                      }

                      return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final vehicle = filtered[index];
                              return VehicleCard(
                                vehicle: vehicle,
                                onTap: () => context.push('/vehicles/${vehicle.id}'),
                              );
                            },
                            childCount: filtered.length,
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.crossAxisExtent;
                    if (_isGridView) {
                      final crossAxisCount = width > 1200
                          ? 5
                          : width > 900
                              ? 4
                              : width > 600
                                  ? 3
                                  : 2;
                      final childAspectRatio = width > 900 ? 0.76 : 0.68;
                      return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        sliver: SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: childAspectRatio,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (_, __) => const VehicleCardSkeleton(),
                            childCount: crossAxisCount * 2,
                          ),
                        ),
                      );
                    }

                    if (width > 650) {
                      final crossAxisCount = width > 1100 ? 3 : 2;
                      final childAspectRatio = width > 1100 ? 0.88 : 0.94;
                      return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        sliver: SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: childAspectRatio,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (_, __) => const VehicleCardSkeleton(),
                            childCount: crossAxisCount * 2,
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, __) => const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: VehicleCardSkeleton(),
                          ),
                          childCount: 4,
                        ),
                      ),
                    );
                  },
                ),
                error: (err, _) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                          const SizedBox(height: 12),
                          Text(
                            'Không thể tải dữ liệu xe. Vui lòng kiểm tra kết nối mạng và thử lại.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          VehicaButton(
                            text: 'Thử lại',
                            width: 140,
                            height: 42,
                            borderRadius: 12,
                            onPressed: () => ref.read(vehicleListControllerProvider.notifier).loadVehicles(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Loading More Indicator
              if (vehicleListState.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Đang tải thêm xe...',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (!vehicleListState.hasMore && (vehicleState.value?.isNotEmpty ?? false))
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 28),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 24, height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                          const SizedBox(width: 10),
                          Text(
                            'Đã hiển thị toàn bộ xe',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(width: 24, height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
