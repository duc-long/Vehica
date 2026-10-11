import 'package:vehica_mobile/features/auth/data/models/user_model.dart';
import 'package:vehica_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:vehica_mobile/features/bookings/domain/entities/booking_entity.dart';
import 'package:vehica_mobile/features/vehicles/data/models/vehicle_model.dart';
import 'package:vehica_mobile/features/vehicles/domain/entities/vehicle_entity.dart';

class BookingStatusHistoryModel extends BookingStatusHistoryEntity {
  const BookingStatusHistoryModel({
    required super.id,
    super.fromStatus,
    required super.toStatus,
    super.reason,
    required super.changedByName,
    required super.changedAt,
  });

  factory BookingStatusHistoryModel.fromJson(Map<String, dynamic> json) {
    return BookingStatusHistoryModel(
      id: json['id']?.toString() ?? '',
      fromStatus: json['fromStatus']?.toString(),
      toStatus: json['toStatus']?.toString() ?? 'PENDING',
      reason: json['reason']?.toString(),
      changedByName: json['changedByName']?.toString() ?? 'Hệ thống',
      changedAt: DateTime.tryParse(json['changedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class BookingSummaryModel extends BookingSummaryEntity {
  const BookingSummaryModel({
    required super.id,
    required super.bookingCode,
    required super.status,
    required super.startDate,
    required super.endDate,
    required super.rentalDays,
    required super.pricePerDay,
    required super.totalAmount,
    required super.vehicleName,
    required super.vehicleBrand,
    required super.vehicleModel,
    super.vehicleImageUrl,
    required super.customerName,
    required super.createdAt,
  });

  factory BookingSummaryModel.fromJson(Map<String, dynamic> json) {
    return BookingSummaryModel(
      id: json['id']?.toString() ?? '',
      bookingCode: json['bookingCode']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      startDate: DateTime.tryParse(json['startDate']?.toString() ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate']?.toString() ?? '') ?? DateTime.now(),
      rentalDays: int.tryParse(json['rentalDays']?.toString() ?? '1') ?? 1,
      pricePerDay: double.tryParse(json['pricePerDay']?.toString() ?? '0') ?? 0.0,
      totalAmount: double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0,
      vehicleName: json['vehicleName']?.toString() ?? '',
      vehicleBrand: json['vehicleBrand']?.toString() ?? '',
      vehicleModel: json['vehicleModel']?.toString() ?? '',
      vehicleImageUrl: json['vehicleImageUrl']?.toString(),
      customerName: json['customerName']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class BookingDetailModel extends BookingDetailEntity {
  const BookingDetailModel({
    required super.id,
    required super.bookingCode,
    required super.status,
    required super.startDate,
    required super.endDate,
    required super.rentalDays,
    required super.pricePerDay,
    required super.totalAmount,
    super.note,
    required super.customer,
    required super.vehicle,
    super.statusHistories,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BookingDetailModel.fromJson(Map<String, dynamic> json) {
    List<BookingStatusHistoryEntity> histories = [];
    if (json['statusHistories'] is List) {
      histories = (json['statusHistories'] as List)
          .map((h) => BookingStatusHistoryModel.fromJson(h as Map<String, dynamic>))
          .toList();
    }

    return BookingDetailModel(
      id: json['id']?.toString() ?? '',
      bookingCode: json['bookingCode']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      startDate: DateTime.tryParse(json['startDate']?.toString() ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate']?.toString() ?? '') ?? DateTime.now(),
      rentalDays: int.tryParse(json['rentalDays']?.toString() ?? '1') ?? 1,
      pricePerDay: double.tryParse(json['pricePerDay']?.toString() ?? '0') ?? 0.0,
      totalAmount: double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0,
      note: json['note']?.toString(),
      customer: json['customer'] != null
          ? UserModel.fromJson(json['customer'] as Map<String, dynamic>)
          : const UserEntity(id: '', email: '', fullName: '', phone: '', role: 'USER', status: 'ACTIVE'),
      vehicle: json['vehicle'] != null
          ? VehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>)
          : const VehicleModel(
              id: '',
              name: '',
              brand: '',
              model: '',
              licensePlate: '',
              year: 2024,
              pricePerDay: 0,
              status: 'AVAILABLE',
              type: VehicleTypeEntity(id: '', name: ''),
            ),
      statusHistories: histories,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
