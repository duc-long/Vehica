package com.vehica.vehicle.repository;

import com.vehica.common.enums.VehicleStatus;
import com.vehica.vehicle.entity.Vehicle;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

/**
 * ==============================================================================================
 * [BACKEND VEHICLE REPOSITORY]
 * - LINKED SCREENS   : S03 (Home), S03B (Catalog), S04 (Detail), S07 (Admin Fleet), S10 (Admin KPIs)
 * - USE CASES        : UC-04 (Browse), UC-05 (Detail), UC-09 (Admin Vehicle CRUD), UC-11 (Dashboard KPIs)
 * - BUSINESS RULES   : BR-04 (AVAILABLE status), BR-05 (4 operational statuses)
 * ==============================================================================================
 */
@Repository
public interface VehicleRepository extends JpaRepository<Vehicle, UUID> {

    /**
     * Checks if a vehicle with the given license plate exists (BR-05).
     */
    boolean existsByLicensePlate(String licensePlate);

    /**
     * Checks if a vehicle with the given license plate exists excluding the specified ID (BR-05).
     */
    boolean existsByLicensePlateAndIdNot(String licensePlate, UUID id);

    /**
     * Retrieves vehicle and eager fetches vehicle category details (S04 Detail).
     */
    @Query("SELECT v FROM Vehicle v LEFT JOIN FETCH v.type WHERE v.id = :id")
    Vehicle findVehicleWithDetails(@Param("id") UUID id);

    /**
     * Searches, filters, and paginates vehicle records across multiple criteria (S03 Home, S03B Catalog).
     */
    @Query("SELECT v FROM Vehicle v WHERE " +
           "(:keyword IS NULL OR :keyword = '' OR " +
           "LOWER(v.name) LIKE LOWER(CONCAT('%', CAST(:keyword AS string), '%')) OR " +
           "LOWER(v.brand) LIKE LOWER(CONCAT('%', CAST(:keyword AS string), '%')) OR " +
           "LOWER(v.model) LIKE LOWER(CONCAT('%', CAST(:keyword AS string), '%'))) AND " +
           "(:typeId IS NULL OR v.type.id = :typeId) AND " +
           "(:seatCapacity IS NULL OR v.seatCapacity = :seatCapacity) AND " +
           "(:minPrice IS NULL OR v.pricePerDay >= :minPrice) AND " +
           "(:maxPrice IS NULL OR v.pricePerDay <= :maxPrice) AND " +
           "(:status IS NULL OR v.status = :status)")
    Page<Vehicle> searchVehicles(
            @Param("keyword") String keyword,
            @Param("typeId") UUID typeId,
            @Param("seatCapacity") Integer seatCapacity,
            @Param("minPrice") BigDecimal minPrice,
            @Param("maxPrice") BigDecimal maxPrice,
            @Param("status") VehicleStatus status,
            Pageable pageable
    );

    /**
     * Counts vehicles by operational status (AVAILABLE, RENTED, MAINTENANCE, INACTIVE).
     */
    long countByStatus(VehicleStatus status);

    /**
     * Counts available vehicles by brand for offer tags (S03 Brands Carousel).
     */
    long countByBrandIgnoreCaseAndStatus(String brand, VehicleStatus status);

    /**
     * Counts total vehicles of a specific brand before deletion (BR-20).
     */
    long countByBrandIgnoreCase(String brand);

    /**
     * Aggregates fleet counts grouped by status for admin KPI dashboard charts (S10, UC-11).
     */
    @Query("SELECT v.status, COUNT(v) FROM Vehicle v GROUP BY v.status")
    List<Object[]> countVehiclesByStatusGroup();
}
