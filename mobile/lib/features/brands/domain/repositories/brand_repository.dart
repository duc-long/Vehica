import 'package:vehica_mobile/features/brands/domain/entities/brand_entity.dart';

// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// LAYER             : Domain Layer (Repository Contract / Interface)
// USE CASES         : UC-10 (Brand Management - Admin CRUD Brands)
// ==============================================================================

abstract class BrandRepository {
  Future<List<BrandEntity>> getBrands();
  Future<bool> createBrand({
    required String name,
    String? country,
    String? logoUrl,
    String? description,
    bool isPopular = true,
    int displayOrder = 0,
  });
  Future<bool> updateBrand({
    required String id,
    required String name,
    String? country,
    String? logoUrl,
    String? description,
    bool? isPopular,
    int? displayOrder,
  });
  Future<bool> deleteBrand(String id);
}
