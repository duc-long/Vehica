import 'package:vehica_mobile/features/reviews/data/datasources/review_remote_data_source.dart';
import 'package:vehica_mobile/features/reviews/domain/repositories/review_repository.dart';
import 'package:vehica_mobile/features/reviews/domain/entities/review_entity.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  ReviewRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ReviewEntity>> getVehicleReviews(String vehicleId, {int page = 0, int size = 10}) {
    return remoteDataSource.getVehicleReviews(vehicleId, page: page, size: size);
  }

  @override
  Future<ReviewSummaryEntity> getVehicleReviewSummary(String vehicleId) {
    return remoteDataSource.getVehicleReviewSummary(vehicleId);
  }

  @override
  Future<ReviewEntity?> getMyReview(String vehicleId) {
    return remoteDataSource.getMyReview(vehicleId);
  }

  @override
  Future<ReviewEntity> submitReview(String vehicleId, {required int rating, required String reviewText}) {
    return remoteDataSource.submitReview(vehicleId, rating: rating, reviewText: reviewText);
  }

  @override
  Future<void> deleteReview(String reviewId) {
    return remoteDataSource.deleteReview(reviewId);
  }
}
