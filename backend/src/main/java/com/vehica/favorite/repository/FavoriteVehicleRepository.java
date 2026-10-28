package com.vehica.favorite.repository;

import com.vehica.favorite.entity.FavoriteVehicle;
import com.vehica.vehicle.entity.Vehicle;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface FavoriteVehicleRepository extends JpaRepository<FavoriteVehicle, UUID> {

    boolean existsByUserIdAndVehicleId(UUID userId, UUID vehicleId);

    Optional<FavoriteVehicle> findByUserIdAndVehicleId(UUID userId, UUID vehicleId);

    @Modifying
    @Query("DELETE FROM FavoriteVehicle f WHERE f.user.id = :userId AND f.vehicle.id = :vehicleId")
    void deleteByUserIdAndVehicleId(@Param("userId") UUID userId, @Param("vehicleId") UUID vehicleId);

    @Query("SELECT f.vehicle FROM FavoriteVehicle f WHERE f.user.id = :userId ORDER BY f.createdAt DESC")
    Page<Vehicle> findFavoriteVehiclesByUserId(@Param("userId") UUID userId, Pageable pageable);

    @Query("SELECT f.vehicle.id FROM FavoriteVehicle f WHERE f.user.id = :userId")
    List<UUID> findFavoriteVehicleIdsByUserId(@Param("userId") UUID userId);
}
