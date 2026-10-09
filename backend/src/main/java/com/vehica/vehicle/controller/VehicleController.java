package com.vehica.vehicle.controller;

import com.vehica.common.enums.VehicleStatus;
import com.vehica.common.response.ApiResponse;
import com.vehica.common.response.PageResponse;
import com.vehica.vehicle.dto.VehicleDtos;
import com.vehica.vehicle.service.VehicleAvailabilityService;
import com.vehica.vehicle.service.VehicleService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

/**
 * ==============================================================================================
 * [BACKEND VEHICLE PUBLIC CONTROLLER]
 * - SERVICE LAYER    : VehicleService, VehicleAvailabilityService
 * - LINKED SCREENS   : S03 (Home & Vehicle Search), S03B (Catalog), S04 (Vehicle Detail & Availability)
 * - USE CASES        : UC-04 (Browse Vehicles), UC-05 (View Vehicle Detail & Availability)
 * - BUSINESS RULES   : BR-04 (AVAILABLE Required), BR-07 & BR-08 (Date Ranges), BR-09 & BR-10 (Overlap)
 * ==============================================================================================
 */
@RestController
@RequestMapping("/api/v1/vehicles")
@RequiredArgsConstructor
@Tag(name = "03. Vehicles Catalog", description = "Public vehicle browse, search, detail, and availability APIs")
public class VehicleController {

    private final VehicleService vehicleService;
    private final VehicleAvailabilityService vehicleAvailabilityService;

    /**
     * Searches, filters, and paginates vehicle catalog (S03 Home, S03B Catalog, UC-04).
     */
    @GetMapping
    @Operation(summary = "Search and filter vehicles with pagination")
    public ResponseEntity<ApiResponse<PageResponse<VehicleDtos.VehicleDto>>> getVehicles(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) UUID typeId,
            @RequestParam(required = false) Integer seatCapacity,
            @RequestParam(required = false) BigDecimal minPrice,
            @RequestParam(required = false) BigDecimal maxPrice,
            @RequestParam(required = false) VehicleStatus status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String direction) {

        Sort sort = direction.equalsIgnoreCase("asc") ? Sort.by(sortBy).ascending() : Sort.by(sortBy).descending();
        Pageable pageable = PageRequest.of(page, size, sort);

        PageResponse<VehicleDtos.VehicleDto> result = vehicleService.searchVehicles(
                keyword, typeId, seatCapacity, minPrice, maxPrice, status, pageable);

        return ResponseEntity.ok(ApiResponse.success(result));
    }

    /**
     * Retrieves detailed vehicle specifications and media gallery (S04 Vehicle Detail, UC-05).
     */
    @GetMapping("/{id}")
    @Operation(summary = "Get vehicle details by ID")
    public ResponseEntity<ApiResponse<VehicleDtos.VehicleDetailDto>> getVehicleDetail(@PathVariable UUID id) {
        VehicleDtos.VehicleDetailDto detail = vehicleService.getVehicleDetail(id);
        return ResponseEntity.ok(ApiResponse.success(detail));
    }

    /**
     * Checks real-time booking availability and computes estimated rental cost (S04 Detail, UC-05, BR-04, BR-10).
     */
    @GetMapping("/{id}/availability")
    @Operation(summary = "Check vehicle booking availability for date range")
    public ResponseEntity<ApiResponse<VehicleDtos.AvailabilityResponse>> checkAvailability(
            @PathVariable UUID id,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {

        VehicleDtos.AvailabilityResponse availability = vehicleAvailabilityService.checkAvailability(id, startDate, endDate);
        return ResponseEntity.ok(ApiResponse.success(availability));
    }

    /**
     * Retrieves all vehicle body type categories (S03 Home, UC-04).
     */
    @GetMapping("/types")
    @Operation(summary = "Get all vehicle types")
    public ResponseEntity<ApiResponse<List<VehicleDtos.VehicleTypeDto>>> getVehicleTypes() {
        return ResponseEntity.ok(ApiResponse.success(vehicleService.getAllVehicleTypes()));
    }

    /**
     * Retrieves all vehicle brands (S03 Home, S03B Catalog, UC-04).
     */
    @GetMapping("/brands")
    @Operation(summary = "Get all vehicle brands with offer count")
    public ResponseEntity<ApiResponse<List<VehicleDtos.BrandDto>>> getBrands() {
        return ResponseEntity.ok(ApiResponse.success(vehicleService.getAllBrands()));
    }

    /**
     * Retrieves popular featured brands for the home discovery section (S03 Home, UC-04).
     */
    @GetMapping("/brands/popular")
    @Operation(summary = "Get popular vehicle brands for home screen")
    public ResponseEntity<ApiResponse<List<VehicleDtos.BrandDto>>> getPopularBrands() {
        return ResponseEntity.ok(ApiResponse.success(vehicleService.getPopularBrands()));
    }
}
