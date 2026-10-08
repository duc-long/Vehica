// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// LAYER             : Data Layer (Remote Data Source)
// USE CASES         : UC-11 (Admin KPI Dashboard, Revenue & Fleet Utilization Analytics)
// ENDPOINTS         : /api/admin/dashboard/summary, /api/admin/statistics/revenue
// ==============================================================================

import 'package:vehica_mobile/core/constants/api_endpoints.dart';
import 'package:vehica_mobile/core/network/api_client.dart';
import 'package:vehica_mobile/core/utils/formatters.dart';
import 'package:vehica_mobile/features/dashboard/data/models/dashboard_summary_model.dart';

/// Performs raw HTTP calls for admin analytics. Contains no business logic.
class DashboardRemoteDataSource {
  final ApiClient apiClient;

  DashboardRemoteDataSource({required this.apiClient});

  Future<DashboardSummaryModel> getDashboardSummary() async {
    final response = await apiClient.get(ApiEndpoints.adminDashboardSummary);
    return DashboardSummaryModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> getRevenue(DateTime? startDate, DateTime? endDate) async {
    final query = <String, dynamic>{
      if (startDate != null) 'startDate': VehicaFormatters.formatApiDate(startDate),
      if (endDate != null) 'endDate': VehicaFormatters.formatApiDate(endDate),
    };
    final response = await apiClient.get(ApiEndpoints.adminRevenue, queryParameters: query);
    return response['data'] as Map<String, dynamic>;
  }
}
