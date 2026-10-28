package com.vehica.favorite.entity;

import com.vehica.common.util.UuidV7Utils;
import com.vehica.user.entity.User;
import com.vehica.vehicle.entity.Vehicle;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "favorite_vehicles", uniqueConstraints = {
        @UniqueConstraint(name = "uk_favorite_vehicles_user_vehicle", columnNames = {"user_id", "vehicle_id"})
})
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FavoriteVehicle {

    @Id
    private UUID id;

    @PrePersist
    public void ensureId() {
        if (this.id == null) {
            this.id = UuidV7Utils.generateUuidV7();
        }
    }

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vehicle_id", nullable = false)
    private Vehicle vehicle;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private OffsetDateTime createdAt;
}
