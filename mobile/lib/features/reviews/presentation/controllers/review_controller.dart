import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/app/providers.dart';
import 'package:vehica_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:vehica_mobile/features/reviews/domain/entities/review_entity.dart';
import 'package:vehica_mobile/features/reviews/domain/repositories/review_repository.dart';

class ReviewState {
  final List<ReviewEntity> reviews;
  final ReviewSummaryEntity? summary;
  final ReviewEntity? myReview;
  final ReviewEligibilityEntity? eligibility;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  const ReviewState({
    this.reviews = const [],
    this.summary,
    this.myReview,
    this.eligibility,
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  ReviewState copyWith({
    List<ReviewEntity>? reviews,
    ReviewSummaryEntity? summary,
    ReviewEntity? myReview,
    ReviewEligibilityEntity? eligibility,
    bool clearMyReview = false,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
  }) {
    return ReviewState(
      reviews: reviews ?? this.reviews,
      summary: summary ?? this.summary,
      myReview: clearMyReview ? null : (myReview ?? this.myReview),
      eligibility: eligibility ?? this.eligibility,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }
}

class ReviewController extends StateNotifier<ReviewState> {
  final ReviewRepository _repository;
  final Ref _ref;
  final String vehicleId;

  ReviewController(
    this._repository,
    this._ref, {
    required this.vehicleId,
  }) : super(const ReviewState()) {
    loadVehicleReviews();
  }

  Future<void> loadVehicleReviews({bool refresh = false}) async {
    if (state.isLoading && !refresh) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final authState = _ref.read(authControllerProvider);

      final futures = await Future.wait([
        _repository.getVehicleReviews(vehicleId, page: 0, size: 20),
        _repository.getVehicleReviewSummary(vehicleId),
        if (authState.isAuthenticated)
          _repository.getMyReview(vehicleId)
        else
          Future.value(null),
        if (authState.isAuthenticated)
          _repository.getReviewEligibility(vehicleId)
        else
          Future.value(null),
      ]);

      final reviews = futures[0] as List<ReviewEntity>;
      final summary = futures[1] as ReviewSummaryEntity;
      final myReview = futures[2] as ReviewEntity?;
      final eligibility = futures[3] as ReviewEligibilityEntity?;

      state = state.copyWith(
        reviews: reviews,
        summary: summary,
        myReview: myReview,
        eligibility: eligibility,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> submitReview({required int rating, required String reviewText}) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final created = await _repository.submitReview(
        vehicleId,
        rating: rating,
        reviewText: reviewText,
      );

      // Cập nhật lại danh sách reviews và myReview
      final updatedList = List<ReviewEntity>.from(state.reviews);
      final existingIndex = updatedList.indexWhere((r) => r.id == created.id || r.userId == created.userId);
      if (existingIndex >= 0) {
        updatedList[existingIndex] = created;
      } else {
        updatedList.insert(0, created);
      }

      state = state.copyWith(
        reviews: updatedList,
        myReview: created,
        eligibility: const ReviewEligibilityEntity(
          eligible: true,
          alreadyReviewed: true,
          message: 'Bạn đã gửi đánh giá cho xe này.',
        ),
        isSubmitting: false,
      );

      // Tải lại summary điểm số mới nhất
      final updatedSummary = await _repository.getVehicleReviewSummary(vehicleId);
      state = state.copyWith(summary: updatedSummary);

      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      rethrow;
    }
  }

  Future<bool> deleteReview(String reviewId) async {
    try {
      await _repository.deleteReview(reviewId);
      final updatedList = state.reviews.where((r) => r.id != reviewId).toList();
      state = state.copyWith(
        reviews: updatedList,
        clearMyReview: true,
      );

      final updatedSummary = await _repository.getVehicleReviewSummary(vehicleId);
      state = state.copyWith(summary: updatedSummary);
      return true;
    } catch (e) {
      rethrow;
    }
  }
}

final reviewControllerProvider =
    StateNotifierProvider.autoDispose.family<ReviewController, ReviewState, String>((ref, vehicleId) {
  final repository = ref.watch(reviewRepositoryProvider);
  return ReviewController(
    repository,
    ref,
    vehicleId: vehicleId,
  );
});
