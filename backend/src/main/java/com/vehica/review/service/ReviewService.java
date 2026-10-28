package com.vehica.review.service;

import com.vehica.common.exception.ForbiddenException;
import com.vehica.common.exception.ResourceNotFoundException;
import com.vehica.common.response.PageResponse;
import com.vehica.review.dto.ReviewDtos;
import com.vehica.review.entity.VehicleReview;
import com.vehica.review.repository.VehicleReviewRepository;
import com.vehica.user.entity.User;
import com.vehica.user.repository.UserRepository;
import com.vehica.vehicle.entity.Vehicle;
import com.vehica.vehicle.repository.VehicleRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class ReviewService {

    private final VehicleReviewRepository vehicleReviewRepository;
    private final UserRepository userRepository;
    private final VehicleRepository vehicleRepository;

    @Transactional
    public ReviewDtos.ReviewDto createOrUpdateReview(UUID userId, UUID vehicleId, ReviewDtos.CreateReviewRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy thông tin người dùng: " + userId));

        Vehicle vehicle = vehicleRepository.findById(vehicleId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy xe với ID: " + vehicleId));

        Optional<VehicleReview> existingReview = vehicleReviewRepository.findByUserIdAndVehicleId(userId, vehicleId);

        VehicleReview review;
        if (existingReview.isPresent()) {
            review = existingReview.get();
            review.setRating(request.getRating());
            review.setReviewText(request.getReviewText().trim());
            log.info("User {} updated review for vehicle {}", userId, vehicleId);
        } else {
            review = VehicleReview.builder()
                    .user(user)
                    .vehicle(vehicle)
                    .rating(request.getRating())
                    .reviewText(request.getReviewText().trim())
                    .build();
            log.info("User {} created new review for vehicle {}", userId, vehicleId);
        }

        VehicleReview saved = vehicleReviewRepository.save(review);
        return mapToDto(saved);
    }

    @Transactional(readOnly = true)
    public PageResponse<ReviewDtos.ReviewDto> getVehicleReviews(UUID vehicleId, Pageable pageable) {
        if (!vehicleRepository.existsById(vehicleId)) {
            throw new ResourceNotFoundException("Không tìm thấy xe với ID: " + vehicleId);
        }

        Page<VehicleReview> reviewPage = vehicleReviewRepository.findByVehicleIdOrderByCreatedAtDesc(vehicleId, pageable);
        Page<ReviewDtos.ReviewDto> dtoPage = reviewPage.map(this::mapToDto);
        return PageResponse.from(dtoPage);
    }

    @Transactional(readOnly = true)
    public ReviewDtos.ReviewSummaryDto getVehicleReviewSummary(UUID vehicleId) {
        if (!vehicleRepository.existsById(vehicleId)) {
            throw new ResourceNotFoundException("Không tìm thấy xe với ID: " + vehicleId);
        }

        Double rawAvg = vehicleReviewRepository.getAverageRatingByVehicleId(vehicleId);
        Long totalReviews = vehicleReviewRepository.countReviewsByVehicleId(vehicleId);

        Double roundedAvg = 0.0;
        if (rawAvg != null) {
            roundedAvg = BigDecimal.valueOf(rawAvg).setScale(1, RoundingMode.HALF_UP).doubleValue();
        }

        Map<Integer, Long> ratingCounts = new LinkedHashMap<>();
        for (int i = 5; i >= 1; i--) {
            ratingCounts.put(i, 0L);
        }

        List<Object[]> starGroups = vehicleReviewRepository.countRatingsGroupedByStars(vehicleId);
        if (starGroups != null) {
            for (Object[] row : starGroups) {
                Integer star = ((Number) row[0]).intValue();
                Long count = ((Number) row[1]).longValue();
                ratingCounts.put(star, count);
            }
        }

        return ReviewDtos.ReviewSummaryDto.builder()
                .vehicleId(vehicleId)
                .averageRating(roundedAvg)
                .totalReviews(totalReviews != null ? totalReviews : 0L)
                .ratingCounts(ratingCounts)
                .build();
    }

    @Transactional(readOnly = true)
    public Optional<ReviewDtos.ReviewDto> getUserReviewForVehicle(UUID userId, UUID vehicleId) {
        return vehicleReviewRepository.findByUserIdAndVehicleId(userId, vehicleId)
                .map(this::mapToDto);
    }

    @Transactional
    public void deleteReview(UUID userId, UUID reviewId) {
        VehicleReview review = vehicleReviewRepository.findById(reviewId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy đánh giá với ID: " + reviewId));

        if (!review.getUser().getId().equals(userId)) {
            throw new ForbiddenException("Bạn không có quyền xóa đánh giá của người dùng khác.");
        }

        vehicleReviewRepository.delete(review);
        log.info("User {} deleted review {}", userId, reviewId);
    }

    public ReviewDtos.ReviewDto mapToDto(VehicleReview review) {
        return ReviewDtos.ReviewDto.builder()
                .id(review.getId())
                .vehicleId(review.getVehicle().getId())
                .userId(review.getUser().getId())
                .userFullName(review.getUser().getFullName())
                .userAvatarUrl(review.getUser().getAvatarUrl())
                .rating(review.getRating())
                .reviewText(review.getReviewText())
                .createdAt(review.getCreatedAt())
                .updatedAt(review.getUpdatedAt())
                .build();
    }
}
