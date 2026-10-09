export 'package:vehica_mobile/features/brands/domain/entities/brand_entity.dart';


class VehicleTypeEntity {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;

  const VehicleTypeEntity({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
  });
}

class VehicleImageEntity {
  final String id;
  final String imageUrl;
  final bool isPrimary;

  const VehicleImageEntity({
    required this.id,
    required this.imageUrl,
    required this.isPrimary,
  });
}

class VehicleEntity {
  final String id;
  final String name;
  final String brand;
  final String model;
  final String licensePlate;
  final int year;
  final int seatCapacity;
  final double pricePerDay;
  final String status; // 'AVAILABLE' | 'RENTED' | 'MAINTENANCE' | 'INACTIVE'
  final String? description;
  final String? primaryImageUrl;
  final VehicleTypeEntity type;
  final List<VehicleImageEntity> images;
  final List<String> features;

  const VehicleEntity({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.licensePlate,
    required this.year,
    this.seatCapacity = 5,
    required this.pricePerDay,
    required this.status,
    this.description,
    this.primaryImageUrl,
    required this.type,
    this.images = const [],
    this.features = const [],
  });

  bool get isAvailable => status.toUpperCase() == 'AVAILABLE';
}

class AvailabilityEntity {
  final String vehicleId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isAvailable;
  final String reason;
  final double pricePerDay;
  final int rentalDays;
  final double estimatedTotalAmount;

  const AvailabilityEntity({
    required this.vehicleId,
    required this.startDate,
    required this.endDate,
    required this.isAvailable,
    required this.reason,
    required this.pricePerDay,
    required this.rentalDays,
    required this.estimatedTotalAmount,
  });
}
