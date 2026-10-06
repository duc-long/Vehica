package com.vehica.user.controller;

import com.vehica.common.response.ApiResponse;
import com.vehica.security.UserPrincipal;
import com.vehica.user.dto.UserDto;
import com.vehica.user.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

/**
 * ==============================================================================================
 * [BACKEND PROFILE CONTROLLER]
 * - SERVICE LAYER    : UserService
 * - LINKED SCREENS   : S02 (Profile)
 * - USE CASES        : UC-03 (View Profile)
 * - BUSINESS RULES   : FR-PRO-01, FR-PRO-03 (Email Read-only)
 * ==============================================================================================
 */
@RestController
@RequestMapping("/api/v1/me")
@RequiredArgsConstructor
@Tag(name = "02. Profile", description = "Current authenticated user profile APIs")
public class ProfileController {

    private final UserService userService;

    /**
     * Retrieves current user profile (S02 Profile, UC-03).
     */
    @GetMapping
    @Operation(summary = "Get current user profile")
    public ResponseEntity<ApiResponse<UserDto>> getProfile(@AuthenticationPrincipal UserPrincipal userPrincipal) {
        UserDto profile = userService.getProfile(userPrincipal.getId());
        return ResponseEntity.ok(ApiResponse.success(profile));
    }
}
