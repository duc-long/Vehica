package com.vehica.user.controller;

import com.vehica.common.enums.UserStatus;
import com.vehica.common.response.ApiResponse;
import com.vehica.common.response.PageResponse;
import com.vehica.user.dto.AdminUserDtos;
import com.vehica.user.dto.UserDto;
import com.vehica.user.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

/**
 * ==============================================================================================
 * [BACKEND ADMIN USER MANAGEMENT CONTROLLER]
 * - SERVICE LAYER    : UserService
 * - LINKED SCREENS   : S09 (Admin User Management)
 * - USE CASES        : UC-10 (Manage Users)
 * - BUSINESS RULES   : BR-01 (Unique Email), BR-03 (Blocked Account Block), BR-20 (Account Status)
 * ==============================================================================================
 */
@RestController
@RequestMapping("/api/v1/admin/users")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
@Tag(name = "07. Admin Users", description = "Admin User Management APIs")
public class AdminUserController {

    private final UserService userService;

    /**
     * Retrieves paginated list of users with optional keyword and status filters (S09 Admin Users, UC-10).
     */
    @GetMapping
    @Operation(summary = "Get paginated user list with optional search and status filter")
    public ResponseEntity<ApiResponse<PageResponse<UserDto>>> getUsers(
            @RequestParam(required = false) String search,
            @RequestParam(required = false) UserStatus status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "desc") String direction) {

        Sort sort = direction.equalsIgnoreCase("asc") ? Sort.by(sortBy).ascending() : Sort.by(sortBy).descending();
        Pageable pageable = PageRequest.of(page, size, sort);

        PageResponse<UserDto> users = userService.searchUsers(search, status, pageable);
        return ResponseEntity.ok(ApiResponse.success(users));
    }

    /**
     * Creates a new user account as administrator (S09 Admin Users, UC-10, BR-01).
     */
    @PostMapping
    @Operation(summary = "Create user as Admin")
    public ResponseEntity<ApiResponse<UserDto>> createUser(@Valid @RequestBody AdminUserDtos.CreateUserRequest request) {
        UserDto created = userService.createUser(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Tạo người dùng thành công", created));
    }

    /**
     * Updates user details as administrator (S09 Admin Users, UC-10).
     */
    @PutMapping("/{id}")
    @Operation(summary = "Update user details as Admin")
    public ResponseEntity<ApiResponse<UserDto>> updateUser(
            @PathVariable UUID id,
            @Valid @RequestBody AdminUserDtos.UpdateUserRequest request) {
        UserDto updated = userService.updateUser(id, request);
        return ResponseEntity.ok(ApiResponse.success("Cập nhật người dùng thành công", updated));
    }

    /**
     * Updates user ACTIVE/BLOCKED status as administrator (S09 Admin Users, UC-10, BR-03).
     */
    @PatchMapping("/{id}/status")
    @Operation(summary = "Update user ACTIVE/BLOCKED status as Admin")
    public ResponseEntity<ApiResponse<UserDto>> updateStatus(
            @PathVariable UUID id,
            @Valid @RequestBody AdminUserDtos.UpdateStatusRequest request) {
        UserDto updated = userService.updateUserStatus(id, request.getStatus());
        return ResponseEntity.ok(ApiResponse.success("Cập nhật trạng thái thành công", updated));
    }

    /**
     * Deletes or soft-blocks user depending on booking history (S09 Admin Users, UC-10, BR-20).
     */
    @DeleteMapping("/{id}")
    @Operation(summary = "Delete user (Soft delete if bookings exist, hard delete if 0 bookings)")
    public ResponseEntity<ApiResponse<Void>> deleteUser(@PathVariable UUID id) {
        userService.deleteUser(id);
        return ResponseEntity.ok(ApiResponse.success("Xóa/Khóa người dùng thành công", null));
    }
}
