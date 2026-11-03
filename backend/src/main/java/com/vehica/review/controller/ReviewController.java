package com.vehica.review.controller;

import com.vehica.common.response.ApiResponse;
import com.vehica.common.response.PageResponse;
import com.vehica.review.dto.ReviewDtos;
import com.vehica.review.service.ReviewService;
import com.vehica.security.UserPrincipal;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequiredArgsConstructor
@Tag(name = "08. Vehicle Reviews & Ratings", description = "Vehicle Reviews and Ratings APIs")
public class ReviewController {

    private final ReviewService reviewService;

    @GetMapping("/api/v1/vehicles/{vehicleId}/reviews")
    @Operation(summary = "Get paginated reviews for a specific vehicle")
    public ResponseEntity<ApiResponse<PageResponse<ReviewDtos.ReviewDto>>> getVehicleReviews(
            @PathVariable UUID vehicleId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String direction) {

        Sort sort = direction.equalsIgnoreCase("asc") ? Sort.by(sortBy).ascending() : Sort.by(sortBy).descending();
        Pageable pageable = PageRequest.of(page, size, sort);

        PageResponse<ReviewDtos.ReviewDto> response = reviewService.getVehicleReviews(vehicleId, pageable);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping("/api/v1/vehicles/{vehicleId}/reviews/summary")
    @Operation(summary = "Get review rating summary (average score and star distribution) for a vehicle")
    public ResponseEntity<ApiResponse<ReviewDtos.ReviewSummaryDto>> getVehicleReviewSummary(
            @PathVariable UUID vehicleId) {

        ReviewDtos.ReviewSummaryDto summary = reviewService.getVehicleReviewSummary(vehicleId);
        return ResponseEntity.ok(ApiResponse.success(summary));
    }

    @GetMapping("/api/v1/vehicles/{vehicleId}/reviews/my-review")
    @Operation(summary = "Get current authenticated customer's review for a vehicle if exists")
    public ResponseEntity<ApiResponse<ReviewDtos.ReviewDto>> getMyReview(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PathVariable UUID vehicleId) {

        ReviewDtos.ReviewDto review = reviewService.getUserReviewForVehicle(userPrincipal.getId(), vehicleId)
                .orElse(null);
        return ResponseEntity.ok(ApiResponse.success(review));
    }

    @GetMapping("/api/v1/vehicles/{vehicleId}/reviews/eligibility")
    @Operation(summary = "Check if current authenticated customer is eligible to review vehicle (completed rental check)")
    public ResponseEntity<ApiResponse<ReviewDtos.ReviewEligibilityDto>> checkEligibility(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PathVariable UUID vehicleId) {

        if (userPrincipal == null) {
            return ResponseEntity.ok(ApiResponse.success(
                    ReviewDtos.ReviewEligibilityDto.builder()
                            .eligible(false)
                            .alreadyReviewed(false)
                            .message("Vui lòng đăng nhập để đánh giá xe.")
                            .build()
            ));
        }

        ReviewDtos.ReviewEligibilityDto eligibility = reviewService.checkReviewEligibility(userPrincipal.getId(), vehicleId);
        return ResponseEntity.ok(ApiResponse.success(eligibility));
    }

    @PostMapping("/api/v1/vehicles/{vehicleId}/reviews")
    @Operation(summary = "Submit or update rating and review for a vehicle")
    public ResponseEntity<ApiResponse<ReviewDtos.ReviewDto>> submitReview(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PathVariable UUID vehicleId,
            @Valid @RequestBody ReviewDtos.CreateReviewRequest request) {

        ReviewDtos.ReviewDto created = reviewService.createOrUpdateReview(userPrincipal.getId(), vehicleId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Đánh giá xe thành công.", created));
    }

    @DeleteMapping("/api/v1/reviews/{reviewId}")
    @Operation(summary = "Delete customer's own review")
    public ResponseEntity<ApiResponse<Void>> deleteReview(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PathVariable UUID reviewId) {

        reviewService.deleteReview(userPrincipal.getId(), reviewId);
        return ResponseEntity.ok(ApiResponse.success("Đã xóa đánh giá thành công.", null));
    }
}
