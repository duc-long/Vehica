class BrandEntity {
  final String id;
  final String name;
  final String? logoUrl;
  final String? description;
  final String? country;
  final bool isPopular;
  final int displayOrder;
  final int offerCount;

  const BrandEntity({
    required this.id,
    required this.name,
    this.logoUrl,
    this.description,
    this.country,
    this.isPopular = false,
    this.displayOrder = 0,
    this.offerCount = 0,
  });
}
