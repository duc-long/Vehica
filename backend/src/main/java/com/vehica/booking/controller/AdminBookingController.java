package com.vehica.booking.controller;

import com.vehica.booking.dto.BookingDtos;
import com.vehica.booking.service.BookingService;
import com.vehica.common.enums.BookingStatus;
import com.vehica.common.response.ApiResponse;
import com.vehica.common.response.PageResponse;
import com.vehica.security.UserPrincipal;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

/**
 * ==============================================================================================
 * [BACKEND ADMIN BOOKING MANAGEMENT CONTROLLER]
 * - SERVICE LAYER    : BookingService
 * - LINKED SCREENS   : S12 (Admin Booking Management)
 * - USE CASES        : UC-08 (Manage Booking)
 * - BUSINESS RULES   : BR-16 (Server State Transition Validation), BR-18 (Admin Read All), BR-21 (History)
 * ==============================================================================================
 */
@RestController
@RequestMapping("/api/v1/admin/bookings")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
@Tag(name = "05. Admin Bookings", description = "Admin Booking Management APIs")
public class AdminBookingController {

    private final BookingService bookingService;

    /**
     * Searches and filters all bookings in the system with pagination (S12 Admin Bookings, UC-08).
     */
    @GetMapping
    @Operation(summary = "Search and view all bookings as Admin")
    public ResponseEntity<ApiResponse<PageResponse<BookingDtos.BookingSummaryDto>>> getAdminBookings(
            @RequestParam(required = false) BookingStatus status,
            @RequestParam(required = false) UUID vehicleId,
            @RequestParam(required = false) UUID userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {

        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        PageResponse<BookingDtos.BookingSummaryDto> bookings = bookingService.getAdminBookings(status, vehicleId, userId, pageable);
        return ResponseEntity.ok(ApiResponse.success(bookings));
    }

    /**
     * Updates booking status according to the finite state machine (S12 Transition, UC-08, BR-16).
     */
    @PatchMapping("/{id}/status")
    @Operation(summary = "Update booking status according to state machine")
    public ResponseEntity<ApiResponse<BookingDtos.BookingDetailDto>> updateBookingStatus(
            @PathVariable UUID id,
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @Valid @RequestBody BookingDtos.UpdateBookingStatusRequest request) {

        BookingDtos.BookingDetailDto updated = bookingService.updateBookingStatusByAdmin(id, userPrincipal.getId(), request);
        return ResponseEntity.ok(ApiResponse.success("Cập nhật trạng thái đơn thành công: " + request.getStatus(), updated));
    }
}
