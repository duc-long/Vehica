import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/core/network/api_client.dart';
import 'package:vehica_mobile/core/storage/secure_storage_service.dart';

// Storage Provider
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storageService: storage);
});
