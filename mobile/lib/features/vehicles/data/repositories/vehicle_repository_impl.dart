import 'package:vehica_mobile/features/vehicles/data/datasources/vehicle_remote_data_source.dart';
import 'package:vehica_mobile/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:vehica_mobile/features/vehicles/domain/repositories/vehicle_repository.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleRemoteDataSource remoteDataSource;

  VehicleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<VehicleEntity>> getVehicles({
    String? keyword,
    String? typeId,
    int? seatCapacity,
    double? minPrice,
    double? maxPrice,
    String? status,
    int page = 0,
    int size = 10,
  }) async {
    return await remoteDataSource.getVehicles(
      keyword: keyword,
      typeId: typeId,
      seatCapacity: seatCapacity,
      minPrice: minPrice,
      maxPrice: maxPrice,
      status: status,
      page: page,
      size: size,
    );
  }

  @override
  Future<VehicleEntity> getVehicleDetail(String id) async {
    return await remoteDataSource.getVehicleDetail(id);
  }

  @override
  Future<AvailabilityEntity> checkAvailability({
    required String vehicleId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await remoteDataSource.checkAvailability(
      vehicleId: vehicleId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<List<VehicleTypeEntity>> getVehicleTypes() async {
    return await remoteDataSource.getVehicleTypes();
  }

  @override
  Future<List<BrandEntity>> getBrands() async {
    return await remoteDataSource.getBrands();
  }

  @override
  Future<List<BrandEntity>> getPopularBrands() async {
    return await remoteDataSource.getPopularBrands();
  }

  @override
  Future<VehicleEntity> createVehicle(Map<String, dynamic> data) async {
    return await remoteDataSource.createVehicle(data);
  }

  @override
  Future<VehicleEntity> updateVehicle(String id, Map<String, dynamic> data) async {
    return await remoteDataSource.updateVehicle(id, data);
  }

  @override
  Future<VehicleEntity> updateVehicleStatus(String id, String status) async {
    return await remoteDataSource.updateVehicleStatus(id, status);
  }

  @override
  Future<void> deleteVehicle(String id) async {
    await remoteDataSource.deleteVehicle(id);
  }

  @override
  Future<void> addVehicleImage(String vehicleId, String imageUrl, bool isPrimary) async {
    await remoteDataSource.addVehicleImage(vehicleId, imageUrl, isPrimary);
  }

  @override
  Future<void> deleteVehicleImage(String vehicleId, String imageId) async {
    await remoteDataSource.deleteVehicleImage(vehicleId, imageId);
  }

  @override
  Future<List<Map<String, dynamic>>> getVehicleSchedule(String vehicleId, DateTime startDate, DateTime endDate) async {
    return await remoteDataSource.getVehicleSchedule(vehicleId, startDate, endDate);
  }
}
