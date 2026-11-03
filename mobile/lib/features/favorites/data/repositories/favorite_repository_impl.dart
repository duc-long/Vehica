import 'package:vehica_mobile/features/favorites/data/datasources/favorite_remote_data_source.dart';
import 'package:vehica_mobile/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:vehica_mobile/features/vehicles/domain/entities/vehicle_entity.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteRemoteDataSource remoteDataSource;

  FavoriteRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<VehicleEntity>> getFavoriteVehicles({int page = 0, int size = 10}) {
    return remoteDataSource.getFavoriteVehicles(page: page, size: size);
  }

  @override
  Future<Set<String>> getFavoriteVehicleIds() {
    return remoteDataSource.getFavoriteVehicleIds();
  }

  @override
  Future<bool> isFavorite(String vehicleId) {
    return remoteDataSource.isFavorite(vehicleId);
  }

  @override
  Future<bool> toggleFavorite(String vehicleId) {
    return remoteDataSource.toggleFavorite(vehicleId);
  }

  @override
  Future<void> addFavorite(String vehicleId) {
    return remoteDataSource.addFavorite(vehicleId);
  }

  @override
  Future<void> removeFavorite(String vehicleId) {
    return remoteDataSource.removeFavorite(vehicleId);
  }
}
