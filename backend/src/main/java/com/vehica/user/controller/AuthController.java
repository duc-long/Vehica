package com.vehica.user.controller;

import com.vehica.common.response.ApiResponse;
import com.vehica.user.dto.AuthResponse;
import com.vehica.user.dto.LoginRequest;
import com.vehica.user.dto.RegisterRequest;
import com.vehica.user.dto.UserDto;
import com.vehica.user.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * ==============================================================================================
 * [BACKEND AUTH CONTROLLER]
 * - SERVICE LAYER    : AuthService
 * - LINKED SCREENS   : S01 (Login), S11 (Register), S14 (Forgot & Reset Password OTP)
 * - USE CASES        : UC-01 (Login), UC-02 (Register), UC-14 (Forgot/Reset Password)
 * - BUSINESS RULES   : BR-01 (Unique Email), BR-02 (Password >= 8 chars), BR-03 (No Blocked Login), BR-23 (OTP 5-min TTL)
 * ==============================================================================================
 */
@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Tag(name = "01. Auth", description = "Authentication and Registration APIs")
public class AuthController {

    private final AuthService authService;

    /**
     * Registers a new customer account (S11 Register, UC-02, BR-01, BR-02).
     */
    @PostMapping("/register")
    @Operation(summary = "Register new customer account")
    public ResponseEntity<ApiResponse<UserDto>> register(@Valid @RequestBody RegisterRequest request) {
        UserDto registeredUser = authService.register(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Đăng ký tài khoản thành công", registeredUser));
    }

    /**
     * Authenticates user credentials and issues JWT token (S01 Login, UC-01, BR-03).
     */
    @PostMapping("/login")
    @Operation(summary = "Login and obtain JWT access token")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody LoginRequest request) {
        AuthResponse authResponse = authService.login(request);
        return ResponseEntity.ok(ApiResponse.success("Đăng nhập thành công", authResponse));
    }

    /**
     * Generates and dispatches a password reset OTP (S14 Forgot Password, UC-14, BR-23).
     */
    @PostMapping("/forgot-password")
    @Operation(summary = "Request password reset OTP")
    public ResponseEntity<ApiResponse<java.util.Map<String, Object>>> forgotPassword(@Valid @RequestBody com.vehica.user.dto.ForgotPasswordRequest request) {
        java.util.Map<String, Object> result = authService.forgotPassword(request);
        return ResponseEntity.ok(ApiResponse.success("Mã OTP đã được gửi đến email", result));
    }

    /**
     * Verifies OTP code and sets new account password (S14 Reset Password, UC-14, BR-02).
     */
    @PostMapping("/reset-password")
    @Operation(summary = "Reset password using OTP code")
    public ResponseEntity<ApiResponse<Void>> resetPassword(@Valid @RequestBody com.vehica.user.dto.ResetPasswordRequest request) {
        authService.resetPassword(request);
        return ResponseEntity.ok(ApiResponse.success("Đặt lại mật khẩu thành công. Vui lòng đăng nhập.", null));
    }
}

