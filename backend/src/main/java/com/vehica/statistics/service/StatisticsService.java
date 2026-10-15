// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - SPRING BOOT BACKEND
// ==============================================================================
// SERVICE LAYER           : StatisticsService
// USE CASES HANDLED       : UC-11 (Revenue Reporting & Admin KPI Analytics Dashboard)
// BUSINESS RULES / BR     : BR-22 (Timezone UTC+7, Revenue calculation, vehicle utilization),
//                           FR-STA-01..06
// ==============================================================================

package com.vehica.statistics.service;

import com.vehica.booking.repository.BookingRepository;
import com.vehica.common.enums.BookingStatus;
import com.vehica.common.enums.UserStatus;
import com.vehica.common.enums.VehicleStatus;
import com.vehica.statistics.dto.StatisticsDtos;
import com.vehica.user.repository.UserRepository;
import com.vehica.vehicle.repository.VehicleImageRepository;
import com.vehica.vehicle.repository.VehicleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;

@Service
@RequiredArgsConstructor
public class StatisticsService {

    private final UserRepository userRepository;
    private final VehicleRepository vehicleRepository;
    private final BookingRepository bookingRepository;
    private final VehicleImageRepository vehicleImageRepository;

    /**
     * Aggregates comprehensive KPI metrics for the Admin Dashboard (Users, Vehicles, Bookings, Revenue, Top Vehicles) (UC-11).
     *
     * @return consolidated dashboard summary metrics
     */
    @Transactional(readOnly = true)
    public StatisticsDtos.DashboardSummaryResponse getDashboardSummary() {
        long totalUsers = userRepository.count();
        long activeUsers = userRepository.countByStatus(UserStatus.ACTIVE);

        long totalVehicles = vehicleRepository != null ? vehicleRepository.count() : 0;
        Map<VehicleStatus, Long> vehiclesByStatus = new EnumMap<>(VehicleStatus.class);
        for (VehicleStatus status : VehicleStatus.values()) {
            vehiclesByStatus.put(status, 0L);
        }
        if (vehicleRepository != null) {
            for (Object[] row : vehicleRepository.countVehiclesByStatusGroup()) {
                VehicleStatus status = (VehicleStatus) row[0];
                Long count = (Long) row[1];
                vehiclesByStatus.put(status, count);
            }
        }

        long totalBookings = bookingRepository.count();
        Map<BookingStatus, Long> bookingsByStatus = new EnumMap<>(BookingStatus.class);
        for (BookingStatus status : BookingStatus.values()) {
            bookingsByStatus.put(status, 0L);
        }
        for (Object[] row : bookingRepository.countBookingsByStatusGroup()) {
            BookingStatus status = (BookingStatus) row[0];
            Long count = (Long) row[1];
            bookingsByStatus.put(status, count);
        }

        BigDecimal totalEstimatedRevenue = bookingRepository.calculateEstimatedRevenue(null, null);

        List<StatisticsDtos.PopularVehicleDto> topVehicles = getPopularVehicles(5);

        return StatisticsDtos.DashboardSummaryResponse.builder()
                .totalUsers(totalUsers)
                .activeUsers(activeUsers)
                .totalVehicles(totalVehicles)
                .vehiclesByStatus(vehiclesByStatus)
                .totalBookings(totalBookings)
                .bookingsByStatus(bookingsByStatus)
                .totalEstimatedRevenue(totalEstimatedRevenue != null ? totalEstimatedRevenue : BigDecimal.ZERO)
                .topVehicles(topVehicles)
                .build();
    }

    /**
     * Calculates revenue statistics within a date range (UC-11, BR-22).
     *
     * @param startDate start of range
     * @param endDate end of range
     * @return revenue metrics and completed booking tallies
     */
    @Transactional(readOnly = true)
    public StatisticsDtos.RevenueStatisticResponse getRevenueStatistics(LocalDate startDate, LocalDate endDate) {
        BigDecimal total = bookingRepository.calculateEstimatedRevenue(startDate, endDate);

        return StatisticsDtos.RevenueStatisticResponse.builder()
                .startDate(startDate)
                .endDate(endDate)
                .totalRevenue(total != null ? total : BigDecimal.ZERO)
                .totalCompletedBookings(bookingRepository.countByStatus(BookingStatus.COMPLETED))
                .points(Collections.emptyList())
                .build();
    }

    /**
     * Retrieves top performing vehicles ranked by booking frequency and total revenue (UC-11).
     *
     * @param limit maximum number of items to return
     * @return list of top performing vehicles
     */
    @Transactional(readOnly = true)
    public List<StatisticsDtos.PopularVehicleDto> getPopularVehicles(int limit) {
        List<Object[]> rows = bookingRepository.findPopularVehicles(PageRequest.of(0, limit));
        List<StatisticsDtos.PopularVehicleDto> result = new ArrayList<>();

        for (Object[] row : rows) {
            UUID vehicleId = (UUID) row[0];
            String primaryImageUrl = vehicleImageRepository != null
                    ? vehicleImageRepository.findFirstByVehicleIdAndIsPrimaryTrue(vehicleId)
                            .map(com.vehica.vehicle.entity.VehicleImage::getImageUrl)
                            .orElse(null)
                    : null;

            result.add(StatisticsDtos.PopularVehicleDto.builder()
                    .vehicleId(vehicleId)
                    .name((String) row[1])
                    .brand((String) row[2])
                    .model((String) row[3])
                    .bookingCount((Long) row[4])
                    .totalRevenue((BigDecimal) row[5])
                    .imageUrl(primaryImageUrl)
                    .build());
        }

        return result;
    }
}
