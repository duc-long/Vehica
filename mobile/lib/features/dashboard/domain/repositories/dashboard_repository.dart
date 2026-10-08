import 'package:vehica_mobile/features/dashboard/domain/entities/dashboard_summary_entity.dart';

// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// LAYER             : Domain Layer (Repository Contract / Interface)
// USE CASES         : UC-11 (Admin KPI Dashboard, Revenue & Fleet Analytics)
// ==============================================================================

abstract class DashboardRepository {
  Future<DashboardSummaryEntity> getDashboardSummary();
  Future<Map<String, dynamic>> getRevenue(DateTime? startDate, DateTime? endDate);
}
