import 'package:vehica_mobile/features/reviews/domain/entities/review_entity.dart';

abstract class ReviewRepository {
  Future<List<ReviewEntity>> getVehicleReviews(String vehicleId, {int page = 0, int size = 10});
  Future<ReviewSummaryEntity> getVehicleReviewSummary(String vehicleId);
  Future<ReviewEntity?> getMyReview(String vehicleId);
  Future<ReviewEntity> submitReview(String vehicleId, {required int rating, required String reviewText});
  Future<void> deleteReview(String reviewId);
}
