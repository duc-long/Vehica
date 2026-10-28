package com.vehica.favorite.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.UUID;

public class FavoriteDtos {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class FavoriteToggleResponse {
        private UUID vehicleId;
        private boolean isFavorite;
        private String message;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class FavoriteStatusResponse {
        private UUID vehicleId;
        private boolean isFavorite;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class FavoriteIdsResponse {
        private List<UUID> vehicleIds;
    }
}
