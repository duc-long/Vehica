import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/app/providers.dart';
import 'package:vehica_mobile/features/brands/domain/entities/brand_entity.dart';
import 'package:vehica_mobile/features/brands/domain/repositories/brand_repository.dart';
import 'package:vehica_mobile/features/vehicles/presentation/controllers/vehicle_list_controller.dart';

/// Provider for brand list for Admin (S13)
final adminBrandsListProvider =
    FutureProvider.autoDispose<List<BrandEntity>>((ref) async {
  final repo = ref.watch(brandRepositoryProvider);
  return repo.getBrands();
});

final brandAdminControllerProvider =
    Provider<BrandAdminController>((ref) => BrandAdminController(ref));

/// Controller managing vehicle brands for Admin (S13)
class BrandAdminController {
  final Ref _ref;

  BrandAdminController(this._ref);

  BrandRepository get _repo => _ref.read(brandRepositoryProvider);

  /// Add new brand (S13 Admin CRUD)
  Future<bool> createBrand({
    required String name,
    String? country,
    String? logoUrl,
    String? description,
    bool isPopular = true,
    int displayOrder = 0,
  }) async {
    final success = await _repo.createBrand(
      name: name,
      country: country,
      logoUrl: logoUrl,
      description: description,
      isPopular: isPopular,
      displayOrder: displayOrder,
    );

    if (success) {
      _ref.invalidate(adminBrandsListProvider);
      _ref.invalidate(popularBrandsProvider);
    }
    return success;
  }

  /// Update brand information (S13 Admin CRUD)
  Future<bool> updateBrand(
    String id, {
    required String name,
    String? country,
    String? logoUrl,
    String? description,
    bool? isPopular,
    int? displayOrder,
  }) async {
    final success = await _repo.updateBrand(
      id: id,
      name: name,
      country: country,
      logoUrl: logoUrl,
      description: description,
      isPopular: isPopular,
      displayOrder: displayOrder,
    );

    if (success) {
      _ref.invalidate(adminBrandsListProvider);
      _ref.invalidate(popularBrandsProvider);
    }
    return success;
  }

  /// Delete brand (S13 Admin CRUD)
  Future<bool> deleteBrand(String id) async {
    final success = await _repo.deleteBrand(id);

    if (success) {
      _ref.invalidate(adminBrandsListProvider);
      _ref.invalidate(popularBrandsProvider);
    }
    return success;
  }
}
