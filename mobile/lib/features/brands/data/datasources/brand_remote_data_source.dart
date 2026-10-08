// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// LAYER             : Data Layer (Remote Data Source)
// USE CASES         : UC-10 (Brand Management - Admin CRUD Brands)
// ENDPOINTS         : GET /api/brands, POST/PUT/DELETE /api/admin/brands
// ==============================================================================

import 'package:vehica_mobile/core/constants/api_endpoints.dart';
import 'package:vehica_mobile/core/network/api_client.dart';
import 'package:vehica_mobile/features/brands/data/models/brand_model.dart';

/// Performs raw HTTP calls for brand resources. Contains no business logic.
class BrandRemoteDataSource {
  final ApiClient apiClient;

  BrandRemoteDataSource({required this.apiClient});

  Future<List<BrandModel>> getBrands() async {
    final response = await apiClient.get(ApiEndpoints.brands);
    if (response != null && response['data'] is List) {
      return (response['data'] as List<dynamic>)
          .map((json) => BrandModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<bool> createBrand(Map<String, dynamic> data) async {
    final response = await apiClient.post(ApiEndpoints.adminBrands, data: data);
    return response != null && (response['success'] == true || response['data'] != null);
  }

  Future<bool> updateBrand(String id, Map<String, dynamic> data) async {
    final response = await apiClient.put(ApiEndpoints.adminBrandDetail(id), data: data);
    return response != null && (response['success'] == true || response['data'] != null);
  }

  Future<bool> deleteBrand(String id) async {
    final response = await apiClient.delete(ApiEndpoints.adminBrandDetail(id));
    return response != null && (response['success'] == true || response['statusCode'] == 200);
  }
}
