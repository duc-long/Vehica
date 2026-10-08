// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - SPRING BOOT BACKEND
// ==============================================================================
// SERVICE LAYER           : BookingService
// USE CASES HANDLED       : UC-06 (Create Booking & Price Snapshot), UC-07 (View/Cancel My Bookings),
//                           UC-08 (Admin Booking Management, State Machine & Check-in/Return)
// BUSINESS RULES / BR     : BR-08 (Time slot granularity), BR-09 (Buffer time), BR-10 (Overlap check), BR-11 (Dynamic pricing),
//                           BR-12 (Deposit 30%), BR-14 (Cancellation fee), BR-16 (State Machine), BR-17 (Cancellation deadline),
//                           BR-18 (Admin override), BR-21 (Audit log booking_status_history)
// ==============================================================================

package com.vehica.booking.service;

import com.vehica.booking.dto.BookingDtos;
import com.vehica.booking.entity.Booking;
import com.vehica.booking.entity.BookingStatusHistory;
import com.vehica.booking.repository.BookingRepository;
import com.vehica.booking.repository.BookingStatusHistoryRepository;
import com.vehica.common.enums.BookingStatus;
import com.vehica.common.enums.UserRole;
import com.vehica.common.enums.VehicleStatus;
import com.vehica.common.exception.BadRequestException;
import com.vehica.common.exception.ConflictException;
import com.vehica.common.exception.ForbiddenException;
import com.vehica.common.exception.ResourceNotFoundException;
import com.vehica.common.response.PageResponse;
import com.vehica.user.entity.User;
import com.vehica.user.repository.UserRepository;
import com.vehica.user.service.UserService;
import com.vehica.vehicle.dto.VehicleDtos;
import com.vehica.vehicle.entity.Vehicle;
import com.vehica.vehicle.repository.VehicleRepository;
import com.vehica.vehicle.service.VehicleService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Random;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class BookingService {

    private final BookingRepository bookingRepository;
    private final BookingStatusHistoryRepository bookingStatusHistoryRepository;
    private final UserRepository userRepository;
    private final VehicleRepository vehicleRepository;
    private final UserService userService;
    private final VehicleService vehicleService;

    /**
     * Creates a new vehicle booking, checks conflict schedule (BR-10), and captures immutable price snapshot (BR-11) (UC-06).
     *
     * @param userId customer identifier
     * @param request booking details
     * @return detailed booking response
     */
    @Transactional
    public BookingDtos.BookingDetailDto createBooking(UUID userId, BookingDtos.CreateBookingRequest request) {
        if (!request.getStartDate().isBefore(request.getEndDate())) {
            throw new BadRequestException("Ngày trả xe phải sau ngày nhận xe.");
        }

        if (request.getStartDate().isBefore(LocalDate.now())) {
            throw new BadRequestException("Ngày nhận xe không thể ở trong quá khứ.");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy thông tin người dùng."));

        Vehicle vehicle = vehicleRepository.findById(request.getVehicleId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy xe với ID: " + request.getVehicleId()));

        if (vehicle.getStatus() != VehicleStatus.AVAILABLE) {
            throw new ConflictException("Xe hiện đang trong trạng thái " + vehicle.getStatus() + " và không thể đặt.");
        }

        // Final authoritative overlap check
        List<Booking> conflicts = bookingRepository.findConflictingBookings(
                request.getVehicleId(), request.getStartDate(), request.getEndDate());
        if (!conflicts.isEmpty()) {
            throw new ConflictException("Xe đã có lịch thuê trong khoảng thời gian này.");
        }

        long rentalDays = ChronoUnit.DAYS.between(request.getStartDate(), request.getEndDate());
        BigDecimal pricePerDaySnapshot = vehicle.getPricePerDay();
        BigDecimal totalAmountSnapshot = pricePerDaySnapshot.multiply(BigDecimal.valueOf(rentalDays));

        String bookingCode = generateBookingCode();

        Booking booking = Booking.builder()
                .bookingCode(bookingCode)
                .user(user)
                .vehicle(vehicle)
                .startDate(request.getStartDate())
                .endDate(request.getEndDate())
                .rentalDays((int) rentalDays)
                .pricePerDay(pricePerDaySnapshot)
                .totalAmount(totalAmountSnapshot)
                .status(BookingStatus.PENDING)
                .note(request.getNote())
                .build();

        Booking savedBooking = bookingRepository.save(booking);

        // Record initial status history
        BookingStatusHistory history = BookingStatusHistory.builder()
                .booking(savedBooking)
                .changedByUser(user)
                .fromStatus(null)
                .toStatus(BookingStatus.PENDING)
                .reason("Khách hàng tạo yêu cầu đặt xe.")
                .build();
        bookingStatusHistoryRepository.save(history);

        return getBookingDetail(savedBooking.getId(), userId, UserRole.USER);
    }

    /**
     * Retrieves paginated booking history for the authenticated customer (UC-07).
     *
     * @param userId customer identifier
     * @param pageable pagination parameters
     * @return paginated booking summary list
     */
    @Transactional(readOnly = true)
    public PageResponse<BookingDtos.BookingSummaryDto> getMyBookings(UUID userId, Pageable pageable) {
        Page<Booking> page = bookingRepository.findByUserId(userId, pageable);
        return PageResponse.from(page.map(this::mapToSummaryDto));
    }

    /**
     * Retrieves paginated bookings for administrators with multi-attribute filtering (UC-08).
     *
     * @param status optional booking status filter
     * @param vehicleId optional vehicle filter
     * @param userId optional customer filter
     * @param pageable pagination parameters
     * @return paginated admin booking summary list
     */
    @Transactional(readOnly = true)
    public PageResponse<BookingDtos.BookingSummaryDto> getAdminBookings(
            BookingStatus status, UUID vehicleId, UUID userId, Pageable pageable) {
        Page<Booking> page = bookingRepository.searchAdminBookings(status, vehicleId, userId, pageable);
        return PageResponse.from(page.map(this::mapToSummaryDto));
    }

    /**
     * Retrieves full booking details and audit timeline with role-based access validation (UC-07, UC-08).
     *
     * @param bookingId booking identifier
     * @param requesterId identifier of the requesting user
     * @param role user role (ADMIN or USER)
     * @return detailed booking data with audit status history
     */
    @Transactional(readOnly = true)
    public BookingDtos.BookingDetailDto getBookingDetail(UUID bookingId, UUID requesterId, UserRole role) {
        Booking booking = bookingRepository.findByIdWithDetails(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy đơn đặt xe với ID: " + bookingId));

        if (role != UserRole.ADMIN && !booking.getUser().getId().equals(requesterId)) {
            throw new ForbiddenException("Bạn không có quyền xem đơn đặt xe này.");
        }

        List<BookingStatusHistory> histories = bookingStatusHistoryRepository.findByBookingIdWithUser(bookingId);
        return mapToDetailDto(booking, histories);
    }

    /**
     * Retrieves immutable audit log history for a booking (BR-21, UC-07, UC-08).
     *
     * @param bookingId booking identifier
     * @param requesterId identifier of the requesting user
     * @param role user role
     * @return list of status history entries
     */
    @Transactional(readOnly = true)
    public List<BookingDtos.BookingStatusHistoryDto> getBookingHistory(UUID bookingId, UUID requesterId, UserRole role) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy đơn đặt xe với ID: " + bookingId));

        if (role != UserRole.ADMIN && !booking.getUser().getId().equals(requesterId)) {
            throw new ForbiddenException("Bạn không có quyền xem lịch sử đơn đặt xe này.");
        }

        return bookingStatusHistoryRepository.findByBookingIdWithUser(bookingId).stream()
                .map(this::mapToHistoryDto)
                .collect(Collectors.toList());
    }

    /**
     * Cancels a booking by the customer if in PENDING or CONFIRMED state (UC-07, BR-16, BR-17).
     *
     * @param bookingId booking identifier
     * @param userId customer identifier
     * @param reason cancellation reason
     * @return updated booking detail
     */
    @Transactional
    public BookingDtos.BookingDetailDto cancelBooking(UUID bookingId, UUID userId, String reason) {
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy đơn đặt xe với ID: " + bookingId));

        if (!booking.getUser().getId().equals(userId)) {
            throw new ForbiddenException("Bạn không có quyền hủy đơn đặt xe này.");
        }

        if (booking.getStatus() != BookingStatus.PENDING && booking.getStatus() != BookingStatus.CONFIRMED) {
            throw new ConflictException("Chỉ có thể hủy đơn khi ở trạng thái PENDING hoặc CONFIRMED.");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng."));

        BookingStatus fromStatus = booking.getStatus();
        booking.setStatus(BookingStatus.CANCELLED);
        Booking updated = bookingRepository.save(booking);

        BookingStatusHistory history = BookingStatusHistory.builder()
                .booking(updated)
                .changedByUser(user)
                .fromStatus(fromStatus)
                .toStatus(BookingStatus.CANCELLED)
                .reason(reason != null && !reason.isBlank() ? reason : "Khách hàng hủy đơn đặt xe.")
                .build();
        bookingStatusHistoryRepository.save(history);

        List<BookingStatusHistory> histories = bookingStatusHistoryRepository.findByBookingIdWithUser(bookingId);
        return mapToDetailDto(updated, histories);
    }

    /**
     * Updates booking status by administrator following state machine constraints (BR-16, UC-08).
     *
     * @param bookingId booking identifier
     * @param adminUserId administrator identifier
     * @param request status update request
     * @return updated booking detail
     */
    @Transactional
    public BookingDtos.BookingDetailDto updateBookingStatusByAdmin(
            UUID bookingId, UUID adminUserId, BookingDtos.UpdateBookingStatusRequest request) {

        Booking booking = bookingRepository.findByIdWithDetails(bookingId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy đơn đặt xe với ID: " + bookingId));

        BookingStatus currentStatus = booking.getStatus();
        BookingStatus targetStatus = request.getStatus();

        if (!currentStatus.canTransitionTo(targetStatus, UserRole.ADMIN)) {
            throw new ConflictException(
                    String.format("Không thể chuyển trạng thái từ %s sang %s.", currentStatus, targetStatus)
            );
        }

        User adminUser = userRepository.findById(adminUserId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy quản trị viên."));

        booking.setStatus(targetStatus);

        // Update vehicle state if PICKED_UP or COMPLETED
        if (targetStatus == BookingStatus.PICKED_UP) {
            booking.getVehicle().setStatus(VehicleStatus.RENTED);
            vehicleRepository.save(booking.getVehicle());
        } else if (targetStatus == BookingStatus.COMPLETED || targetStatus == BookingStatus.CANCELLED) {
            if (booking.getVehicle().getStatus() == VehicleStatus.RENTED) {
                booking.getVehicle().setStatus(VehicleStatus.AVAILABLE);
                vehicleRepository.save(booking.getVehicle());
            }
        }

        Booking updated = bookingRepository.save(booking);

        BookingStatusHistory history = BookingStatusHistory.builder()
                .booking(updated)
                .changedByUser(adminUser)
                .fromStatus(currentStatus)
                .toStatus(targetStatus)
                .reason(request.getReason())
                .build();
        bookingStatusHistoryRepository.save(history);

        List<BookingStatusHistory> histories = bookingStatusHistoryRepository.findByBookingIdWithUser(bookingId);
        return mapToDetailDto(updated, histories);
    }

    private String generateBookingCode() {
        String datePrefix = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String randomSuffix = String.format("%04d", new Random().nextInt(10000));
        return "VHC-" + datePrefix + "-" + randomSuffix;
    }

    private BookingDtos.BookingSummaryDto mapToSummaryDto(Booking booking) {
        String primaryImage = null;
        if (booking.getVehicle() != null && booking.getVehicle().getImages() != null && !booking.getVehicle().getImages().isEmpty()) {
            primaryImage = booking.getVehicle().getImages().get(0).getImageUrl();
        }

        return BookingDtos.BookingSummaryDto.builder()
                .id(booking.getId())
                .bookingCode(booking.getBookingCode())
                .customerName(booking.getUser() != null ? booking.getUser().getFullName() : null)
                .vehicleName(booking.getVehicle() != null ? booking.getVehicle().getName() : null)
                .vehicleBrand(booking.getVehicle() != null ? booking.getVehicle().getBrand() : null)
                .vehicleModel(booking.getVehicle() != null ? booking.getVehicle().getModel() : null)
                .vehicleImageUrl(primaryImage)
                .startDate(booking.getStartDate())
                .endDate(booking.getEndDate())
                .rentalDays(booking.getRentalDays())
                .pricePerDay(booking.getPricePerDay())
                .totalAmount(booking.getTotalAmount())
                .status(booking.getStatus())
                .createdAt(booking.getCreatedAt())
                .build();
    }

    private BookingDtos.BookingDetailDto mapToDetailDto(Booking booking, List<BookingStatusHistory> histories) {
        List<BookingDtos.BookingStatusHistoryDto> historyDtos = histories.stream()
                .map(this::mapToHistoryDto)
                .collect(Collectors.toList());

        return BookingDtos.BookingDetailDto.builder()
                .id(booking.getId())
                .bookingCode(booking.getBookingCode())
                .customer(booking.getUser() != null ? userService.mapToDto(booking.getUser()) : null)
                .vehicle(booking.getVehicle() != null ? vehicleService.mapToDto(booking.getVehicle()) : null)
                .startDate(booking.getStartDate())
                .endDate(booking.getEndDate())
                .rentalDays(booking.getRentalDays())
                .pricePerDay(booking.getPricePerDay())
                .totalAmount(booking.getTotalAmount())
                .status(booking.getStatus())
                .note(booking.getNote())
                .statusHistories(historyDtos)
                .createdAt(booking.getCreatedAt())
                .updatedAt(booking.getUpdatedAt())
                .build();
    }

    private BookingDtos.BookingStatusHistoryDto mapToHistoryDto(BookingStatusHistory history) {
        return BookingDtos.BookingStatusHistoryDto.builder()
                .id(history.getId())
                .fromStatus(history.getFromStatus())
                .toStatus(history.getToStatus())
                .reason(history.getReason())
                .changedByName(history.getChangedByUser() != null ? history.getChangedByUser().getFullName() : null)
                .changedAt(history.getChangedAt())
                .build();
    }
}
