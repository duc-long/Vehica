class ReviewEntity {
  final String id;
  final String vehicleId;
  final String userId;
  final String userFullName;
  final String? userAvatarUrl;
  final int rating;
  final String reviewText;
  final DateTime createdAt;

  const ReviewEntity({
    required this.id,
    required this.vehicleId,
    required this.userId,
    required this.userFullName,
    this.userAvatarUrl,
    required this.rating,
    required this.reviewText,
    required this.createdAt,
  });
}

class ReviewSummaryEntity {
  final String vehicleId;
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingCounts;

  const ReviewSummaryEntity({
    required this.vehicleId,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingCounts,
  });
}

class ReviewEligibilityEntity {
  final bool eligible;
  final bool alreadyReviewed;
  final String? message;

  const ReviewEligibilityEntity({
    required this.eligible,
    required this.alreadyReviewed,
    this.message,
  });
}
