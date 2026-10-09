// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - SPRING BOOT BACKEND
// ==============================================================================
// SERVICE LAYER           : VehicleService
// USE CASES HANDLED       : UC-04 (Browse & Filter Vehicles), UC-05 (Vehicle Details), UC-09 (Admin Fleet CRUD), UC-13 (Admin Brand CRUD)
// BUSINESS RULES / BR     : BR-04 (Vehicle Status), BR-05 (Unique License Plate), BR-07, BR-19, BR-20 (Brand deletion constraint)
// ==============================================================================

package com.vehica.vehicle.service;

import com.vehica.booking.repository.BookingRepository;
import com.vehica.common.enums.VehicleStatus;
import com.vehica.common.exception.ConflictException;
import com.vehica.common.exception.ResourceNotFoundException;
import com.vehica.common.response.PageResponse;
import com.vehica.vehicle.dto.VehicleDtos;
import com.vehica.vehicle.entity.Brand;
import com.vehica.vehicle.entity.Vehicle;
import com.vehica.vehicle.entity.VehicleImage;
import com.vehica.vehicle.entity.VehicleType;
import com.vehica.vehicle.repository.BrandRepository;
import com.vehica.vehicle.repository.VehicleImageRepository;
import com.vehica.vehicle.repository.VehicleRepository;
import com.vehica.vehicle.repository.VehicleTypeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class VehicleService {

    private final VehicleRepository vehicleRepository;
    private final VehicleTypeRepository vehicleTypeRepository;
    private final VehicleImageRepository vehicleImageRepository;
    private final BrandRepository brandRepository;
    private final BookingRepository bookingRepository;

    // ==============================================================================
    // 1. VEHICLE CATALOG & DISCOVERY (UC-04, UC-05)
    // ==============================================================================

    /**
     * Searches and filters vehicle catalog with pagination (UC-04, BR-04).
     *
     * @param keyword search term for vehicle name, brand, or model
     * @param typeId vehicle category identifier
     * @param seatCapacity minimum number of seats
     * @param minPrice minimum daily rate
     * @param maxPrice maximum daily rate
     * @param status operational vehicle status
     * @param pageable pagination options
     * @return paginated vehicle listing
     */
    @Transactional(readOnly = true)
    public PageResponse<VehicleDtos.VehicleDto> searchVehicles(
            String keyword,
            UUID typeId,
            Integer seatCapacity,
            BigDecimal minPrice,
            BigDecimal maxPrice,
            VehicleStatus status,
            Pageable pageable) {

        Page<Vehicle> page = vehicleRepository.searchVehicles(
                keyword, typeId, seatCapacity, minPrice, maxPrice, status, pageable);

        return PageResponse.from(page.map(this::mapToDto));
    }

    /**
     * Retrieves vehicle specifications and associated image gallery (UC-05).
     *
     * @param id vehicle identifier
     * @return detailed vehicle information with gallery
     */
    @Transactional(readOnly = true)
    public VehicleDtos.VehicleDetailDto getVehicleDetail(UUID id) {
        Vehicle vehicle = vehicleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy xe với ID: " + id));

        List<VehicleImage> images = vehicleImageRepository.findByVehicleIdOrderByCreatedAtAsc(id);
        return mapToDetailDto(vehicle, images);
    }

    /**
     * Retrieves all available vehicle body types (UC-04).
     *
     * @return list of vehicle type definitions
     */
    @Transactional(readOnly = true)
    public List<VehicleDtos.VehicleTypeDto> getAllVehicleTypes() {
        return vehicleTypeRepository.findAll().stream()
                .map(t -> VehicleDtos.VehicleTypeDto.builder()
                        .id(t.getId())
                        .name(t.getName())
                        .description(t.getDescription())
                        .imageUrl(t.getImageUrl())
                        .build())
                .collect(Collectors.toList());
    }

    /**
     * Retrieves all brands ordered by display order (UC-04).
     *
     * @return list of car manufacturers/brands
     */
    @Transactional(readOnly = true)
    public List<VehicleDtos.BrandDto> getAllBrands() {
        return brandRepository.findAllByOrderByDisplayOrderAscNameAsc().stream()
                .map(this::mapToBrandDto)
                .collect(Collectors.toList());
    }

    /**
     * Retrieves popular featured brands for the homepage discovery carousel (UC-04).
     *
     * @return list of popular brand items
     */
    @Transactional(readOnly = true)
    public List<VehicleDtos.BrandDto> getPopularBrands() {
        return brandRepository.findAllByIsPopularTrueOrderByDisplayOrderAscNameAsc().stream()
                .map(this::mapToBrandDto)
                .collect(Collectors.toList());
    }

    // ==============================================================================
    // 2. FLEET & BRAND ADMINISTRATION (UC-09, UC-13)
    // ==============================================================================

    /**
     * Creates a new vehicle record with license plate uniqueness check (UC-09, BR-05).
     *
     * @param request vehicle creation attributes
     * @return created vehicle detailed DTO
     */
    @Transactional
    public VehicleDtos.VehicleDetailDto createVehicle(VehicleDtos.VehicleRequest request) {
        if (vehicleRepository.existsByLicensePlate(request.getLicensePlate())) {
            throw new ConflictException("Biển số xe đã tồn tại trong hệ thống: " + request.getLicensePlate());
        }

        VehicleType type = vehicleTypeRepository.findById(request.getTypeId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy loại xe với ID: " + request.getTypeId()));

        Vehicle vehicle = Vehicle.builder()
                .type(type)
                .name(request.getName().trim())
                .brand(request.getBrand().trim())
                .model(request.getModel().trim())
                .licensePlate(request.getLicensePlate().toUpperCase().trim())
                .year(request.getYear())
                .seatCapacity(request.getSeatCapacity() != null ? request.getSeatCapacity() : 5)
                .pricePerDay(request.getPricePerDay())
                .status(request.getStatus())
                .description(request.getDescription())
                .build();

        if (request.getFeatures() != null && !request.getFeatures().isEmpty()) {
            vehicle.getFeatures().addAll(request.getFeatures());
        }

        Vehicle saved = vehicleRepository.save(vehicle);

        List<VehicleImage> images = new ArrayList<>();
        if (request.getImageUrl() != null && !request.getImageUrl().isBlank()) {
            VehicleImage img = VehicleImage.builder()
                    .vehicle(saved)
                    .imageUrl(request.getImageUrl().trim())
                    .isPrimary(true)
                    .build();
            VehicleImage savedImg = vehicleImageRepository.save(img);
            images.add(savedImg);
        }

        return mapToDetailDto(saved, images);
    }

    /**
     * Updates vehicle specifications and primary thumbnail (UC-09, BR-05).
     *
     * @param id vehicle identifier
     * @param request update payload
     * @return updated vehicle detailed DTO
     */
    @Transactional
    public VehicleDtos.VehicleDetailDto updateVehicle(UUID id, VehicleDtos.VehicleRequest request) {
        Vehicle vehicle = vehicleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy xe với ID: " + id));

        if (vehicleRepository.existsByLicensePlateAndIdNot(request.getLicensePlate(), id)) {
            throw new ConflictException("Biển số xe đã được sử dụng bởi xe khác: " + request.getLicensePlate());
        }

        VehicleType type = vehicleTypeRepository.findById(request.getTypeId())
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy loại xe với ID: " + request.getTypeId()));

        vehicle.setType(type);
        vehicle.setName(request.getName().trim());
        vehicle.setBrand(request.getBrand().trim());
        vehicle.setModel(request.getModel().trim());
        vehicle.setLicensePlate(request.getLicensePlate().toUpperCase().trim());
        vehicle.setYear(request.getYear());
        vehicle.setSeatCapacity(request.getSeatCapacity() != null ? request.getSeatCapacity() : 5);
        vehicle.setPricePerDay(request.getPricePerDay());
        vehicle.setStatus(request.getStatus());
        vehicle.setDescription(request.getDescription());

        if (request.getFeatures() != null) {
            vehicle.getFeatures().clear();
            vehicle.getFeatures().addAll(request.getFeatures());
        }

        Vehicle updated = vehicleRepository.save(vehicle);

        if (request.getImageUrl() != null && !request.getImageUrl().isBlank()) {
            Optional<VehicleImage> primary = vehicleImageRepository.findFirstByVehicleIdAndIsPrimaryTrue(id);
            if (primary.isPresent()) {
                primary.get().setImageUrl(request.getImageUrl().trim());
                vehicleImageRepository.save(primary.get());
            } else {
                VehicleImage img = VehicleImage.builder()
                    .vehicle(updated)
                    .imageUrl(request.getImageUrl().trim())
                    .isPrimary(true)
                    .build();
                vehicleImageRepository.save(img);
            }
        }

        List<VehicleImage> images = vehicleImageRepository.findByVehicleIdOrderByCreatedAtAsc(id);
        return mapToDetailDto(updated, images);
    }

    /**
     * Updates operational status of a vehicle (AVAILABLE, RENTED, MAINTENANCE, INACTIVE) (UC-09, BR-04).
     *
     * @param id vehicle identifier
     * @param status new operational status
     * @return updated vehicle detailed DTO
     */
    @Transactional
    public VehicleDtos.VehicleDetailDto updateVehicleStatus(UUID id, VehicleStatus status) {
        Vehicle vehicle = vehicleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy xe với ID: " + id));

        vehicle.setStatus(status);
        Vehicle updated = vehicleRepository.save(vehicle);
        List<VehicleImage> images = vehicleImageRepository.findByVehicleIdOrderByCreatedAtAsc(id);
        return mapToDetailDto(updated, images);
    }

    /**
     * Deletes vehicle or marks INACTIVE if historical bookings exist (UC-09, BR-20).
     *
     * @param id vehicle identifier
     */
    @Transactional
    public void deleteVehicle(UUID id) {
        Vehicle vehicle = vehicleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy xe với ID: " + id));

        long bookingCount = bookingRepository.countByVehicleId(id);
        if (bookingCount > 0) {
            vehicle.setStatus(VehicleStatus.INACTIVE);
            vehicleRepository.save(vehicle);
        } else {
            vehicleImageRepository.deleteAll(vehicleImageRepository.findByVehicleIdOrderByCreatedAtAsc(id));
            vehicleRepository.delete(vehicle);
        }
    }

    /**
     * Creates a new brand/manufacturer entry (UC-13, BR-20).
     *
     * @param request brand properties
     * @return created brand DTO
     */
    @Transactional
    public VehicleDtos.BrandDto createBrand(VehicleDtos.BrandRequest request) {
        if (brandRepository.existsByNameIgnoreCase(request.getName().trim())) {
            throw new ConflictException("Hãng xe đã tồn tại trong hệ thống: " + request.getName());
        }

        Brand brand = Brand.builder()
                .name(request.getName().trim())
                .logoUrl(request.getLogoUrl())
                .description(request.getDescription())
                .country(request.getCountry())
                .isPopular(request.getIsPopular() != null ? request.getIsPopular() : true)
                .displayOrder(request.getDisplayOrder() != null ? request.getDisplayOrder() : 0)
                .build();

        return mapToBrandDto(brandRepository.save(brand));
    }

    /**
     * Updates an existing brand definition (UC-13, BR-20).
     *
     * @param id brand identifier
     * @param request updated brand payload
     * @return updated brand DTO
     */
    @Transactional
    public VehicleDtos.BrandDto updateBrand(UUID id, VehicleDtos.BrandRequest request) {
        Brand brand = brandRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy hãng xe với ID: " + id));

        if (!brand.getName().equalsIgnoreCase(request.getName().trim()) &&
                brandRepository.existsByNameIgnoreCase(request.getName().trim())) {
            throw new ConflictException("Hãng xe đã tồn tại trong hệ thống: " + request.getName());
        }

        brand.setName(request.getName().trim());
        brand.setLogoUrl(request.getLogoUrl());
        brand.setDescription(request.getDescription());
        brand.setCountry(request.getCountry());
        if (request.getIsPopular() != null) brand.setIsPopular(request.getIsPopular());
        if (request.getDisplayOrder() != null) brand.setDisplayOrder(request.getDisplayOrder());

        return mapToBrandDto(brandRepository.save(brand));
    }

    /**
     * Deletes brand with relational integrity check against active vehicle inventory (UC-13, BR-20).
     *
     * @param id brand identifier
     */
    @Transactional
    public void deleteBrand(UUID id) {
        Brand brand = brandRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy hãng xe với ID: " + id));

        long vehicleCount = vehicleRepository.countByBrandIgnoreCase(brand.getName());
        if (vehicleCount > 0) {
            throw new ConflictException("Không thể xóa hãng xe '" + brand.getName() + "' vì đang có " +
                    vehicleCount + " xe thuộc hãng này trong hệ thống. Vui lòng chuyển các xe sang hãng khác trước.");
        }

        brandRepository.delete(brand);
    }

    // ==============================================================================
    // 3. OBJECT MAPPING UTILITIES
    // ==============================================================================

    public VehicleDtos.VehicleDto mapToDto(Vehicle vehicle) {
        String primaryImage = null;
        if (vehicle.getImages() != null && !vehicle.getImages().isEmpty()) {
            primaryImage = vehicle.getImages().stream()
                    .filter(VehicleImage::getIsPrimary)
                    .findFirst()
                    .map(VehicleImage::getImageUrl)
                    .orElse(vehicle.getImages().get(0).getImageUrl());
        }

        return VehicleDtos.VehicleDto.builder()
                .id(vehicle.getId())
                .name(vehicle.getName())
                .brand(vehicle.getBrand())
                .model(vehicle.getModel())
                .licensePlate(vehicle.getLicensePlate())
                .year(vehicle.getYear())
                .seatCapacity(vehicle.getSeatCapacity())
                .pricePerDay(vehicle.getPricePerDay())
                .status(vehicle.getStatus())
                .primaryImageUrl(primaryImage)
                .type(vehicle.getType() != null ? VehicleDtos.VehicleTypeDto.builder()
                        .id(vehicle.getType().getId())
                        .name(vehicle.getType().getName())
                        .description(vehicle.getType().getDescription())
                        .imageUrl(vehicle.getType().getImageUrl())
                        .build() : null)
                .features(vehicle.getFeatures() != null ? new ArrayList<>(vehicle.getFeatures()) : Collections.emptyList())
                .build();
    }

    public VehicleDtos.VehicleDetailDto mapToDetailDto(Vehicle vehicle, List<VehicleImage> images) {
        List<VehicleDtos.VehicleImageDto> imageDtos = images.stream()
                .map(img -> VehicleDtos.VehicleImageDto.builder()
                        .id(img.getId())
                        .vehicleId(vehicle.getId())
                        .imageUrl(img.getImageUrl())
                        .isPrimary(img.getIsPrimary())
                        .createdAt(img.getCreatedAt())
                        .build())
                .collect(Collectors.toList());

        return VehicleDtos.VehicleDetailDto.builder()
                .id(vehicle.getId())
                .name(vehicle.getName())
                .brand(vehicle.getBrand())
                .model(vehicle.getModel())
                .licensePlate(vehicle.getLicensePlate())
                .year(vehicle.getYear())
                .seatCapacity(vehicle.getSeatCapacity())
                .pricePerDay(vehicle.getPricePerDay())
                .status(vehicle.getStatus())
                .description(vehicle.getDescription())
                .type(vehicle.getType() != null ? VehicleDtos.VehicleTypeDto.builder()
                        .id(vehicle.getType().getId())
                        .name(vehicle.getType().getName())
                        .description(vehicle.getType().getDescription())
                        .imageUrl(vehicle.getType().getImageUrl())
                        .build() : null)
                .images(imageDtos)
                .features(vehicle.getFeatures() != null ? new ArrayList<>(vehicle.getFeatures()) : Collections.emptyList())
                .createdAt(vehicle.getCreatedAt())
                .updatedAt(vehicle.getUpdatedAt())
                .build();
    }

    public VehicleDtos.BrandDto mapToBrandDto(Brand brand) {
        long availableOffers = vehicleRepository.countByBrandIgnoreCaseAndStatus(
                brand.getName(), VehicleStatus.AVAILABLE);

        return VehicleDtos.BrandDto.builder()
                .id(brand.getId())
                .name(brand.getName())
                .logoUrl(brand.getLogoUrl())
                .description(brand.getDescription())
                .country(brand.getCountry())
                .isPopular(brand.getIsPopular())
                .displayOrder(brand.getDisplayOrder())
                .offerCount(availableOffers)
                .build();
    }
}
