// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - SPRING BOOT BACKEND
// ==============================================================================
// SERVICE LAYER           : VehicleAvailabilityService
// USE CASES HANDLED       : UC-05 (Check Vehicle Availability & Estimate Pricing)
// BUSINESS RULES / BR     : BR-04 (AVAILABLE status), BR-07 (Min/max rental days),
//                           BR-08 (Time slot granularity), BR-09 (Buffer time), BR-10 (Overlap check)
// ==============================================================================

package com.vehica.vehicle.service;

import com.vehica.booking.entity.Booking;
import com.vehica.booking.repository.BookingRepository;
import com.vehica.common.enums.VehicleStatus;
import com.vehica.common.exception.BadRequestException;
import com.vehica.common.exception.ResourceNotFoundException;
import com.vehica.vehicle.dto.VehicleDtos;
import com.vehica.vehicle.entity.Vehicle;
import com.vehica.vehicle.repository.VehicleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class VehicleAvailabilityService {

    private final VehicleRepository vehicleRepository;
    private final BookingRepository bookingRepository;

    /**
     * Verifies real-time vehicle booking availability and calculates estimated rental total (UC-05, BR-04, BR-10).
     *
     * @param vehicleId unique vehicle identifier
     * @param startDate start of rental period
     * @param endDate end of rental period
     * @return availability status and calculated financial estimates
     */
    @Transactional(readOnly = true)
    public VehicleDtos.AvailabilityResponse checkAvailability(UUID vehicleId, LocalDate startDate, LocalDate endDate) {
        if (startDate == null || endDate == null) {
            throw new BadRequestException("Ngày bắt đầu và ngày kết thúc không được để trống.");
        }

        if (!startDate.isBefore(endDate)) {
            throw new BadRequestException("Ngày trả xe phải sau ngày nhận xe.");
        }

        if (startDate.isBefore(LocalDate.now())) {
            throw new BadRequestException("Ngày nhận xe không thể ở trong quá khứ.");
        }

        Vehicle vehicle = vehicleRepository.findById(vehicleId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy xe với ID: " + vehicleId));

        long rentalDays = ChronoUnit.DAYS.between(startDate, endDate);
        BigDecimal estimatedTotal = vehicle.getPricePerDay().multiply(BigDecimal.valueOf(rentalDays));

        // Rule BR-04: Operational status check
        if (vehicle.getStatus() != VehicleStatus.AVAILABLE) {
            return VehicleDtos.AvailabilityResponse.builder()
                    .vehicleId(vehicleId)
                    .startDate(startDate)
                    .endDate(endDate)
                    .isAvailable(false)
                    .reason("Xe hiện đang trong trạng thái " + vehicle.getStatus() + " và không thể đặt.")
                    .pricePerDay(vehicle.getPricePerDay())
                    .rentalDays(rentalDays)
                    .estimatedTotalAmount(estimatedTotal)
                    .build();
        }

        // Rule BR-09 & BR-10: Booking overlap check
        List<Booking> conflicts = bookingRepository.findConflictingBookings(vehicleId, startDate, endDate);
        if (!conflicts.isEmpty()) {
            return VehicleDtos.AvailabilityResponse.builder()
                    .vehicleId(vehicleId)
                    .startDate(startDate)
                    .endDate(endDate)
                    .isAvailable(false)
                    .reason("Xe đã có lịch thuê trong khoảng thời gian này.")
                    .pricePerDay(vehicle.getPricePerDay())
                    .rentalDays(rentalDays)
                    .estimatedTotalAmount(estimatedTotal)
                    .build();
        }

        return VehicleDtos.AvailabilityResponse.builder()
                .vehicleId(vehicleId)
                .startDate(startDate)
                .endDate(endDate)
                .isAvailable(true)
                .reason("Xe có sẵn trong khoảng thời gian đã chọn.")
                .pricePerDay(vehicle.getPricePerDay())
                .rentalDays(rentalDays)
                .estimatedTotalAmount(estimatedTotal)
                .build();
    }
}
