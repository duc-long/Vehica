import 'package:vehica_mobile/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:vehica_mobile/features/dashboard/domain/entities/dashboard_summary_entity.dart';
import 'package:vehica_mobile/features/dashboard/domain/repositories/dashboard_repository.dart';

// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// LAYER             : Data Layer (Repository Implementation)
// USE CASES         : UC-11 (Admin KPI Dashboard, Revenue & Fleet Utilization Analytics)
// ==============================================================================

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DashboardSummaryEntity> getDashboardSummary() => remoteDataSource.getDashboardSummary();

  @override
  Future<Map<String, dynamic>> getRevenue(DateTime? startDate, DateTime? endDate) =>
      remoteDataSource.getRevenue(startDate, endDate);
}
