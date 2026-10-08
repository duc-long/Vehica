package com.vehica.statistics.controller;

import com.vehica.common.response.ApiResponse;
import com.vehica.statistics.dto.StatisticsDtos;
import com.vehica.statistics.service.StatisticsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

/**
 * ==============================================================================================
 * [BACKEND ADMIN STATISTICS & DASHBOARD CONTROLLER]
 * - SERVICE LAYER    : StatisticsService
 * - LINKED SCREENS   : S10 (Admin Dashboard & Statistics)
 * - USE CASES        : UC-11 (View Dashboard)
 * - BUSINESS RULES   : BR-22 (Estimated Revenue Snapshot), FR-STA-01..06 (KPI Aggregation)
 * ==============================================================================================
 */
@RestController
@RequestMapping("/api/v1/admin/statistics")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
@Tag(name = "08. Admin Statistics", description = "Admin Dashboard and Business Intelligence APIs")
public class AdminStatisticsController {

    private final StatisticsService statisticsService;

    /**
     * Retrieves overall operational dashboard KPIs and status metrics (S10 Admin Dashboard, UC-11).
     */
    @GetMapping("/summary")
    @Operation(summary = "Get overall dashboard KPIs and status metrics")
    public ResponseEntity<ApiResponse<StatisticsDtos.DashboardSummaryResponse>> getDashboardSummary() {
        StatisticsDtos.DashboardSummaryResponse summary = statisticsService.getDashboardSummary();
        return ResponseEntity.ok(ApiResponse.success(summary));
    }

    /**
     * Retrieves estimated revenue statistics by date range (S10 Revenue, UC-11, BR-22).
     */
    @GetMapping("/revenue")
    @Operation(summary = "Get estimated revenue statistics by date range")
    public ResponseEntity<ApiResponse<StatisticsDtos.RevenueStatisticResponse>> getRevenue(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {

        StatisticsDtos.RevenueStatisticResponse response = statisticsService.getRevenueStatistics(startDate, endDate);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    /**
     * Retrieves most booked vehicles leaderboard (S10 Top Vehicles, UC-11).
     */
    @GetMapping("/popular-vehicles")
    @Operation(summary = "Get most booked vehicles")
    public ResponseEntity<ApiResponse<List<StatisticsDtos.PopularVehicleDto>>> getPopularVehicles(
            @RequestParam(defaultValue = "5") int limit) {

        List<StatisticsDtos.PopularVehicleDto> popular = statisticsService.getPopularVehicles(limit);
        return ResponseEntity.ok(ApiResponse.success(popular));
    }
}
