package com.vehica.booking.repository;

import com.vehica.common.enums.BookingStatus;
import com.vehica.booking.entity.Booking;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * ==============================================================================================
 * [BACKEND BOOKING REPOSITORY]
 * - LINKED SCREENS   : S05 (Create Booking), S06 (My Bookings), S12 (Admin Bookings), S10 (Admin KPIs)
 * - USE CASES        : UC-06 (Create Booking), UC-07 (Manage Booking), UC-08 (Admin Bookings), UC-11 (KPIs)
 * - BUSINESS RULES   : BR-08 (Date Overlap), BR-11 (Snapshot Pricing), BR-15 (Revenue), BR-22
 * ==============================================================================================
 */
@Repository
public interface BookingRepository extends JpaRepository<Booking, UUID> {

    /**
     * Finds booking by unique human-readable booking code.
     */
    Optional<Booking> findByBookingCode(String bookingCode);

    /**
     * Retrieves booking with eagerly fetched vehicle and customer details (S06, S12).
     */
    @Query("SELECT b FROM Booking b " +
           "LEFT JOIN FETCH b.vehicle v " +
           "LEFT JOIN FETCH b.user u " +
           "WHERE b.id = :id")
    Optional<Booking> findByIdWithDetails(@Param("id") UUID id);

    /**
     * Retrieves paginated bookings owned by a specific customer (S06 My Bookings).
     */
    @Query("SELECT b FROM Booking b WHERE b.user.id = :userId ORDER BY b.createdAt DESC")
    Page<Booking> findByUserId(@Param("userId") UUID userId, Pageable pageable);

    /**
     * Searches and paginates bookings for admin portal with multi-attribute filtering (S12).
     */
    @Query("SELECT b FROM Booking b WHERE " +
           "(:status IS NULL OR b.status = :status) AND " +
           "(:vehicleId IS NULL OR b.vehicle.id = :vehicleId) AND " +
           "(:userId IS NULL OR b.user.id = :userId) " +
           "ORDER BY b.createdAt DESC")
    Page<Booking> searchAdminBookings(
            @Param("status") BookingStatus status,
            @Param("vehicleId") UUID vehicleId,
            @Param("userId") UUID userId,
            Pageable pageable
    );

    /**
     * Finds overlapping bookings to prevent double-booking collisions (BR-09, BR-10).
     */
    @Query("SELECT b FROM Booking b WHERE " +
           "b.vehicle.id = :vehicleId AND " +
           "b.status IN ('PENDING', 'CONFIRMED', 'PICKED_UP') AND " +
           "b.startDate < :requestedEnd AND " +
           "b.endDate > :requestedStart")
    List<Booking> findConflictingBookings(
            @Param("vehicleId") UUID vehicleId,
            @Param("requestedStart") LocalDate requestedStart,
            @Param("requestedEnd") LocalDate requestedEnd
    );

    /**
     * Retrieves vehicle rental schedule for fleet management timeline views (S08).
     */
    @Query("SELECT b FROM Booking b WHERE " +
           "b.vehicle.id = :vehicleId AND " +
           "b.startDate <= :endDate AND " +
           "b.endDate >= :startDate " +
           "ORDER BY b.startDate ASC")
    List<Booking> findScheduleByVehicleAndDateRange(
            @Param("vehicleId") UUID vehicleId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate
    );

    /**
     * Counts bookings by current status.
     */
    long countByStatus(BookingStatus status);

    /**
     * Counts bookings associated with a vehicle.
     */
    long countByVehicleId(UUID vehicleId);

    /**
     * Counts bookings associated with a user.
     */
    long countByUserId(UUID userId);

    /**
     * Aggregates booking counts grouped by status for KPI analytics (S10).
     */
    @Query("SELECT b.status, COUNT(b) FROM Booking b GROUP BY b.status")
    List<Object[]> countBookingsByStatusGroup();

    /**
     * Computes total revenue within a specified date window (S10, BR-15).
     */
    @Query("SELECT COALESCE(SUM(b.totalAmount), 0) FROM Booking b WHERE " +
           "b.status IN ('CONFIRMED', 'PICKED_UP', 'COMPLETED') AND " +
           "(:startDate IS NULL OR b.startDate >= :startDate) AND " +
           "(:endDate IS NULL OR b.endDate <= :endDate)")
    BigDecimal calculateEstimatedRevenue(
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate
    );

    /**
     * Retrieves top vehicles ranked by booking frequency and revenue (S10).
     */
    @Query("SELECT b.vehicle.id, b.vehicle.name, b.vehicle.brand, b.vehicle.model, COUNT(b), COALESCE(SUM(b.totalAmount), 0) " +
           "FROM Booking b " +
           "WHERE b.status IN ('CONFIRMED', 'PICKED_UP', 'COMPLETED') " +
           "GROUP BY b.vehicle.id, b.vehicle.name, b.vehicle.brand, b.vehicle.model " +
           "ORDER BY COUNT(b) DESC")
    List<Object[]> findPopularVehicles(Pageable pageable);
}
