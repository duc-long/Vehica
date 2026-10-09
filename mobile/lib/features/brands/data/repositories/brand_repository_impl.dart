import 'package:vehica_mobile/features/brands/data/datasources/brand_remote_data_source.dart';
import 'package:vehica_mobile/features/brands/domain/entities/brand_entity.dart';
import 'package:vehica_mobile/features/brands/domain/repositories/brand_repository.dart';

// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// LAYER             : Data Layer (Repository Implementation)
// USE CASES         : UC-10 (Brand Management - Admin CRUD Brands)
// ==============================================================================

class BrandRepositoryImpl implements BrandRepository {
  final BrandRemoteDataSource remoteDataSource;

  BrandRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<BrandEntity>> getBrands() => remoteDataSource.getBrands();

  @override
  Future<bool> createBrand({
    required String name,
    String? country,
    String? logoUrl,
    String? description,
    bool isPopular = true,
    int displayOrder = 0,
  }) {
    return remoteDataSource.createBrand({
      'name': name.trim(),
      'country': country?.trim(),
      'logoUrl': (logoUrl != null && logoUrl.trim().isNotEmpty) ? logoUrl.trim() : null,
      'description': description?.trim(),
      'isPopular': isPopular,
      'displayOrder': displayOrder,
    });
  }

  @override
  Future<bool> updateBrand({
    required String id,
    required String name,
    String? country,
    String? logoUrl,
    String? description,
    bool? isPopular,
    int? displayOrder,
  }) {
    final data = <String, dynamic>{'name': name.trim()};
    if (country != null) data['country'] = country.trim();
    if (logoUrl != null) data['logoUrl'] = logoUrl.trim();
    if (description != null) data['description'] = description.trim();
    if (isPopular != null) data['isPopular'] = isPopular;
    if (displayOrder != null) data['displayOrder'] = displayOrder;
    return remoteDataSource.updateBrand(id, data);
  }

  @override
  Future<bool> deleteBrand(String id) => remoteDataSource.deleteBrand(id);
}
