package com.vehica.favorite.service;

import com.vehica.common.exception.ResourceNotFoundException;
import com.vehica.common.response.PageResponse;
import com.vehica.favorite.dto.FavoriteDtos;
import com.vehica.favorite.entity.FavoriteVehicle;
import com.vehica.favorite.repository.FavoriteVehicleRepository;
import com.vehica.user.entity.User;
import com.vehica.user.repository.UserRepository;
import com.vehica.vehicle.dto.VehicleDtos;
import com.vehica.vehicle.entity.Vehicle;
import com.vehica.vehicle.repository.VehicleRepository;
import com.vehica.vehicle.service.VehicleService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class FavoriteService {

    private final FavoriteVehicleRepository favoriteVehicleRepository;
    private final UserRepository userRepository;
    private final VehicleRepository vehicleRepository;
    private final VehicleService vehicleService;

    @Transactional
    public FavoriteDtos.FavoriteToggleResponse toggleFavorite(UUID userId, UUID vehicleId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy thông tin người dùng: " + userId));

        Vehicle vehicle = vehicleRepository.findById(vehicleId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy xe với ID: " + vehicleId));

        Optional<FavoriteVehicle> existing = favoriteVehicleRepository.findByUserIdAndVehicleId(userId, vehicleId);

        if (existing.isPresent()) {
            favoriteVehicleRepository.deleteByUserIdAndVehicleId(userId, vehicleId);
            log.info("User {} unfavorited vehicle {}", userId, vehicleId);
            return FavoriteDtos.FavoriteToggleResponse.builder()
                    .vehicleId(vehicleId)
                    .isFavorite(false)
                    .message("Đã bỏ xe khỏi danh sách yêu thích.")
                    .build();
        } else {
            FavoriteVehicle favorite = FavoriteVehicle.builder()
                    .user(user)
                    .vehicle(vehicle)
                    .build();
            favoriteVehicleRepository.save(favorite);
            log.info("User {} favorited vehicle {}", userId, vehicleId);
            return FavoriteDtos.FavoriteToggleResponse.builder()
                    .vehicleId(vehicleId)
                    .isFavorite(true)
                    .message("Đã thêm xe vào danh sách yêu thích.")
                    .build();
        }
    }

    @Transactional
    public void addFavorite(UUID userId, UUID vehicleId) {
        if (favoriteVehicleRepository.existsByUserIdAndVehicleId(userId, vehicleId)) {
            return;
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy thông tin người dùng: " + userId));

        Vehicle vehicle = vehicleRepository.findById(vehicleId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy xe với ID: " + vehicleId));

        FavoriteVehicle favorite = FavoriteVehicle.builder()
                .user(user)
                .vehicle(vehicle)
                .build();

        favoriteVehicleRepository.save(favorite);
        log.info("User {} added vehicle {} to favorites", userId, vehicleId);
    }

    @Transactional
    public void removeFavorite(UUID userId, UUID vehicleId) {
        favoriteVehicleRepository.deleteByUserIdAndVehicleId(userId, vehicleId);
        log.info("User {} removed vehicle {} from favorites", userId, vehicleId);
    }

    @Transactional(readOnly = true)
    public boolean isFavorite(UUID userId, UUID vehicleId) {
        return favoriteVehicleRepository.existsByUserIdAndVehicleId(userId, vehicleId);
    }

    @Transactional(readOnly = true)
    public PageResponse<VehicleDtos.VehicleDto> getMyFavoriteVehicles(UUID userId, Pageable pageable) {
        Page<Vehicle> vehiclePage = favoriteVehicleRepository.findFavoriteVehiclesByUserId(userId, pageable);
        Page<VehicleDtos.VehicleDto> dtoPage = vehiclePage.map(vehicleService::mapToDto);
        return PageResponse.from(dtoPage);
    }

    @Transactional(readOnly = true)
    public List<UUID> getMyFavoriteVehicleIds(UUID userId) {
        return favoriteVehicleRepository.findFavoriteVehicleIdsByUserId(userId);
    }
}
