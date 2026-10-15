import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/core/network/api_client.dart';
import 'package:vehica_mobile/core/storage/secure_storage_service.dart';
import 'package:vehica_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:vehica_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:vehica_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:vehica_mobile/features/bookings/data/datasources/booking_remote_data_source.dart';
import 'package:vehica_mobile/features/bookings/data/repositories/booking_repository_impl.dart';
import 'package:vehica_mobile/features/bookings/domain/repositories/booking_repository.dart';
import 'package:vehica_mobile/features/brands/data/datasources/brand_remote_data_source.dart';
import 'package:vehica_mobile/features/brands/data/repositories/brand_repository_impl.dart';
import 'package:vehica_mobile/features/brands/domain/repositories/brand_repository.dart';
import 'package:vehica_mobile/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:vehica_mobile/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:vehica_mobile/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:vehica_mobile/features/users/data/datasources/user_admin_remote_data_source.dart';
import 'package:vehica_mobile/features/users/data/repositories/user_admin_repository_impl.dart';
import 'package:vehica_mobile/features/users/domain/repositories/user_admin_repository.dart';
import 'package:vehica_mobile/features/vehicles/data/datasources/vehicle_remote_data_source.dart';
import 'package:vehica_mobile/features/vehicles/data/repositories/vehicle_repository_impl.dart';
import 'package:vehica_mobile/features/vehicles/domain/repositories/vehicle_repository.dart';

// Storage Provider
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storageService: storage);
});

// Auth Providers
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSource(apiClient: apiClient);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remote = ref.watch(authRemoteDataSourceProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepositoryImpl(remoteDataSource: remote, storageService: storage);
});

// Vehicle Providers
final vehicleRemoteDataSourceProvider = Provider<VehicleRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VehicleRemoteDataSource(apiClient: apiClient);
});

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  final remote = ref.watch(vehicleRemoteDataSourceProvider);
  return VehicleRepositoryImpl(remoteDataSource: remote);
});

// Brand Providers
final brandRemoteDataSourceProvider = Provider<BrandRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BrandRemoteDataSource(apiClient: apiClient);
});

final brandRepositoryProvider = Provider<BrandRepository>((ref) {
  final remote = ref.watch(brandRemoteDataSourceProvider);
  return BrandRepositoryImpl(remoteDataSource: remote);
});

// Booking Providers
final bookingRemoteDataSourceProvider = Provider<BookingRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BookingRemoteDataSource(apiClient: apiClient);
});

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final remote = ref.watch(bookingRemoteDataSourceProvider);
  return BookingRepositoryImpl(remoteDataSource: remote);
});

// User Admin Providers
final userAdminRemoteDataSourceProvider = Provider<UserAdminRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UserAdminRemoteDataSource(apiClient: apiClient);
});

final userAdminRepositoryProvider = Provider<UserAdminRepository>((ref) {
  final remote = ref.watch(userAdminRemoteDataSourceProvider);
  return UserAdminRepositoryImpl(remoteDataSource: remote);
});

// Dashboard & Statistics Providers
final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DashboardRemoteDataSource(apiClient: apiClient);
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final remote = ref.watch(dashboardRemoteDataSourceProvider);
  return DashboardRepositoryImpl(remoteDataSource: remote);
});
