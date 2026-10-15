// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// LAYER             : Data Layer (DTO / JSON Model)
// USE CASES         : UC-11 (Admin KPI Dashboard, Revenue & Fleet Analytics)
// ==============================================================================

import 'package:vehica_mobile/features/dashboard/domain/entities/dashboard_summary_entity.dart';

int _toInt(dynamic v) => int.tryParse(v?.toString() ?? '0') ?? 0;
double _toDouble(dynamic v) => double.tryParse(v?.toString() ?? '0') ?? 0.0;

Map<String, int> _toCountMap(dynamic raw) {
  final map = <String, int>{};
  if (raw is Map) {
    raw.forEach((k, v) => map[k.toString()] = _toInt(v));
  }
  return map;
}

class PopularVehicleModel extends PopularVehicleEntity {
  const PopularVehicleModel({
    required super.vehicleId,
    required super.name,
    required super.brand,
    required super.model,
    required super.bookingCount,
    required super.totalRevenue,
    super.imageUrl,
  });

  factory PopularVehicleModel.fromJson(Map<String, dynamic> json) {
    return PopularVehicleModel(
      vehicleId: json['vehicleId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      bookingCount: _toInt(json['bookingCount']),
      totalRevenue: _toDouble(json['totalRevenue']),
      imageUrl: json['imageUrl']?.toString(),
    );
  }
}

/// JSON model for `GET /api/admin/dashboard/summary`.
class DashboardSummaryModel extends DashboardSummaryEntity {
  const DashboardSummaryModel({
    required super.totalUsers,
    required super.activeUsers,
    required super.totalVehicles,
    required super.vehiclesByStatus,
    required super.totalBookings,
    required super.bookingsByStatus,
    required super.totalEstimatedRevenue,
    required super.topVehicles,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawTop = json['topVehicles'];
    return DashboardSummaryModel(
      totalUsers: _toInt(json['totalUsers']),
      activeUsers: _toInt(json['activeUsers']),
      totalVehicles: _toInt(json['totalVehicles']),
      vehiclesByStatus: _toCountMap(json['vehiclesByStatus']),
      totalBookings: _toInt(json['totalBookings']),
      bookingsByStatus: _toCountMap(json['bookingsByStatus']),
      totalEstimatedRevenue: _toDouble(json['totalEstimatedRevenue']),
      topVehicles: rawTop is List
          ? rawTop
              .map((item) => PopularVehicleModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }
}
