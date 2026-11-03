import 'package:vehica_mobile/features/vehicles/domain/entities/vehicle_entity.dart';

abstract class FavoriteRepository {
  Future<List<VehicleEntity>> getFavoriteVehicles({int page = 0, int size = 10});
  Future<Set<String>> getFavoriteVehicleIds();
  Future<bool> isFavorite(String vehicleId);
  Future<bool> toggleFavorite(String vehicleId);
  Future<void> addFavorite(String vehicleId);
  Future<void> removeFavorite(String vehicleId);
}
