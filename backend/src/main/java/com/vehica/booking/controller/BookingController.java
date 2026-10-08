package com.vehica.booking.controller;

import com.vehica.booking.dto.BookingDtos;
import com.vehica.booking.service.BookingService;
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
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * ==============================================================================================
 * [BACKEND CUSTOMER BOOKING CONTROLLER]
 * - SERVICE LAYER    : BookingService
 * - LINKED SCREENS   : S05 (Create Booking & Review), S06 (My Bookings & Booking Detail)
 * - USE CASES        : UC-06 (Create Booking), UC-07 (Manage My Booking)
 * - BUSINESS RULES   : BR-08..BR-13 (Calculation & Snapshot), BR-14..BR-17 (Cancellation & Ownership)
 * ==============================================================================================
 */
@RestController
@RequestMapping("/api/v1/bookings")
@RequiredArgsConstructor
@Tag(name = "04. Customer Bookings", description = "Customer Booking APIs")
public class BookingController {

    private final BookingService bookingService;

    /**
     * Creates a new vehicle rental booking (S05 Create Booking, UC-06, BR-08..BR-13).
     */
    @PostMapping
    @Operation(summary = "Create new rental booking")
    public ResponseEntity<ApiResponse<BookingDtos.BookingDetailDto>> createBooking(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @Valid @RequestBody BookingDtos.CreateBookingRequest request) {

        BookingDtos.BookingDetailDto created = bookingService.createBooking(userPrincipal.getId(), request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Đặt xe thành công. Đơn hàng đang ở trạng thái PENDING.", created));
    }

    /**
     * Retrieves paginated booking history for the current authenticated user (S06 My Bookings, UC-07).
     */
    @GetMapping("/me")
    @Operation(summary = "Get list of bookings owned by the authenticated customer")
    public ResponseEntity<ApiResponse<PageResponse<BookingDtos.BookingSummaryDto>>> getMyBookings(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {

        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        PageResponse<BookingDtos.BookingSummaryDto> bookings = bookingService.getMyBookings(userPrincipal.getId(), pageable);
        return ResponseEntity.ok(ApiResponse.success(bookings));
    }

    /**
     * Retrieves full booking details with authorization check (S06 Booking Detail, UC-07, BR-17).
     */
    @GetMapping("/{id}")
    @Operation(summary = "Get detailed booking information")
    public ResponseEntity<ApiResponse<BookingDtos.BookingDetailDto>> getBookingDetail(
            @PathVariable UUID id,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {

        BookingDtos.BookingDetailDto detail = bookingService.getBookingDetail(id, userPrincipal.getId(), userPrincipal.getRole());
        return ResponseEntity.ok(ApiResponse.success(detail));
    }

    /**
     * Retrieves status change history and audit trail (S06 Timeline, UC-07, BR-21).
     */
    @GetMapping("/{id}/history")
    @Operation(summary = "Get booking status history timeline")
    public ResponseEntity<ApiResponse<List<BookingDtos.BookingStatusHistoryDto>>> getBookingHistory(
            @PathVariable UUID id,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {

        List<BookingDtos.BookingStatusHistoryDto> history = bookingService.getBookingHistory(id, userPrincipal.getId(), userPrincipal.getRole());
        return ResponseEntity.ok(ApiResponse.success(history));
    }

    /**
     * Cancels own booking if allowed by business rules (S06 Cancel Booking, UC-07, BR-14, BR-17).
     */
    @PatchMapping("/{id}/cancel")
    @Operation(summary = "Cancel own booking when allowed (PENDING/CONFIRMED)")
    public ResponseEntity<ApiResponse<BookingDtos.BookingDetailDto>> cancelBooking(
            @PathVariable UUID id,
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @RequestBody(required = false) Map<String, String> body) {

        String reason = body != null ? body.get("reason") : null;
        BookingDtos.BookingDetailDto cancelled = bookingService.cancelBooking(id, userPrincipal.getId(), reason);
        return ResponseEntity.ok(ApiResponse.success("Hủy đơn đặt xe thành công", cancelled));
    }
}
