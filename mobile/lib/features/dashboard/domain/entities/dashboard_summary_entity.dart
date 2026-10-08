// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// LAYER             : Domain Layer (Pure Business Entities)
// USE CASES         : UC-11 (Admin KPI Dashboard, Revenue & Fleet Analytics)
// ==============================================================================

class DashboardSummaryEntity {
  final int totalUsers;
  final int activeUsers;
  final int totalVehicles;
  final Map<String, int> vehiclesByStatus;
  final int totalBookings;
  final Map<String, int> bookingsByStatus;
  final double totalEstimatedRevenue;
  final List<PopularVehicleEntity> topVehicles;

  const DashboardSummaryEntity({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalVehicles,
    required this.vehiclesByStatus,
    required this.totalBookings,
    required this.bookingsByStatus,
    required this.totalEstimatedRevenue,
    required this.topVehicles,
  });
}

class PopularVehicleEntity {
  final String vehicleId;
  final String name;
  final String brand;
  final String model;
  final int bookingCount;
  final double totalRevenue;
  final String? imageUrl;

  const PopularVehicleEntity({
    required this.vehicleId,
    required this.name,
    required this.brand,
    required this.model,
    required this.bookingCount,
    required this.totalRevenue,
    this.imageUrl,
  });
}
