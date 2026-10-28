package com.vehica.review.repository;

import com.vehica.review.entity.VehicleReview;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface VehicleReviewRepository extends JpaRepository<VehicleReview, UUID> {

    Page<VehicleReview> findByVehicleIdOrderByCreatedAtDesc(UUID vehicleId, Pageable pageable);

    Optional<VehicleReview> findByUserIdAndVehicleId(UUID userId, UUID vehicleId);

    boolean existsByUserIdAndVehicleId(UUID userId, UUID vehicleId);

    @Query("SELECT AVG(r.rating) FROM VehicleReview r WHERE r.vehicle.id = :vehicleId")
    Double getAverageRatingByVehicleId(@Param("vehicleId") UUID vehicleId);

    @Query("SELECT COUNT(r) FROM VehicleReview r WHERE r.vehicle.id = :vehicleId")
    Long countReviewsByVehicleId(@Param("vehicleId") UUID vehicleId);

    @Query("SELECT r.rating, COUNT(r) FROM VehicleReview r WHERE r.vehicle.id = :vehicleId GROUP BY r.rating")
    List<Object[]> countRatingsGroupedByStars(@Param("vehicleId") UUID vehicleId);
}
