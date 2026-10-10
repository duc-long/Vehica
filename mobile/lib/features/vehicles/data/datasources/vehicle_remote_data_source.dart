import 'package:vehica_mobile/core/constants/api_endpoints.dart';
import 'package:vehica_mobile/core/network/api_client.dart';
import 'package:vehica_mobile/core/utils/formatters.dart';
import 'package:vehica_mobile/features/vehicles/data/models/vehicle_model.dart';

// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// LAYER             : Data Layer (Remote Data Source)
// USE CASES         : UC-04 (Browse Vehicles), UC-05 (Vehicle Detail & Availability), UC-13 (Brands)
// ==============================================================================

class VehicleRemoteDataSource {
  final ApiClient apiClient;

  VehicleRemoteDataSource({required this.apiClient});

  Future<List<VehicleModel>> getVehicles({
    String? keyword,
    String? typeId,
    int? seatCapacity,
    double? minPrice,
    double? maxPrice,
    String? status,
    int page = 0,
    int size = 10,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'size': size,
      if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      if (typeId != null && typeId.isNotEmpty) 'typeId': typeId,
      if (seatCapacity != null) 'seatCapacity': seatCapacity,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (status != null && status.isNotEmpty) 'status': status,
    };

    final response = await apiClient.get(ApiEndpoints.vehicles, queryParameters: query);
    final data = response['data'] as Map<String, dynamic>;
    final list = data['content'] as List;
    return list.map((item) => VehicleModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<VehicleModel> getVehicleDetail(String id) async {
    final response = await apiClient.get(ApiEndpoints.vehicleDetail(id));
    return VehicleModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<AvailabilityModel> checkAvailability({
    required String vehicleId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final query = {
      'startDate': VehicaFormatters.formatApiDate(startDate),
      'endDate': VehicaFormatters.formatApiDate(endDate),
    };

    final response = await apiClient.get(
      ApiEndpoints.vehicleAvailability(vehicleId),
      queryParameters: query,
    );
    return AvailabilityModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<List<VehicleTypeModel>> getVehicleTypes() async {
    final response = await apiClient.get(ApiEndpoints.vehicleTypes);
    final list = response['data'] as List;
    return list.map((item) => VehicleTypeModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<BrandModel>> getBrands() async {
    final response = await apiClient.get(ApiEndpoints.brands);
    final list = response['data'] as List;
    return list.map((item) => BrandModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<BrandModel>> getPopularBrands() async {
    final response = await apiClient.get(ApiEndpoints.popularBrands);
    final list = response['data'] as List;
    return list.map((item) => BrandModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  // Admin APIs
  Future<VehicleModel> createVehicle(Map<String, dynamic> data) async {
    final response = await apiClient.post(ApiEndpoints.adminVehicles, data: data);
    return VehicleModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<VehicleModel> updateVehicle(String id, Map<String, dynamic> data) async {
    final response = await apiClient.put(ApiEndpoints.adminVehicleDetail(id), data: data);
    return VehicleModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<VehicleModel> updateVehicleStatus(String id, String status) async {
    final response = await apiClient.patch(
      ApiEndpoints.adminVehicleStatus(id),
      data: {'status': status},
    );
    return VehicleModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> deleteVehicle(String id) async {
    await apiClient.delete(ApiEndpoints.adminVehicleDetail(id));
  }

  Future<void> addVehicleImage(String vehicleId, String imageUrl, bool isPrimary) async {
    await apiClient.post(
      ApiEndpoints.adminVehicleImages(vehicleId),
      data: {'imageUrl': imageUrl, 'isPrimary': isPrimary},
    );
  }

  Future<void> deleteVehicleImage(String vehicleId, String imageId) async {
    await apiClient.delete(ApiEndpoints.adminDeleteVehicleImage(vehicleId, imageId));
  }

  Future<List<Map<String, dynamic>>> getVehicleSchedule(String vehicleId, DateTime startDate, DateTime endDate) async {
    final query = {
      'startDate': VehicaFormatters.formatApiDate(startDate),
      'endDate': VehicaFormatters.formatApiDate(endDate),
    };
    final response = await apiClient.get(
      ApiEndpoints.adminVehicleSchedule(vehicleId),
      queryParameters: query,
    );
    return List<Map<String, dynamic>>.from(response['data'] as List);
  }
}
