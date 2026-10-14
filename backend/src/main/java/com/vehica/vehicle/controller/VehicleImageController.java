package com.vehica.vehicle.controller;

import com.vehica.common.exception.ResourceNotFoundException;
import com.vehica.common.response.ApiResponse;
import com.vehica.common.storage.dto.StorageDtos;
import com.vehica.common.storage.service.SupabaseStorageService;
import com.vehica.vehicle.dto.VehicleDtos;
import com.vehica.vehicle.entity.Vehicle;
import com.vehica.vehicle.entity.VehicleImage;
import com.vehica.vehicle.repository.VehicleImageRepository;
import com.vehica.vehicle.repository.VehicleRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * ==============================================================================================
 * [BACKEND VEHICLE IMAGE CONTROLLER]
 * - SERVICE LAYER    : SupabaseStorageService, VehicleImageRepository
 * - LINKED SCREENS   : S04 (Detail Gallery), S07 (Admin Vehicle Image Management)
 * - USE CASES        : UC-05 (Image Gallery), UC-09 (Upload CDN Images)
 * ==============================================================================================
 */
@RestController
@RequiredArgsConstructor
@Tag(name = "Vehicle Images", description = "Vehicle Image Upload and Management APIs")
public class VehicleImageController {

    private final VehicleImageRepository vehicleImageRepository;
    private final VehicleRepository vehicleRepository;
    private final SupabaseStorageService storageService;

    /**
     * Retrieves all gallery images for a given vehicle (S04 Detail Gallery, UC-05).
     */
    @GetMapping("/api/v1/vehicles/{id}/images")
    @Operation(summary = "Get all images for a vehicle")
    public ResponseEntity<ApiResponse<List<VehicleDtos.VehicleImageDto>>> getImages(@PathVariable UUID id) {
        List<VehicleImage> images = vehicleImageRepository.findByVehicleIdOrderByCreatedAtAsc(id);
        List<VehicleDtos.VehicleImageDto> dtos = images.stream()
                .map(img -> VehicleDtos.VehicleImageDto.builder()
                        .id(img.getId())
                        .vehicleId(id)
                        .imageUrl(img.getImageUrl())
                        .isPrimary(img.getIsPrimary())
                        .createdAt(img.getCreatedAt())
                        .build())
                .collect(Collectors.toList());

        return ResponseEntity.ok(ApiResponse.success(dtos));
    }

    /**
     * Adds image URL to a vehicle gallery as Admin (S07 Admin CRUD, UC-09).
     */
    @PostMapping("/api/v1/admin/vehicles/{id}/images")
    @PreAuthorize("hasRole('ADMIN')")
    @Transactional
    @Operation(summary = "Add image to vehicle via URL as Admin")
    public ResponseEntity<ApiResponse<VehicleDtos.VehicleImageDto>> addImage(
            @PathVariable UUID id,
            @Valid @RequestBody VehicleDtos.AddImageRequest request) {

        Vehicle vehicle = vehicleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy xe với ID: " + id));

        if (Boolean.TRUE.equals(request.getIsPrimary())) {
            List<VehicleImage> existing = vehicleImageRepository.findByVehicleIdOrderByCreatedAtAsc(id);
            existing.forEach(img -> img.setIsPrimary(false));
            vehicleImageRepository.saveAll(existing);
        }

        VehicleImage image = VehicleImage.builder()
                .vehicle(vehicle)
                .imageUrl(request.getImageUrl().trim())
                .isPrimary(Boolean.TRUE.equals(request.getIsPrimary()))
                .build();

        VehicleImage saved = vehicleImageRepository.save(image);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Thêm hình ảnh thành công", VehicleDtos.VehicleImageDto.builder()
                        .id(saved.getId())
                        .vehicleId(id)
                        .imageUrl(saved.getImageUrl())
                        .isPrimary(saved.getIsPrimary())
                        .createdAt(saved.getCreatedAt())
                        .build()));
    }

    /**
     * Uploads image file directly to Supabase CDN and attaches to vehicle (S07 Admin Upload, UC-09).
     */
    @PostMapping(value = "/api/v1/admin/vehicles/{id}/images/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasRole('ADMIN')")
    @Transactional
    @Operation(summary = "Upload image file directly to Supabase Storage and link to vehicle as Admin")
    public ResponseEntity<ApiResponse<VehicleDtos.VehicleImageDto>> uploadImage(
            @PathVariable UUID id,
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "isPrimary", defaultValue = "false") Boolean isPrimary) {

        Vehicle vehicle = vehicleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy xe với ID: " + id));

        // 1. Upload to Supabase Storage under folder 'vehicles/<id>'
        StorageDtos.FileUploadResponse uploadResult = storageService.uploadFile(file, "vehicles/" + id);

        // 2. If primary, reset other images
        if (Boolean.TRUE.equals(isPrimary)) {
            List<VehicleImage> existing = vehicleImageRepository.findByVehicleIdOrderByCreatedAtAsc(id);
            existing.forEach(img -> img.setIsPrimary(false));
            vehicleImageRepository.saveAll(existing);
        }

        // 3. Save into vehicle_images table
        VehicleImage image = VehicleImage.builder()
                .vehicle(vehicle)
                .imageUrl(uploadResult.getFileUrl())
                .isPrimary(Boolean.TRUE.equals(isPrimary))
                .build();

        VehicleImage saved = vehicleImageRepository.save(image);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Tải và lưu hình ảnh xe vào Supabase thành công", VehicleDtos.VehicleImageDto.builder()
                        .id(saved.getId())
                        .vehicleId(id)
                        .imageUrl(saved.getImageUrl())
                        .isPrimary(saved.getIsPrimary())
                        .createdAt(saved.getCreatedAt())
                        .build()));
    }

    /**
     * Deletes vehicle image by ID (S07 Admin, UC-09).
     */
    @DeleteMapping("/api/v1/admin/vehicles/{id}/images/{imageId}")
    @PreAuthorize("hasRole('ADMIN')")
    @Transactional
    @Operation(summary = "Delete vehicle image as Admin")
    public ResponseEntity<ApiResponse<Void>> deleteImage(
            @PathVariable UUID id,
            @PathVariable UUID imageId) {

        vehicleImageRepository.deleteByVehicleIdAndId(id, imageId);
        return ResponseEntity.ok(ApiResponse.success("Xóa hình ảnh thành công", null));
    }
}
