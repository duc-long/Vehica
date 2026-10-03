package com.vehica.statistics.dto;

import com.vehica.common.enums.BookingStatus;
import com.vehica.common.enums.VehicleStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public class StatisticsDtos {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DashboardSummaryResponse {
        private long totalUsers;
        private long activeUsers;
        private long totalVehicles;
        private Map<VehicleStatus, Long> vehiclesByStatus;
        private long totalBookings;
        private Map<BookingStatus, Long> bookingsByStatus;
        private BigDecimal totalEstimatedRevenue;
        private List<PopularVehicleDto> topVehicles;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RevenueStatisticResponse {
        private LocalDate startDate;
        private LocalDate endDate;
        private BigDecimal totalRevenue;
        private long totalCompletedBookings;
        private List<RevenuePointDto> points;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RevenuePointDto {
        private String period;
        private BigDecimal amount;
        private long bookingCount;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class PopularVehicleDto {
        private UUID vehicleId;
        private String name;
        private String brand;
        private String model;
        private long bookingCount;
        private BigDecimal totalRevenue;
        private String imageUrl;
    }
}
