import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/app/providers.dart';
import 'package:vehica_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:vehica_mobile/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:vehica_mobile/features/vehicles/domain/entities/vehicle_entity.dart';

class FavoriteState {
  final Set<String> favoriteIds;
  final List<VehicleEntity> favoriteVehicles;
  final bool isLoading;
  final bool isVehiclesLoading;
  final String? error;

  const FavoriteState({
    this.favoriteIds = const {},
    this.favoriteVehicles = const [],
    this.isLoading = false,
    this.isVehiclesLoading = false,
    this.error,
  });

  FavoriteState copyWith({
    Set<String>? favoriteIds,
    List<VehicleEntity>? favoriteVehicles,
    bool? isLoading,
    bool? isVehiclesLoading,
    String? error,
  }) {
    return FavoriteState(
      favoriteIds: favoriteIds ?? this.favoriteIds,
      favoriteVehicles: favoriteVehicles ?? this.favoriteVehicles,
      isLoading: isLoading ?? this.isLoading,
      isVehiclesLoading: isVehiclesLoading ?? this.isVehiclesLoading,
      error: error,
    );
  }

  bool isFavorite(String vehicleId) => favoriteIds.contains(vehicleId);
}

class FavoriteController extends StateNotifier<FavoriteState> {
  final FavoriteRepository _repository;
  final Ref _ref;

  FavoriteController(this._repository, this._ref) : super(const FavoriteState()) {
    // Tự động tải favoriteIds nếu người dùng đã đăng nhập
    _initIfAuthenticated();
  }

  void _initIfAuthenticated() {
    final authState = _ref.read(authControllerProvider);
    if (authState.isAuthenticated) {
      loadFavoriteIds();
    }
  }

  Future<void> loadFavoriteIds() async {
    try {
      final ids = await _repository.getFavoriteVehicleIds();
      state = state.copyWith(favoriteIds: ids);
    } catch (_) {
      // Bỏ qua lỗi im lặng khi tải IDs nền
    }
  }

  Future<void> loadFavoriteVehicles({bool refresh = false}) async {
    if (state.isVehiclesLoading && !refresh) return;

    state = state.copyWith(isVehiclesLoading: true, error: null);
    try {
      final vehicles = await _repository.getFavoriteVehicles(page: 0, size: 50);
      final ids = vehicles.map((v) => v.id).toSet();
      state = state.copyWith(
        favoriteVehicles: vehicles,
        favoriteIds: {...state.favoriteIds, ...ids},
        isVehiclesLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isVehiclesLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> toggleFavorite(VehicleEntity vehicle) async {
    final isFav = state.isFavorite(vehicle.id);
    final previousIds = Set<String>.from(state.favoriteIds);
    final previousVehicles = List<VehicleEntity>.from(state.favoriteVehicles);

    // 1. Optimistic Update
    final updatedIds = Set<String>.from(state.favoriteIds);
    final updatedVehicles = List<VehicleEntity>.from(state.favoriteVehicles);

    if (isFav) {
      updatedIds.remove(vehicle.id);
      updatedVehicles.removeWhere((v) => v.id == vehicle.id);
    } else {
      updatedIds.add(vehicle.id);
      if (!updatedVehicles.any((v) => v.id == vehicle.id)) {
        updatedVehicles.insert(0, vehicle);
      }
    }

    state = state.copyWith(
      favoriteIds: updatedIds,
      favoriteVehicles: updatedVehicles,
    );

    // 2. Call API
    try {
      final result = await _repository.toggleFavorite(vehicle.id);
      if (result != !isFav) {
        // Đồng bộ lại nếu backend trả về trạng thái khác
        if (result) {
          state.favoriteIds.add(vehicle.id);
        } else {
          state.favoriteIds.remove(vehicle.id);
        }
      }
      return result;
    } catch (e) {
      // Rollback nếu có lỗi mạng
      state = state.copyWith(
        favoriteIds: previousIds,
        favoriteVehicles: previousVehicles,
      );
      rethrow;
    }
  }

  Future<void> removeFavorite(String vehicleId) async {
    final previousIds = Set<String>.from(state.favoriteIds);
    final previousVehicles = List<VehicleEntity>.from(state.favoriteVehicles);

    // Optimistic remove
    final updatedIds = Set<String>.from(state.favoriteIds)..remove(vehicleId);
    final updatedVehicles = state.favoriteVehicles.where((v) => v.id != vehicleId).toList();

    state = state.copyWith(
      favoriteIds: updatedIds,
      favoriteVehicles: updatedVehicles,
    );

    try {
      await _repository.removeFavorite(vehicleId);
    } catch (e) {
      // Rollback
      state = state.copyWith(
        favoriteIds: previousIds,
        favoriteVehicles: previousVehicles,
      );
      rethrow;
    }
  }
}

final favoriteControllerProvider = StateNotifierProvider<FavoriteController, FavoriteState>((ref) {
  final repository = ref.watch(favoriteRepositoryProvider);
  return FavoriteController(repository, ref);
});
