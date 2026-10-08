import 'package:vehica_mobile/features/vehicles/domain/entities/vehicle_entity.dart';

abstract class VehicleRepository {
  Future<List<VehicleEntity>> getVehicles({
    String? keyword,
    String? typeId,
    int? seatCapacity,
    double? minPrice,
    double? maxPrice,
    String? status,
    int page = 0,
    int size = 10,
  });

  Future<VehicleEntity> getVehicleDetail(String id);

  Future<AvailabilityEntity> checkAvailability({
    required String vehicleId,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<List<VehicleTypeEntity>> getVehicleTypes();

  Future<List<BrandEntity>> getBrands();
  Future<List<BrandEntity>> getPopularBrands();

  // Admin Operations
  Future<VehicleEntity> createVehicle(Map<String, dynamic> data);
  Future<VehicleEntity> updateVehicle(String id, Map<String, dynamic> data);
  Future<VehicleEntity> updateVehicleStatus(String id, String status);
  Future<void> deleteVehicle(String id);
  Future<void> addVehicleImage(String vehicleId, String imageUrl, bool isPrimary);
  Future<void> deleteVehicleImage(String vehicleId, String imageId);
  Future<List<Map<String, dynamic>>> getVehicleSchedule(String vehicleId, DateTime startDate, DateTime endDate);
}
