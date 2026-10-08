// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// LAYER             : Data Layer (DTO / JSON Model)
// USE CASES         : UC-10 (Brand Management), UC-04 (Vehicle Catalog brand filter)
// ==============================================================================

import 'package:vehica_mobile/features/brands/domain/entities/brand_entity.dart';

/// JSON-serializable data model for a vehicle brand returned by `/api/brands`.
class BrandModel extends BrandEntity {
  const BrandModel({
    required super.id,
    required super.name,
    super.logoUrl,
    super.description,
    super.country,
    super.isPopular,
    super.displayOrder,
    super.offerCount,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      logoUrl: json['logoUrl']?.toString(),
      description: json['description']?.toString(),
      country: json['country']?.toString(),
      isPopular: json['isPopular'] == true || json['popular'] == true,
      displayOrder: int.tryParse(json['displayOrder']?.toString() ?? '0') ?? 0,
      offerCount: int.tryParse(json['offerCount']?.toString() ?? '0') ?? 0,
    );
  }
}
