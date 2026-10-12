package com.vehica.user.controller;

import com.vehica.common.response.ApiResponse;
import com.vehica.common.storage.dto.StorageDtos;
import com.vehica.common.storage.service.SupabaseStorageService;
import com.vehica.security.UserPrincipal;
import com.vehica.user.dto.UpdateProfileRequest;
import com.vehica.user.dto.UserDto;
import com.vehica.user.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

/**
 * ==============================================================================================
 * [BACKEND PROFILE CONTROLLER]
 * - SERVICE LAYER    : UserService, SupabaseStorageService
 * - LINKED SCREENS   : S02 (Profile)
 * - USE CASES        : UC-03 (Manage Profile)
 * - BUSINESS RULES   : FR-PRO-01, FR-PRO-02, FR-PRO-03 (Email Read-only), FR-PRO-04
 * ==============================================================================================
 */
@RestController
@RequestMapping("/api/v1/me")
@RequiredArgsConstructor
@Tag(name = "02. Profile", description = "Current authenticated user profile APIs")
public class ProfileController {

    private final UserService userService;
    private final SupabaseStorageService storageService;

    /**
     * Retrieves current user profile (S02 Profile, UC-03).
     */
    @GetMapping
    @Operation(summary = "Get current user profile")
    public ResponseEntity<ApiResponse<UserDto>> getProfile(@AuthenticationPrincipal UserPrincipal userPrincipal) {
        UserDto profile = userService.getProfile(userPrincipal.getId());
        return ResponseEntity.ok(ApiResponse.success(profile));
    }

    /**
     * Updates current user profile details (S02 Profile, UC-03).
     */
    @PutMapping
    @Operation(summary = "Update current user profile")
    public ResponseEntity<ApiResponse<UserDto>> updateProfile(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @Valid @RequestBody UpdateProfileRequest request) {
        UserDto updated = userService.updateProfile(userPrincipal.getId(), request);
        return ResponseEntity.ok(ApiResponse.success("Cập nhật thông tin thành công", updated));
    }

    /**
     * Uploads avatar directly to Supabase Storage and updates user profile (S02 Profile, UC-03).
     */
    @PostMapping(value = "/avatar/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Upload user avatar directly to Supabase Storage")
    public ResponseEntity<ApiResponse<UserDto>> uploadAvatar(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @RequestParam("file") MultipartFile file) {
        StorageDtos.FileUploadResponse uploadResult = storageService.uploadFile(file, "avatars/" + userPrincipal.getId());
        UserDto updated = userService.updateAvatar(userPrincipal.getId(), uploadResult.getFileUrl());
        return ResponseEntity.ok(ApiResponse.success("Tải ảnh đại diện lên Supabase Storage thành công", updated));
    }
}
