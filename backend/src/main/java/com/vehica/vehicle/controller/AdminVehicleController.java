package com.vehica.vehicle.controller;

import com.vehica.booking.entity.Booking;
import com.vehica.booking.repository.BookingRepository;
import com.vehica.common.response.ApiResponse;
import com.vehica.vehicle.dto.VehicleDtos;
import com.vehica.vehicle.service.VehicleService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * ==============================================================================================
 * [BACKEND ADMIN VEHICLE & FLEET CONTROLLER]
 * - SERVICE LAYER    : VehicleService, BookingRepository
 * - LINKED SCREENS   : S07 (Admin Vehicle Management), S08 (Fleet Availability), S13 (Brand Management)
 * - USE CASES        : UC-09 (Manage Vehicles), UC-12 (Fleet Availability), UC-13 (Manage Brands)
 * - BUSINESS RULES   : BR-04, BR-05 (AVAILABLE/RENTED/MAINTENANCE/INACTIVE), BR-19 (Logical Deletion)
 * ==============================================================================================
 */
@RestController
@RequestMapping("/api/v1/admin/vehicles")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
@Tag(name = "06. Admin Vehicles & Fleet", description = "Admin Vehicle Management & Fleet APIs")
public class AdminVehicleController {

    private final VehicleService vehicleService;
    private final BookingRepository bookingRepository;

    /**
     * Creates a new vehicle in the fleet (S07 Admin Vehicle Management, UC-09, BR-05).
     */
    @PostMapping
    @Operation(summary = "Create new vehicle in fleet")
    public ResponseEntity<ApiResponse<VehicleDtos.VehicleDetailDto>> createVehicle(
            @Valid @RequestBody VehicleDtos.VehicleRequest request) {
        VehicleDtos.VehicleDetailDto created = vehicleService.createVehicle(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Tạo thông tin xe thành công", created));
    }

    /**
     * Updates vehicle specifications and details (S07 Admin Vehicle Management, UC-09, BR-05).
     */
    @PutMapping("/{id}")
    @Operation(summary = "Update vehicle details")
    public ResponseEntity<ApiResponse<VehicleDtos.VehicleDetailDto>> updateVehicle(
            @PathVariable UUID id,
            @Valid @RequestBody VehicleDtos.VehicleRequest request) {
        VehicleDtos.VehicleDetailDto updated = vehicleService.updateVehicle(id, request);
        return ResponseEntity.ok(ApiResponse.success("Cập nhật thông tin xe thành công", updated));
    }

    /**
     * Updates vehicle operational status (AVAILABLE, RENTED, MAINTENANCE, INACTIVE) (S07 / S08, UC-09, BR-04).
     */
    @PatchMapping("/{id}/status")
    @Operation(summary = "Update vehicle operational status")
    public ResponseEntity<ApiResponse<VehicleDtos.VehicleDetailDto>> updateStatus(
            @PathVariable UUID id,
            @Valid @RequestBody VehicleDtos.UpdateStatusRequest request) {
        VehicleDtos.VehicleDetailDto updated = vehicleService.updateVehicleStatus(id, request.getStatus());
        return ResponseEntity.ok(ApiResponse.success("Cập nhật trạng thái xe thành công", updated));
    }

    /**
     * Deletes vehicle logically or permanently based on booking history (S07, UC-09, BR-19).
     */
    @DeleteMapping("/{id}")
    @Operation(summary = "Logically delete vehicle (mark INACTIVE)")
    public ResponseEntity<ApiResponse<Void>> deleteVehicle(@PathVariable UUID id) {
        vehicleService.deleteVehicle(id);
        return ResponseEntity.ok(ApiResponse.success("Xóa xe thành công (chuyển sang INACTIVE)", null));
    }

    /**
     * Retrieves fleet calendar schedule and active bookings for a vehicle over a date range (S08 Fleet Availability, UC-12).
     */
    @GetMapping("/{id}/schedule")
    @Operation(summary = "Get fleet schedule / bookings for a vehicle over a date range")
    public ResponseEntity<ApiResponse<List<BookingScheduleDto>>> getVehicleSchedule(
            @PathVariable UUID id,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {

        List<Booking> bookings = bookingRepository.findScheduleByVehicleAndDateRange(id, startDate, endDate);
        List<BookingScheduleDto> schedule = bookings.stream()
                .map(b -> new BookingScheduleDto(
                        b.getId(),
                        b.getBookingCode(),
                        b.getStartDate(),
                        b.getEndDate(),
                        b.getStatus().name(),
                        b.getUser().getFullName()
                ))
                .collect(Collectors.toList());

        return ResponseEntity.ok(ApiResponse.success(schedule));
    }

    public record BookingScheduleDto(
            UUID id,
            String bookingCode,
            LocalDate startDate,
            LocalDate endDate,
            String status,
            String customerName
    ) {}

    // ── Brand Management (Admin) ────────────────────────────────────────────────

    /**
     * Creates a new vehicle brand (S13 Admin Brand Management, UC-13).
     */
    @PostMapping("/brands")
    @Operation(summary = "Create a new vehicle brand")
    public ResponseEntity<ApiResponse<VehicleDtos.BrandDto>> createBrand(
            @Valid @RequestBody VehicleDtos.BrandRequest request) {
        VehicleDtos.BrandDto created = vehicleService.createBrand(request);
        return ResponseEntity.ok(ApiResponse.success("Tạo hãng xe thành công", created));
    }

    /**
     * Updates vehicle brand information (S13 Admin Brand Management, UC-13).
     */
    @PutMapping("/brands/{id}")
    @Operation(summary = "Update vehicle brand")
    public ResponseEntity<ApiResponse<VehicleDtos.BrandDto>> updateBrand(
            @PathVariable UUID id,
            @Valid @RequestBody VehicleDtos.BrandRequest request) {
        VehicleDtos.BrandDto updated = vehicleService.updateBrand(id, request);
        return ResponseEntity.ok(ApiResponse.success("Cập nhật hãng xe thành công", updated));
    }

    /**
     * Deletes vehicle brand with referential check (S13 Admin Brand Management, UC-13, BR-20).
     */
    @DeleteMapping("/brands/{id}")
    @Operation(summary = "Delete vehicle brand")
    public ResponseEntity<ApiResponse<Void>> deleteBrand(@PathVariable UUID id) {
        vehicleService.deleteBrand(id);
        return ResponseEntity.ok(ApiResponse.success("Xóa hãng xe thành công", null));
    }
}
