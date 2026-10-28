package com.vehica.favorite.controller;

import com.vehica.common.response.ApiResponse;
import com.vehica.common.response.PageResponse;
import com.vehica.favorite.dto.FavoriteDtos;
import com.vehica.favorite.service.FavoriteService;
import com.vehica.security.UserPrincipal;
import com.vehica.vehicle.dto.VehicleDtos;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/favorites")
@RequiredArgsConstructor
@Tag(name = "07. Favorite Vehicles", description = "Customer Favorite Vehicles APIs")
public class FavoriteController {

    private final FavoriteService favoriteService;

    @GetMapping
    @Operation(summary = "Get list of favorite vehicles for authenticated customer")
    public ResponseEntity<ApiResponse<PageResponse<VehicleDtos.VehicleDto>>> getMyFavorites(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {

        Pageable pageable = PageRequest.of(page, size);
        PageResponse<VehicleDtos.VehicleDto> response = favoriteService.getMyFavoriteVehicles(userPrincipal.getId(), pageable);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping("/ids")
    @Operation(summary = "Get list of all favorite vehicle IDs for quick cache and icon sync")
    public ResponseEntity<ApiResponse<FavoriteDtos.FavoriteIdsResponse>> getMyFavoriteIds(
            @AuthenticationPrincipal UserPrincipal userPrincipal) {

        List<UUID> ids = favoriteService.getMyFavoriteVehicleIds(userPrincipal.getId());
        return ResponseEntity.ok(ApiResponse.success(
                FavoriteDtos.FavoriteIdsResponse.builder()
                        .vehicleIds(ids)
                        .build()
        ));
    }

    @GetMapping("/{vehicleId}/check")
    @Operation(summary = "Check whether a vehicle is favorited by the authenticated customer")
    public ResponseEntity<ApiResponse<FavoriteDtos.FavoriteStatusResponse>> checkFavorite(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PathVariable UUID vehicleId) {

        boolean isFav = favoriteService.isFavorite(userPrincipal.getId(), vehicleId);
        return ResponseEntity.ok(ApiResponse.success(
                FavoriteDtos.FavoriteStatusResponse.builder()
                        .vehicleId(vehicleId)
                        .isFavorite(isFav)
                        .build()
        ));
    }

    @PostMapping("/{vehicleId}/toggle")
    @Operation(summary = "Toggle favorite status for a vehicle (add if not favorited, remove if already favorited)")
    public ResponseEntity<ApiResponse<FavoriteDtos.FavoriteToggleResponse>> toggleFavorite(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PathVariable UUID vehicleId) {

        FavoriteDtos.FavoriteToggleResponse response = favoriteService.toggleFavorite(userPrincipal.getId(), vehicleId);
        return ResponseEntity.ok(ApiResponse.success(response.getMessage(), response));
    }

    @PostMapping("/{vehicleId}")
    @Operation(summary = "Add a vehicle to favorites")
    public ResponseEntity<ApiResponse<Void>> addFavorite(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PathVariable UUID vehicleId) {

        favoriteService.addFavorite(userPrincipal.getId(), vehicleId);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Đã thêm xe vào danh sách yêu thích.", null));
    }

    @DeleteMapping("/{vehicleId}")
    @Operation(summary = "Remove a vehicle from favorites")
    public ResponseEntity<ApiResponse<Void>> removeFavorite(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @PathVariable UUID vehicleId) {

        favoriteService.removeFavorite(userPrincipal.getId(), vehicleId);
        return ResponseEntity.ok(ApiResponse.success("Đã gỡ xe khỏi danh sách yêu thích.", null));
    }
}
