// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// LAYER             : Presentation Layer (StateNotifier Provider)
// USE CASES         : UC-04 (Search / Filter Vehicles), UC-09 (Admin updates vehicle status)
// BUSINESS RULES    : BR-04 (Status AVAILABLE), BR-05 (License Plate), BR-19 (Active vehicle lock)
// ------------------------------------------------------------------------------
// DATA FLOW:
// UI (HomePage S03 / AdminVehicleManagementPage S07)
//   --> VehicleListController / AdminVehicleController
//   --> VehicleRepository (Domain Interface)
//   --> VehicleRepositoryImpl (Data Layer)
//   --> VehicleRemoteDataSource (Dio HTTP Client)
//   --> Spring Boot REST API (/api/vehicles & /api/admin/vehicles)
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/app/providers.dart';
import 'package:vehica_mobile/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:vehica_mobile/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:vehica_mobile/features/vehicles/domain/repositories/vehicle_repository.dart';
import 'package:vehica_mobile/features/vehicles/presentation/controllers/vehicle_detail_controller.dart';

/// Vehicle search filter (Search & Filter Query Parameters)
class VehicleFilterState {
  final String? keyword;
  final String? typeId;
  final int? seatCapacity;
  final double? minPrice;
  final double? maxPrice;

  const VehicleFilterState({
    this.keyword,
    this.typeId,
    this.seatCapacity,
    this.minPrice,
    this.maxPrice,
  });

  VehicleFilterState copyWith({
    String? keyword,
    String? typeId,
    int? seatCapacity,
    double? minPrice,
    double? maxPrice,
    bool clearTypeId = false,
    bool clearSeatCapacity = false,
  }) {
    return VehicleFilterState(
      keyword: keyword ?? this.keyword,
      typeId: clearTypeId ? null : (typeId ?? this.typeId),
      seatCapacity: clearSeatCapacity ? null : (seatCapacity ?? this.seatCapacity),
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }
}

class VehicleListState {
  final AsyncValue<List<VehicleEntity>> vehicles;
  final VehicleFilterState filter;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  const VehicleListState({
    required this.vehicles,
    this.filter = const VehicleFilterState(),
    this.page = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  VehicleListState copyWith({
    AsyncValue<List<VehicleEntity>>? vehicles,
    VehicleFilterState? filter,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return VehicleListState(
      vehicles: vehicles ?? this.vehicles,
      filter: filter ?? this.filter,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// StateNotifier managing available vehicle list for customers (S03)
class VehicleListController extends StateNotifier<VehicleListState> {
  final VehicleRepository repository;
  static const int pageSize = 10;

  VehicleListController({required this.repository})
      : super(const VehicleListState(vehicles: AsyncValue.loading())) {
    loadVehicles();
  }

  /// Load available vehicle list based on current filters (UC-04, BR-04)
  /// Flow: GET /api/vehicles?status=AVAILABLE&keyword=...&typeId=...&seatCapacity=... -> Update state
  Future<void> loadVehicles() async {
    state = state.copyWith(
      vehicles: const AsyncValue.loading(),
      page: 0,
      hasMore: true,
      isLoadingMore: false,
    );
    try {
      final list = await repository.getVehicles(
        keyword: state.filter.keyword,
        typeId: state.filter.typeId,
        seatCapacity: state.filter.seatCapacity,
        minPrice: state.filter.minPrice,
        maxPrice: state.filter.maxPrice,
        status: 'AVAILABLE',
        page: 0,
        size: pageSize,
      );
      if (!mounted) return;
      state = state.copyWith(
        vehicles: AsyncValue.data(list),
        page: 0,
        hasMore: list.length >= pageSize,
        isLoadingMore: false,
      );
    } catch (e, st) {
      if (!mounted) return;
      state = state.copyWith(
        vehicles: AsyncValue.error(
          e.toString().replaceAll('Exception: ', '').replaceAll('ServerException: ', ''),
          st,
        ),
      );
    }
  }

  /// Load more vehicles when scrolling to bottom (Infinite Scroll)
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    final currentList = state.vehicles.value;
    if (currentList == null) return;

    final nextPage = state.page + 1;
    state = state.copyWith(isLoadingMore: true);

    try {
      final moreVehicles = await repository.getVehicles(
        keyword: state.filter.keyword,
        typeId: state.filter.typeId,
        seatCapacity: state.filter.seatCapacity,
        minPrice: state.filter.minPrice,
        maxPrice: state.filter.maxPrice,
        status: 'AVAILABLE',
        page: nextPage,
        size: pageSize,
      );
      if (!mounted) return;
      final updatedList = [...currentList, ...moreVehicles];
      state = state.copyWith(
        vehicles: AsyncValue.data(updatedList),
        page: nextPage,
        hasMore: moreVehicles.length >= pageSize,
        isLoadingMore: false,
      );
    } catch (_) {
      if (!mounted) return;
      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// Update filters and automatically re-fetch latest data
  void updateFilter(VehicleFilterState newFilter) {
    state = state.copyWith(filter: newFilter);
    loadVehicles();
  }

  /// Search vehicles by keyword (Vehicle name, Manufacturer)
  void search(String keyword) {
    state = state.copyWith(
      filter: state.filter.copyWith(keyword: keyword.isEmpty ? null : keyword),
    );
    loadVehicles();
  }

  /// Filter by vehicle type (Sedan, SUV, Hatchback, ...)
  void setTypeFilter(String? typeId) {
    state = state.copyWith(
      filter: state.filter.copyWith(
        typeId: typeId,
        clearTypeId: typeId == null,
      ),
    );
    loadVehicles();
  }

  /// Filter by seating capacity (4 seats, 5 seats, 7 seats, ...)
  void setSeatCapacityFilter(int? seatCapacity) {
    state = state.copyWith(
      filter: state.filter.copyWith(
        seatCapacity: seatCapacity,
        clearSeatCapacity: seatCapacity == null,
      ),
    );
    loadVehicles();
  }
}

final vehicleListControllerProvider =
    StateNotifierProvider<VehicleListController, VehicleListState>((ref) {
  final repo = ref.watch(vehicleRepositoryProvider);
  return VehicleListController(repository: repo);
});

final vehicleTypesProvider = FutureProvider<List<VehicleTypeEntity>>((ref) async {
  final repo = ref.watch(vehicleRepositoryProvider);
  return repo.getVehicleTypes();
});

final brandsProvider = FutureProvider<List<BrandEntity>>((ref) async {
  final repo = ref.watch(vehicleRepositoryProvider);
  return repo.getBrands();
});

final popularBrandsProvider = FutureProvider<List<BrandEntity>>((ref) async {
  final repo = ref.watch(vehicleRepositoryProvider);
  return repo.getPopularBrands();
});

/// Provider for entire fleet list for Admin (S07, S08)
final adminVehiclesListProvider = FutureProvider<List<VehicleEntity>>((ref) async {
  final repo = ref.watch(vehicleRepositoryProvider);
  return repo.getVehicles(size: 50);
});

/// Controller handling admin vehicle management tasks (S07, S08)
/// Feature: Change vehicle status (AVAILABLE / MAINTENANCE), Realtime sync
class AdminVehicleController {
  final VehicleRepository repository;
  final Ref ref;

  AdminVehicleController({
    required this.repository,
    required this.ref,
  });

  /// Update vehicle status (UC-09, BR-04, BR-19)
  /// Flow: PATCH /api/admin/vehicles/:id/status -> Invalidate all related providers for immediate UI update
  Future<bool> updateStatus(String vehicleId, String newStatus) async {
    try {
      await repository.updateVehicleStatus(vehicleId, newStatus);
      _invalidateAll(vehicleId);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Create new vehicle (S07 Admin CRUD)
  Future<bool> createVehicle(Map<String, dynamic> data) async {
    try {
      await repository.createVehicle(data);
      _invalidateAll(null);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Edit vehicle information (S07 Admin CRUD)
  Future<bool> updateVehicle(String vehicleId, Map<String, dynamic> data) async {
    try {
      await repository.updateVehicle(vehicleId, data);
      _invalidateAll(vehicleId);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Delete vehicle (Soft delete if booked, hard delete if not booked)
  Future<bool> deleteVehicle(String vehicleId) async {
    try {
      await repository.deleteVehicle(vehicleId);
      _invalidateAll(vehicleId);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Add vehicle image
  Future<bool> addVehicleImage(String vehicleId, String imageUrl, bool isPrimary) async {
    try {
      await repository.addVehicleImage(vehicleId, imageUrl, isPrimary);
      _invalidateAll(vehicleId);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Delete vehicle image
  Future<bool> deleteVehicleImage(String vehicleId, String imageId) async {
    try {
      await repository.deleteVehicleImage(vehicleId, imageId);
      _invalidateAll(vehicleId);
      return true;
    } catch (_) {
      return false;
    }
  }

  void _invalidateAll(String? vehicleId) {
    ref.invalidate(adminVehiclesListProvider);
    ref.invalidate(vehicleListControllerProvider);
    ref.invalidate(adminDashboardSummaryProvider);
    if (vehicleId != null) {
      ref.invalidate(vehicleDetailControllerProvider(vehicleId));
    }
  }
}

final adminVehicleControllerProvider = Provider<AdminVehicleController>((ref) {
  final repo = ref.watch(vehicleRepositoryProvider);
  return AdminVehicleController(repository: repo, ref: ref);
});
