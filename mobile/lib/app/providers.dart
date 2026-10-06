import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/core/network/api_client.dart';
import 'package:vehica_mobile/core/storage/secure_storage_service.dart';
import 'package:vehica_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:vehica_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:vehica_mobile/features/auth/domain/repositories/auth_repository.dart';

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
