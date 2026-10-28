package com.vehica.review.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.OffsetDateTime;
import java.util.Map;
import java.util.UUID;

public class ReviewDtos {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CreateReviewRequest {
        @NotNull(message = "Số sao đánh giá không được để trống")
        @Min(value = 1, message = "Số sao đánh giá tối thiểu là 1")
        @Max(value = 5, message = "Số sao đánh giá tối đa là 5")
        private Integer rating;

        @NotBlank(message = "Nội dung nhận xét không được để trống")
        @Size(min = 5, max = 1000, message = "Nội dung nhận xét phải từ 5 đến 1000 ký tự")
        private String reviewText;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ReviewDto {
        private UUID id;
        private UUID vehicleId;
        private UUID userId;
        private String userFullName;
        private String userAvatarUrl;
        private Integer rating;
        private String reviewText;
        private OffsetDateTime createdAt;
        private OffsetDateTime updatedAt;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ReviewSummaryDto {
        private UUID vehicleId;
        private Double averageRating;
        private Long totalReviews;
        private Map<Integer, Long> ratingCounts;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ReviewEligibilityDto {
        private boolean eligible;
        private boolean alreadyReviewed;
        private String message;
    }
}
