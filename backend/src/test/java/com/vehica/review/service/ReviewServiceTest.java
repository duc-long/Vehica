package com.vehica.review.service;

import com.vehica.booking.repository.BookingRepository;
import com.vehica.common.enums.BookingStatus;
import com.vehica.common.exception.BadRequestException;
import com.vehica.common.exception.ForbiddenException;
import com.vehica.common.exception.ResourceNotFoundException;
import com.vehica.review.dto.ReviewDtos;
import com.vehica.review.entity.VehicleReview;
import com.vehica.review.repository.VehicleReviewRepository;
import com.vehica.user.entity.User;
import com.vehica.user.repository.UserRepository;
import com.vehica.vehicle.entity.Vehicle;
import com.vehica.vehicle.repository.VehicleRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.OffsetDateTime;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ReviewServiceTest {

    @Mock
    private VehicleReviewRepository vehicleReviewRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private VehicleRepository vehicleRepository;

    @Mock
    private BookingRepository bookingRepository;

    @InjectMocks
    private ReviewService reviewService;

    private UUID userId;
    private UUID vehicleId;
    private User testUser;
    private Vehicle testVehicle;

    @BeforeEach
    void setUp() {
        userId = UUID.randomUUID();
        vehicleId = UUID.randomUUID();

        testUser = User.builder()
                .id(userId)
                .fullName("Nguyen Van A")
                .avatarUrl("https://example.com/avatar.jpg")
                .build();

        testVehicle = Vehicle.builder()
                .id(vehicleId)
                .name("VinFast VF8 Plus")
                .build();
    }

    @Test
    @DisplayName("Cập nhật đánh giá thành công khi đã có đánh giá trước đó")
    void testUpdateReview_Success() {
        // Arrange
        ReviewDtos.CreateReviewRequest updateRequest = ReviewDtos.CreateReviewRequest.builder()
                .rating(4)
                .reviewText("Xe rất êm, cập nhật lại nhận xét sau khi đi thêm 1 tuần")
                .build();

        VehicleReview existingReview = VehicleReview.builder()
                .id(UUID.randomUUID())
                .user(testUser)
                .vehicle(testVehicle)
                .rating(5)
                .reviewText("Xe chạy rất tốt, ban đầu đánh giá 5 sao")
                .createdAt(OffsetDateTime.now().minusDays(3))
                .updatedAt(OffsetDateTime.now().minusDays(3))
                .build();

        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));
        when(vehicleRepository.findById(vehicleId)).thenReturn(Optional.of(testVehicle));
        when(bookingRepository.existsByUserIdAndVehicleIdAndStatus(userId, vehicleId, BookingStatus.COMPLETED))
                .thenReturn(true);
        when(vehicleReviewRepository.findByUserIdAndVehicleId(userId, vehicleId))
                .thenReturn(Optional.of(existingReview));
        when(vehicleReviewRepository.saveAndFlush(any(VehicleReview.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        // Act
        ReviewDtos.ReviewDto result = reviewService.createOrUpdateReview(userId, vehicleId, updateRequest);

        // Assert
        assertThat(result).isNotNull();
        assertThat(result.getRating()).isEqualTo(4);
        assertThat(result.getReviewText()).isEqualTo("Xe rất êm, cập nhật lại nhận xét sau khi đi thêm 1 tuần");
        assertThat(result.getUserFullName()).isEqualTo("Nguyen Van A");

        verify(vehicleReviewRepository, times(1)).saveAndFlush(existingReview);
        assertThat(existingReview.getRating()).isEqualTo(4);
        assertThat(existingReview.getReviewText()).isEqualTo("Xe rất êm, cập nhật lại nhận xét sau khi đi thêm 1 tuần");
    }

    @Test
    @DisplayName("Cập nhật đánh giá trực tiếp qua reviewId thành công khi đúng chủ sở hữu")
    void testUpdateReviewById_Success() {
        UUID reviewId = UUID.randomUUID();
        ReviewDtos.CreateReviewRequest updateRequest = ReviewDtos.CreateReviewRequest.builder()
                .rating(3)
                .reviewText("Cập nhật lại qua ID: dịch vụ ổn nhưng xe hơi hao pin")
                .build();

        VehicleReview existingReview = VehicleReview.builder()
                .id(reviewId)
                .user(testUser)
                .vehicle(testVehicle)
                .rating(5)
                .reviewText("Ban đầu đánh giá 5 sao")
                .build();

        when(vehicleReviewRepository.findById(reviewId)).thenReturn(Optional.of(existingReview));
        when(vehicleReviewRepository.saveAndFlush(any(VehicleReview.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        ReviewDtos.ReviewDto result = reviewService.updateReviewById(userId, reviewId, updateRequest);

        assertThat(result.getRating()).isEqualTo(3);
        assertThat(result.getReviewText()).isEqualTo("Cập nhật lại qua ID: dịch vụ ổn nhưng xe hơi hao pin");
        verify(vehicleReviewRepository, times(1)).saveAndFlush(existingReview);
    }

    @Test
    @DisplayName("Cập nhật đánh giá qua reviewId thất bại khi người dùng khác sửa trộm")
    void testUpdateReviewById_Forbidden() {
        UUID reviewId = UUID.randomUUID();
        UUID attackerUserId = UUID.randomUUID();
        ReviewDtos.CreateReviewRequest updateRequest = ReviewDtos.CreateReviewRequest.builder()
                .rating(1)
                .reviewText("Sửa đánh giá của người khác")
                .build();

        VehicleReview existingReview = VehicleReview.builder()
                .id(reviewId)
                .user(testUser)
                .vehicle(testVehicle)
                .rating(5)
                .build();

        when(vehicleReviewRepository.findById(reviewId)).thenReturn(Optional.of(existingReview));

        assertThatThrownBy(() -> reviewService.updateReviewById(attackerUserId, reviewId, updateRequest))
                .isInstanceOf(ForbiddenException.class)
                .hasMessageContaining("Bạn không có quyền chỉnh sửa đánh giá của người dùng khác.");

        verify(vehicleReviewRepository, never()).saveAndFlush(any());
    }

    @Test
    @DisplayName("Tạo đánh giá mới thành công khi chưa có đánh giá trước đó")
    void testCreateReview_Success() {
        // Arrange
        ReviewDtos.CreateReviewRequest request = ReviewDtos.CreateReviewRequest.builder()
                .rating(5)
                .reviewText("Xe đi rất sướng, tiết kiệm điện năng")
                .build();

        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));
        when(vehicleRepository.findById(vehicleId)).thenReturn(Optional.of(testVehicle));
        when(bookingRepository.existsByUserIdAndVehicleIdAndStatus(userId, vehicleId, BookingStatus.COMPLETED))
                .thenReturn(true);
        when(vehicleReviewRepository.findByUserIdAndVehicleId(userId, vehicleId))
                .thenReturn(Optional.empty());
        when(vehicleReviewRepository.saveAndFlush(any(VehicleReview.class)))
                .thenAnswer(invocation -> {
                    VehicleReview r = invocation.getArgument(0);
                    r.setId(UUID.randomUUID());
                    r.setCreatedAt(OffsetDateTime.now());
                    r.setUpdatedAt(OffsetDateTime.now());
                    return r;
                });

        // Act
        ReviewDtos.ReviewDto result = reviewService.createOrUpdateReview(userId, vehicleId, request);

        // Assert
        assertThat(result).isNotNull();
        assertThat(result.getRating()).isEqualTo(5);
        assertThat(result.getReviewText()).isEqualTo("Xe đi rất sướng, tiết kiệm điện năng");
        verify(vehicleReviewRepository, times(1)).saveAndFlush(any(VehicleReview.class));
    }

    @Test
    @DisplayName("Cập nhật/tạo đánh giá thất bại khi chưa hoàn thành chuyến đi")
    void testCreateOrUpdateReview_NotCompletedRental_ThrowsBadRequest() {
        ReviewDtos.CreateReviewRequest request = ReviewDtos.CreateReviewRequest.builder()
                .rating(5)
                .reviewText("Xe rất đẹp nhưng tôi chưa từng hoàn tất chuyến đi")
                .build();

        when(userRepository.findById(userId)).thenReturn(Optional.of(testUser));
        when(vehicleRepository.findById(vehicleId)).thenReturn(Optional.of(testVehicle));
        when(bookingRepository.existsByUserIdAndVehicleIdAndStatus(userId, vehicleId, BookingStatus.COMPLETED))
                .thenReturn(false);

        assertThatThrownBy(() -> reviewService.createOrUpdateReview(userId, vehicleId, request))
                .isInstanceOf(BadRequestException.class)
                .hasMessageContaining("Bạn chỉ có thể đánh giá và nhận xét xe sau khi đã hoàn thành chuyến đi thuê xe này.");

        verify(vehicleReviewRepository, never()).save(any());
    }

    @Test
    @DisplayName("Xóa đánh giá thành công khi đúng chủ sở hữu")
    void testDeleteReview_Success() {
        UUID reviewId = UUID.randomUUID();
        VehicleReview review = VehicleReview.builder()
                .id(reviewId)
                .user(testUser)
                .vehicle(testVehicle)
                .rating(5)
                .reviewText("Đánh giá tốt")
                .build();

        when(vehicleReviewRepository.findById(reviewId)).thenReturn(Optional.of(review));

        reviewService.deleteReview(userId, reviewId);

        verify(vehicleReviewRepository, times(1)).delete(review);
    }

    @Test
    @DisplayName("Xóa đánh giá thất bại khi không phải chủ sở hữu")
    void testDeleteReview_Forbidden() {
        UUID reviewId = UUID.randomUUID();
        UUID otherUserId = UUID.randomUUID();
        VehicleReview review = VehicleReview.builder()
                .id(reviewId)
                .user(testUser) // belongs to testUser
                .vehicle(testVehicle)
                .rating(5)
                .build();

        when(vehicleReviewRepository.findById(reviewId)).thenReturn(Optional.of(review));

        assertThatThrownBy(() -> reviewService.deleteReview(otherUserId, reviewId))
                .isInstanceOf(ForbiddenException.class)
                .hasMessageContaining("Bạn không có quyền xóa đánh giá của người dùng khác.");

        verify(vehicleReviewRepository, never()).delete(any());
    }
}
