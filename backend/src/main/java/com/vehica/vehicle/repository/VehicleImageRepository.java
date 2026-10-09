package com.vehica.vehicle.repository;

import com.vehica.vehicle.entity.VehicleImage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * ==============================================================================================
 * [BACKEND VEHICLE IMAGE REPOSITORY]
 * - LINKED SCREENS   : S04 (Detail Image Gallery), S07 (Admin Image Upload)
 * - USE CASES        : UC-05 (Image Gallery), UC-09 (Upload CDN Images)
 * ==============================================================================================
 */
@Repository
public interface VehicleImageRepository extends JpaRepository<VehicleImage, UUID> {

    /**
     * Retrieves all gallery images for a vehicle ordered by creation timestamp (S04 Gallery).
     */
    List<VehicleImage> findByVehicleIdOrderByCreatedAtAsc(UUID vehicleId);

    /**
     * Finds the primary thumbnail image for a vehicle.
     */
    Optional<VehicleImage> findFirstByVehicleIdAndIsPrimaryTrue(UUID vehicleId);

    /**
     * Deletes a specific vehicle image record (S07 Admin CRUD).
     */
    void deleteByVehicleIdAndId(UUID vehicleId, UUID id);
}

