package com.vehica.booking.repository;

import com.vehica.booking.entity.BookingStatusHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

/**
 * ==============================================================================================
 * [BACKEND BOOKING STATUS HISTORY REPOSITORY]
 * - LINKED SCREENS   : S06 (Booking Detail Timeline), S12 (Admin Booking Audit)
 * - USE CASES        : UC-07 (View Timeline History), UC-08 (Audit Booking State Transitions)
 * - BUSINESS RULES   : BR-14, BR-21 (Immutable Status History Log)
 * ==============================================================================================
 */
@Repository
public interface BookingStatusHistoryRepository extends JpaRepository<BookingStatusHistory, UUID> {

    /**
     * Retrieves chronological status transition history with user attribution (S06, S12, BR-21).
     */
    @Query("SELECT h FROM BookingStatusHistory h " +
           "LEFT JOIN FETCH h.changedByUser " +
           "WHERE h.booking.id = :bookingId " +
           "ORDER BY h.changedAt ASC")
    List<BookingStatusHistory> findByBookingIdWithUser(@Param("bookingId") UUID bookingId);
}
