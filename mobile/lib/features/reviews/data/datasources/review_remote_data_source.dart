import 'package:vehica_mobile/core/constants/api_endpoints.dart';
import 'package:vehica_mobile/core/network/api_client.dart';
import 'package:vehica_mobile/features/reviews/data/models/review_model.dart';

class ReviewRemoteDataSource {
  final ApiClient apiClient;

  ReviewRemoteDataSource({required this.apiClient});

  Future<List<ReviewModel>> getVehicleReviews(String vehicleId, {int page = 0, int size = 10}) async {
    final response = await apiClient.get(
      ApiEndpoints.vehicleReviews(vehicleId),
      queryParameters: {'page': page, 'size': size},
    );
    final data = response['data'] as Map<String, dynamic>;
    final list = data['content'] as List;
    return list.map((item) => ReviewModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<ReviewSummaryModel> getVehicleReviewSummary(String vehicleId) async {
    final response = await apiClient.get(ApiEndpoints.vehicleReviewSummary(vehicleId));
    final data = response['data'] as Map<String, dynamic>;
    return ReviewSummaryModel.fromJson(data);
  }

  Future<ReviewModel?> getMyReview(String vehicleId) async {
    final response = await apiClient.get(ApiEndpoints.vehicleMyReview(vehicleId));
    final data = response['data'];
    if (data == null) return null;
    return ReviewModel.fromJson(data as Map<String, dynamic>);
  }

  Future<ReviewEligibilityModel> getReviewEligibility(String vehicleId) async {
    final response = await apiClient.get(ApiEndpoints.vehicleReviewEligibility(vehicleId));
    final data = response['data'] as Map<String, dynamic>;
    return ReviewEligibilityModel.fromJson(data);
  }

  Future<ReviewModel> submitReview(
    String vehicleId, {
    required int rating,
    required String reviewText,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.vehicleReviews(vehicleId),
      data: {
        'rating': rating,
        'reviewText': reviewText,
      },
    );
    final data = response['data'] as Map<String, dynamic>;
    return ReviewModel.fromJson(data);
  }

  Future<void> deleteReview(String reviewId) async {
    await apiClient.delete(ApiEndpoints.deleteReview(reviewId));
  }
}
