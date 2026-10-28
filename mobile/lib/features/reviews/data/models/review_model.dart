import 'package:vehica_mobile/features/reviews/domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.vehicleId,
    required super.userId,
    required super.userFullName,
    super.userAvatarUrl,
    required super.rating,
    required super.reviewText,
    required super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id']?.toString() ?? '',
      vehicleId: json['vehicleId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userFullName: json['userFullName']?.toString() ?? 'Khách hàng',
      userAvatarUrl: json['userAvatarUrl']?.toString(),
      rating: json['rating'] is int ? json['rating'] as int : int.tryParse(json['rating']?.toString() ?? '5') ?? 5,
      reviewText: json['reviewText']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class ReviewSummaryModel extends ReviewSummaryEntity {
  const ReviewSummaryModel({
    required super.vehicleId,
    required super.averageRating,
    required super.totalReviews,
    required super.ratingCounts,
  });

  factory ReviewSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawCounts = json['ratingCounts'] as Map<String, dynamic>? ?? {};
    final counts = <int, int>{};
    for (int star = 1; star <= 5; star++) {
      counts[star] = int.tryParse(rawCounts[star.toString()]?.toString() ?? '0') ?? 0;
    }

    return ReviewSummaryModel(
      vehicleId: json['vehicleId']?.toString() ?? '',
      averageRating: json['averageRating'] is num
          ? (json['averageRating'] as num).toDouble()
          : double.tryParse(json['averageRating']?.toString() ?? '0.0') ?? 0.0,
      totalReviews: json['totalReviews'] is int
          ? json['totalReviews'] as int
          : int.tryParse(json['totalReviews']?.toString() ?? '0') ?? 0,
      ratingCounts: counts,
    );
  }
}
