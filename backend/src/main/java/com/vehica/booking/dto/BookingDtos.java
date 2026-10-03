package com.vehica.booking.dto;

import com.vehica.common.enums.BookingStatus;
import com.vehica.user.dto.UserDto;
import com.vehica.vehicle.dto.VehicleDtos;
import jakarta.validation.constraints.FutureOrPresent;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

public class BookingDtos {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CreateBookingRequest {
        @NotNull(message = "Xe không được để trống")
        private UUID vehicleId;

        @NotNull(message = "Ngày bắt đầu thuê không được để trống")
        @FutureOrPresent(message = "Ngày bắt đầu không được ở trong quá khứ")
        private LocalDate startDate;

        @NotNull(message = "Ngày kết thúc thuê không được để trống")
        private LocalDate endDate;

        private String note;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UpdateBookingStatusRequest {
        @NotNull(message = "Trạng thái mới không được để trống")
        private BookingStatus status;

        private String reason;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class BookingStatusHistoryDto {
        private UUID id;
        private BookingStatus fromStatus;
        private BookingStatus toStatus;
        private String reason;
        private String changedByName;
        private OffsetDateTime changedAt;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class BookingSummaryDto {
        private UUID id;
        private String bookingCode;
        private BookingStatus status;
        private LocalDate startDate;
        private LocalDate endDate;
        private Integer rentalDays;
        private BigDecimal pricePerDay;
        private BigDecimal totalAmount;
        private String vehicleName;
        private String vehicleBrand;
        private String vehicleModel;
        private String vehicleImageUrl;
        private String customerName;
        private OffsetDateTime createdAt;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class BookingDetailDto {
        private UUID id;
        private String bookingCode;
        private BookingStatus status;
        private LocalDate startDate;
        private LocalDate endDate;
        private Integer rentalDays;
        private BigDecimal pricePerDay;
        private BigDecimal totalAmount;
        private String note;
        private UserDto customer;
        private VehicleDtos.VehicleDto vehicle;
        private List<BookingStatusHistoryDto> statusHistories;
        private OffsetDateTime createdAt;
        private OffsetDateTime updatedAt;
    }
}
