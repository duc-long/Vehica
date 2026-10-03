package com.vehica.vehicle.dto;

import com.vehica.common.enums.VehicleStatus;
import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

public class VehicleDtos {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class VehicleTypeDto {
        private UUID id;
        private String name;
        private String description;
        private String imageUrl;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class VehicleImageDto {
        private UUID id;
        private UUID vehicleId;
        private String imageUrl;
        private Boolean isPrimary;
        private OffsetDateTime createdAt;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class VehicleDto {
        private UUID id;
        private String name;
        private String brand;
        private String model;
        private String licensePlate;
        private Integer year;
        private Integer seatCapacity;
        private BigDecimal pricePerDay;
        private VehicleStatus status;
        private String primaryImageUrl;
        private VehicleTypeDto type;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class VehicleDetailDto {
        private UUID id;
        private String name;
        private String brand;
        private String model;
        private String licensePlate;
        private Integer year;
        private Integer seatCapacity;
        private BigDecimal pricePerDay;
        private VehicleStatus status;
        private String description;
        private VehicleTypeDto type;
        private List<VehicleImageDto> images;
        private OffsetDateTime createdAt;
        private OffsetDateTime updatedAt;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class VehicleRequest {
        @NotNull(message = "Loại xe không được để trống")
        private UUID typeId;

        @NotBlank(message = "Tên xe không được để trống")
        @Size(max = 150, message = "Tên xe tối đa 150 ký tự")
        private String name;

        @NotBlank(message = "Hãng xe không được để trống")
        @Size(max = 80, message = "Hãng xe tối đa 80 ký tự")
        private String brand;

        @NotBlank(message = "Dòng xe không được để trống")
        @Size(max = 80, message = "Dòng xe tối đa 80 ký tự")
        private String model;

        @NotBlank(message = "Biển số xe không được để trống")
        @Size(max = 20, message = "Biển số xe tối đa 20 ký tự")
        private String licensePlate;

        @NotNull(message = "Năm sản xuất không được để trống")
        @Min(value = 1900, message = "Năm sản xuất không hợp lệ")
        private Integer year;

        @Min(value = 2, message = "Số chỗ ngồi tối thiểu là 2 chỗ")
        @Max(value = 50, message = "Số chỗ ngồi tối đa là 50 chỗ")
        @Builder.Default
        private Integer seatCapacity = 5;

        @NotNull(message = "Giá thuê một ngày không được để trống")
        @DecimalMin(value = "0.01", message = "Giá thuê phải lớn hơn 0")
        private BigDecimal pricePerDay;

        @NotNull(message = "Trạng thái xe không được để trống")
        private VehicleStatus status;

        private String description;

        private String imageUrl;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UpdateStatusRequest {
        @NotNull(message = "Trạng thái xe không được để trống")
        private VehicleStatus status;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AddImageRequest {
        @NotBlank(message = "URL hình ảnh không được để trống")
        private String imageUrl;

        @Builder.Default
        private Boolean isPrimary = false;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AvailabilityResponse {
        private UUID vehicleId;
        private LocalDate startDate;
        private LocalDate endDate;
        private boolean isAvailable;
        private String reason;
        private BigDecimal pricePerDay;
        private long rentalDays;
        private BigDecimal estimatedTotalAmount;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class BrandDto {
        private UUID id;
        private String name;
        private String logoUrl;
        private String description;
        private String country;
        private Boolean isPopular;
        private Integer displayOrder;
        private long offerCount;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class BrandRequest {
        @NotBlank(message = "Tên hãng xe không được để trống")
        private String name;

        private String logoUrl;
        private String description;
        private String country;

        @Builder.Default
        private Boolean isPopular = true;

        @Builder.Default
        private Integer displayOrder = 0;
    }
}
