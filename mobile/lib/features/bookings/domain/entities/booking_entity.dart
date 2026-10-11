import 'package:vehica_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:vehica_mobile/features/vehicles/domain/entities/vehicle_entity.dart';

class BookingStatusHistoryEntity {
  final String id;
  final String? fromStatus;
  final String toStatus;
  final String? reason;
  final String changedByName;
  final DateTime changedAt;

  const BookingStatusHistoryEntity({
    required this.id,
    this.fromStatus,
    required this.toStatus,
    this.reason,
    required this.changedByName,
    required this.changedAt,
  });
}

class BookingSummaryEntity {
  final String id;
  final String bookingCode;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final int rentalDays;
  final double pricePerDay;
  final double totalAmount;
  final String vehicleName;
  final String vehicleBrand;
  final String vehicleModel;
  final String? vehicleImageUrl;
  final String customerName;
  final DateTime createdAt;

  const BookingSummaryEntity({
    required this.id,
    required this.bookingCode,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.rentalDays,
    required this.pricePerDay,
    required this.totalAmount,
    required this.vehicleName,
    required this.vehicleBrand,
    required this.vehicleModel,
    this.vehicleImageUrl,
    required this.customerName,
    required this.createdAt,
  });

  bool get isCancellable => status.toUpperCase() == 'PENDING' || status.toUpperCase() == 'CONFIRMED';
}

class BookingDetailEntity {
  final String id;
  final String bookingCode;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final int rentalDays;
  final double pricePerDay;
  final double totalAmount;
  final String? note;
  final UserEntity customer;
  final VehicleEntity vehicle;
  final List<BookingStatusHistoryEntity> statusHistories;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookingDetailEntity({
    required this.id,
    required this.bookingCode,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.rentalDays,
    required this.pricePerDay,
    required this.totalAmount,
    this.note,
    required this.customer,
    required this.vehicle,
    this.statusHistories = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCancellable => status.toUpperCase() == 'PENDING' || status.toUpperCase() == 'CONFIRMED';
}
