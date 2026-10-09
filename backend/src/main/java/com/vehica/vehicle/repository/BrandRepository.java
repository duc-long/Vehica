package com.vehica.vehicle.repository;

import com.vehica.vehicle.entity.Brand;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * ==============================================================================================
 * [BACKEND BRAND REPOSITORY]
 * - LINKED SCREENS   : S13 (Admin Brand Management), S03 (Home Brands), S03B (Catalog Filter)
 * - USE CASES        : UC-04 (Filter by Brand), UC-13 (Brand CRUD)
 * ==============================================================================================
 */
@Repository
public interface BrandRepository extends JpaRepository<Brand, UUID> {

    /**
     * Retrieves all brands sorted by display order and name (S03B Catalog Filter).
     */
    List<Brand> findAllByOrderByDisplayOrderAscNameAsc();

    /**
     * Retrieves popular featured brands for the homepage discovery section (S03 Home Carousel).
     */
    List<Brand> findAllByIsPopularTrueOrderByDisplayOrderAscNameAsc();

    /**
     * Finds a brand by name ignoring case (S13 Admin CRUD).
     */
    Optional<Brand> findByNameIgnoreCase(String name);

    /**
     * Checks if a brand with the given name already exists (BR-20).
     */
    boolean existsByNameIgnoreCase(String name);
}

