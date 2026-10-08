package com.vehica.vehicle.repository;

import com.vehica.vehicle.entity.VehicleType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

/**
 * ==============================================================================================
 * [BACKEND VEHICLE TYPE REPOSITORY]
 * - LINKED SCREENS   : S03 (Home Super-App Service Hub), S03B (Catalog Type Filter)
 * - USE CASES        : UC-04 (Browse by Vehicle Type)
 * ==============================================================================================
 */
@Repository
public interface VehicleTypeRepository extends JpaRepository<VehicleType, UUID> {

    /**
     * Checks if a vehicle category with the given name exists.
     */
    boolean existsByName(String name);
}

