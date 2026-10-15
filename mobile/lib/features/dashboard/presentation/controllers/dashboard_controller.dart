// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// LAYER             : Presentation Layer (FutureProvider)
// USE CASES         : UC-11 - KPI Statistics & Management Reports (Admin Dashboard & Analytics)
// BUSINESS RULES    : BR-22 (Timezone UTC+7, Revenue stats, occupancy rate, hot vehicles)
// ------------------------------------------------------------------------------
// DATA FLOW:
// UI (AdminDashboardPage S10)
//   --> adminDashboardSummaryProvider
//   --> DashboardRepository (Domain Interface)
//   --> DashboardRepositoryImpl (Data Layer)
//   --> DashboardRemoteDataSource (Dio HTTP Client)
//   --> Spring Boot REST API (/api/admin/statistics/summary)
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/app/providers.dart';
import 'package:vehica_mobile/features/dashboard/domain/entities/dashboard_summary_entity.dart';

/// Provider supplying aggregated KPI data for Admin Dashboard (S10)
/// Auto-reload upon receiving Invalidate command from any changes in bookings, vehicles, or users.
final adminDashboardSummaryProvider = FutureProvider.autoDispose<DashboardSummaryEntity>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getDashboardSummary();
});
