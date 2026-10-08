// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - SPRING BOOT BACKEND
// ==============================================================================
// SERVICE LAYER           : UserService
// USE CASES HANDLED       : UC-03 (User Profile), UC-10 (Admin User Management)
// BUSINESS RULES / BR     : BR-01 (Email/Phone format), BR-03 (User Status), BR-20 (Account soft delete & integrity)
// ==============================================================================

package com.vehica.user.service;

import com.vehica.booking.repository.BookingRepository;
import com.vehica.common.enums.UserStatus;
import com.vehica.common.exception.ConflictException;
import com.vehica.common.exception.ResourceNotFoundException;
import com.vehica.common.response.PageResponse;
import com.vehica.user.dto.AdminUserDtos;
import com.vehica.user.dto.UpdateProfileRequest;
import com.vehica.user.dto.UserDto;
import com.vehica.user.entity.User;
import com.vehica.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final BookingRepository bookingRepository;
    private final PasswordEncoder passwordEncoder;

    // ==============================================================================
    // 1. USER PROFILE OPERATIONS (UC-03)
    // ==============================================================================

    /**
     * Retrieves profile details of the authenticated user (UC-03).
     *
     * @param userId unique identifier of the user
     * @return user profile data transfer object
     */
    @Transactional(readOnly = true)
    public UserDto getProfile(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy thông tin người dùng."));
        return mapToDto(user);
    }

    /**
     * Updates profile personal information including full name, phone number, and avatar URL (UC-03, BR-01).
     *
     * @param userId unique identifier of the user
     * @param request updated profile information
     * @return updated user data transfer object
     */
    @Transactional
    public UserDto updateProfile(UUID userId, UpdateProfileRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy thông tin người dùng."));

        user.setFullName(request.getFullName().trim());
        user.setPhone(request.getPhone().trim());
        if (request.getAvatarUrl() != null) {
            user.setAvatarUrl(request.getAvatarUrl().trim());
        }

        User updatedUser = userRepository.save(user);
        return mapToDto(updatedUser);
    }

    /**
     * Updates user avatar URL directly upon media upload (UC-03).
     *
     * @param userId unique identifier of the user
     * @param avatarUrl public CDN URL of the uploaded avatar image
     * @return updated user data transfer object
     */
    @Transactional
    public UserDto updateAvatar(UUID userId, String avatarUrl) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy thông tin người dùng."));

        user.setAvatarUrl(avatarUrl != null ? avatarUrl.trim() : null);
        User updatedUser = userRepository.save(user);
        return mapToDto(updatedUser);
    }

    // ==============================================================================
    // 2. ADMIN USER MANAGEMENT OPERATIONS (UC-10)
    // ==============================================================================

    /**
     * Searches and paginates system users by keyword and status for administration (UC-10).
     *
     * @param keyword optional search term matching email, name, or phone
     * @param status optional filter by user status
     * @param pageable pagination parameters
     * @return paginated response of user DTOs
     */
    @Transactional(readOnly = true)
    public PageResponse<UserDto> searchUsers(String keyword, UserStatus status, Pageable pageable) {
        Page<User> page = userRepository.searchUsers(keyword, status, pageable);
        return PageResponse.from(page.map(this::mapToDto));
    }

    /**
     * Creates a new user account with specified role and status from the admin console (UC-10, BR-01).
     *
     * @param request creation parameters
     * @return created user DTO
     */
    @Transactional
    public UserDto createUser(AdminUserDtos.CreateUserRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new ConflictException("Email đã tồn tại. Hãy dùng email khác.");
        }

        User user = User.builder()
                .email(request.getEmail().toLowerCase().trim())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .fullName(request.getFullName().trim())
                .phone(request.getPhone().trim())
                .role(request.getRole())
                .status(request.getStatus())
                .build();

        return mapToDto(userRepository.save(user));
    }

    /**
     * Updates an existing user's attributes (role, status, personal details) from the admin console (UC-10).
     *
     * @param userId unique identifier of the user to update
     * @param request updated user properties
     * @return updated user DTO
     */
    @Transactional
    public UserDto updateUser(UUID userId, AdminUserDtos.UpdateUserRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng với ID: " + userId));

        user.setFullName(request.getFullName().trim());
        user.setPhone(request.getPhone().trim());
        user.setAvatarUrl(request.getAvatarUrl());
        user.setRole(request.getRole());
        user.setStatus(request.getStatus());

        return mapToDto(userRepository.save(user));
    }

    /**
     * Toggles or modifies user account status (ACTIVE / BLOCKED) (UC-10, BR-03).
     *
     * @param userId unique identifier of the target user
     * @param status new user status
     * @return updated user DTO
     */
    @Transactional
    public UserDto updateUserStatus(UUID userId, UserStatus status) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng với ID: " + userId));

        user.setStatus(status);
        return mapToDto(userRepository.save(user));
    }

    /**
     * Deletes user account or soft-blocks if historical bookings are attached (UC-10, BR-20).
     *
     * @param userId unique identifier of the user
     */
    @Transactional
    public void deleteUser(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng với ID: " + userId));

        long bookingCount = bookingRepository.countByUserId(userId);
        if (bookingCount > 0) {
            user.setStatus(UserStatus.BLOCKED);
            userRepository.save(user);
        } else {
            userRepository.delete(user);
        }
    }

    // ==============================================================================
    // 3. OBJECT MAPPING UTILITIES
    // ==============================================================================

    public UserDto mapToDto(User user) {
        return UserDto.builder()
                .id(user.getId())
                .email(user.getEmail())
                .fullName(user.getFullName())
                .phone(user.getPhone())
                .avatarUrl(user.getAvatarUrl())
                .role(user.getRole())
                .status(user.getStatus())
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .build();
    }
}
