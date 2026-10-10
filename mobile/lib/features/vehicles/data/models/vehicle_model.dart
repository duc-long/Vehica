import 'package:vehica_mobile/features/vehicles/domain/entities/vehicle_entity.dart';

export 'package:vehica_mobile/features/brands/data/models/brand_model.dart';

class VehicleTypeModel extends VehicleTypeEntity {
  const VehicleTypeModel({
    required super.id,
    required super.name,
    super.description,
    super.imageUrl,
  });

  factory VehicleTypeModel.fromJson(Map<String, dynamic> json) {
    return VehicleTypeModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
    );
  }
}

class VehicleImageModel extends VehicleImageEntity {
  const VehicleImageModel({
    required super.id,
    required super.imageUrl,
    required super.isPrimary,
  });

  factory VehicleImageModel.fromJson(Map<String, dynamic> json) {
    return VehicleImageModel(
      id: json['id']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      isPrimary: json['isPrimary'] == true,
    );
  }
}

class VehicleModel extends VehicleEntity {
  const VehicleModel({
    required super.id,
    required super.name,
    required super.brand,
    required super.model,
    required super.licensePlate,
    required super.year,
    super.seatCapacity = 5,
    required super.pricePerDay,
    required super.status,
    super.description,
    super.primaryImageUrl,
    required super.type,
    super.images,
    super.features,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    List<VehicleImageEntity> imgs = [];
    if (json['images'] is List) {
      imgs = (json['images'] as List)
          .map((img) => VehicleImageModel.fromJson(img as Map<String, dynamic>))
          .toList();
    }

    List<String> featList = [];
    if (json['features'] is List) {
      featList = (json['features'] as List)
          .map((f) => f.toString())
          .toList();
    }

    return VehicleModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      licensePlate: json['licensePlate']?.toString() ?? '',
      year: int.tryParse(json['year']?.toString() ?? '2024') ?? 2024,
      seatCapacity: int.tryParse(json['seatCapacity']?.toString() ?? json['seat_capacity']?.toString() ?? '5') ?? 5,
      pricePerDay: double.tryParse(json['pricePerDay']?.toString() ?? '0') ?? 0.0,
      status: json['status']?.toString() ?? 'AVAILABLE',
      description: json['description']?.toString(),
      primaryImageUrl: json['primaryImageUrl']?.toString(),
      type: json['type'] != null
          ? VehicleTypeModel.fromJson(json['type'] as Map<String, dynamic>)
          : const VehicleTypeEntity(id: '', name: 'Standard'),
      images: imgs,
      features: featList,
    );
  }
}

class AvailabilityModel extends AvailabilityEntity {
  const AvailabilityModel({
    required super.vehicleId,
    required super.startDate,
    required super.endDate,
    required super.isAvailable,
    required super.reason,
    required super.pricePerDay,
    required super.rentalDays,
    required super.estimatedTotalAmount,
  });

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityModel(
      vehicleId: json['vehicleId']?.toString() ?? '',
      startDate: DateTime.tryParse(json['startDate']?.toString() ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate']?.toString() ?? '') ?? DateTime.now(),
      isAvailable: json['isAvailable'] == true || json['available'] == true,
      reason: json['reason']?.toString() ?? '',
      pricePerDay: double.tryParse(json['pricePerDay']?.toString() ?? '0') ?? 0.0,
      rentalDays: int.tryParse(json['rentalDays']?.toString() ?? '1') ?? 1,
      estimatedTotalAmount: double.tryParse(json['estimatedTotalAmount']?.toString() ?? '0') ?? 0.0,
    );
  }
}
