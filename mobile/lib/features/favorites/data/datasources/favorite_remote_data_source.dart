import 'package:vehica_mobile/core/constants/api_endpoints.dart';
import 'package:vehica_mobile/core/network/api_client.dart';
import 'package:vehica_mobile/features/vehicles/data/models/vehicle_model.dart';

class FavoriteRemoteDataSource {
  final ApiClient apiClient;

  FavoriteRemoteDataSource({required this.apiClient});

  Future<List<VehicleModel>> getFavoriteVehicles({int page = 0, int size = 10}) async {
    final response = await apiClient.get(
      ApiEndpoints.favorites,
      queryParameters: {'page': page, 'size': size},
    );
    final data = response['data'] as Map<String, dynamic>;
    final list = data['content'] as List;
    return list.map((item) => VehicleModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Set<String>> getFavoriteVehicleIds() async {
    final response = await apiClient.get(ApiEndpoints.favoriteIds);
    final data = response['data'] as Map<String, dynamic>;
    final list = (data['vehicleIds'] as List?) ?? [];
    return list.map((id) => id.toString()).toSet();
  }

  Future<bool> isFavorite(String vehicleId) async {
    final response = await apiClient.get(ApiEndpoints.checkFavorite(vehicleId));
    final data = response['data'] as Map<String, dynamic>;
    return data['isFavorite'] == true;
  }

  Future<bool> toggleFavorite(String vehicleId) async {
    final response = await apiClient.post(ApiEndpoints.toggleFavorite(vehicleId));
    final data = response['data'] as Map<String, dynamic>;
    return data['isFavorite'] == true;
  }

  Future<void> addFavorite(String vehicleId) async {
    await apiClient.post(ApiEndpoints.favoriteVehicle(vehicleId));
  }

  Future<void> removeFavorite(String vehicleId) async {
    await apiClient.delete(ApiEndpoints.favoriteVehicle(vehicleId));
  }
}
