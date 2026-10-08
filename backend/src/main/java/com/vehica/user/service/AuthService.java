// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - SPRING BOOT BACKEND
// ==============================================================================
// SERVICE LAYER           : AuthService
// USE CASES HANDLED       : UC-01 (Authentication/Login), UC-02 (Registration), UC-14 (Forgot Password & OTP)
// BUSINESS RULES / BR     : BR-01 (Email & Phone format validation), BR-02 (Password >= 8 chars),
//                           BR-03 (Account Status ACTIVE/BLOCKED check), BR-23 (OTP 5-min TTL, Cooldown 60s)
// ==============================================================================

package com.vehica.user.service;

import com.vehica.common.enums.UserRole;
import com.vehica.common.enums.UserStatus;
import com.vehica.common.exception.BadRequestException;
import com.vehica.common.exception.ConflictException;
import com.vehica.common.exception.ForbiddenException;
import com.vehica.common.exception.ResourceNotFoundException;
import com.vehica.security.JwtTokenProvider;
import com.vehica.security.UserPrincipal;
import com.vehica.user.dto.*;
import com.vehica.user.entity.PasswordResetOtp;
import com.vehica.user.entity.User;
import com.vehica.user.repository.PasswordResetOtpRepository;
import com.vehica.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.Duration;
import java.time.OffsetDateTime;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider tokenProvider;
    private final UserService userService;
    private final PasswordResetOtpRepository otpRepository;

    private static final int OTP_EXPIRY_MINUTES = 5;          // OTP validity window: 5 minutes
    private static final int OTP_COOLDOWN_SECONDS = 60;        // Rate limiting: 60s cooldown between OTP requests
    private static final int MAX_FAILED_ATTEMPTS = 5;         // Brute-force protection: Max 5 attempts

    /**
     * Registers a new customer account, validates email uniqueness, encodes password with BCrypt (UC-02, BR-01, BR-02).
     *
     * @param request the registration details
     * @return the created user data transfer object
     */
    @Transactional
    public UserDto register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new ConflictException("Email đã tồn tại. Hãy dùng email khác.");
        }

        User user = User.builder()
                .email(request.getEmail().toLowerCase().trim())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .fullName(request.getFullName().trim())
                .phone(request.getPhone().trim())
                .role(UserRole.USER)
                .status(UserStatus.ACTIVE)
                .build();

        User savedUser = userRepository.save(user);
        return userService.mapToDto(savedUser);
    }

    /**
     * Authenticates user credentials and issues a signed JWT access token (UC-01, BR-03).
     *
     * @param request login credentials (email & password)
     * @return authentication response containing the bearer JWT token and user info
     */
    public AuthResponse login(LoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail().toLowerCase().trim(),
                        request.getPassword()
                )
        );

        UserPrincipal principal = (UserPrincipal) authentication.getPrincipal();

        if (principal.getStatus() == UserStatus.BLOCKED) {
            throw new ForbiddenException("Tài khoản đang bị khóa. Hãy liên hệ quản trị viên.");
        }

        SecurityContextHolder.getContext().setAuthentication(authentication);
        String jwt = tokenProvider.generateToken(authentication);

        User user = userRepository.findById(principal.getId())
                .orElseThrow(() -> new ForbiddenException("Tài khoản không tồn tại."));

        return AuthResponse.builder()
                .accessToken(jwt)
                .tokenType("Bearer")
                .user(userService.mapToDto(user))
                .build();
    }

    /**
     * Generates a 6-digit password reset OTP, enforces 60s cooldown, and persists to database (UC-14, BR-23).
     *
     * @param request the forgot password request containing user email
     * @return confirmation map with cooldown and expiration details
     */
    @Transactional
    public Map<String, Object> forgotPassword(ForgotPasswordRequest request) {
        String email = request.getEmail().toLowerCase().trim();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy tài khoản với email: " + email));

        if (user.getStatus() == UserStatus.BLOCKED) {
            throw new ForbiddenException("Tài khoản đang bị khóa. Hãy liên hệ quản trị viên.");
        }

        OffsetDateTime now = OffsetDateTime.now();

        // 1. Clean up expired or used OTPs in the database
        try {
            otpRepository.deleteExpiredOrUsedOtps(now);
        } catch (Exception ignored) {
        }

        // 2. Anti-SPAM (60s Cooldown): Check the most recent unused OTP in the database
        Optional<PasswordResetOtp> latestOtpOpt =
                otpRepository.findTopByEmailAndIsUsedFalseOrderByCreatedAtDesc(email);

        if (latestOtpOpt.isPresent()) {
            PasswordResetOtp existing = latestOtpOpt.get();
            if (now.isBefore(existing.getExpiresAt())) {
                long secondsSinceLastRequest = Duration.between(existing.getCreatedAt(), now).getSeconds();
                if (secondsSinceLastRequest < OTP_COOLDOWN_SECONDS) {
                    long waitSeconds = OTP_COOLDOWN_SECONDS - secondsSinceLastRequest;
                    throw new BadRequestException(
                            "Thao tác quá nhanh! Vui lòng đợi " + waitSeconds + " giây nữa trước khi yêu cầu gửi lại mã OTP."
                    );
                }
            }
            // Disable old OTP before issuing a new one
            existing.setUsed(true);
            existing.setUsedAt(now);
            otpRepository.save(existing);
        }

        // 3. Generate a random 6-digit OTP
        String otp = String.format("%06d", new SecureRandom().nextInt(1_000_000));
        OffsetDateTime expiresAt = now.plusMinutes(OTP_EXPIRY_MINUTES);

        // 4. Securely save the OTP record to the database (password_reset_otps table)
        PasswordResetOtp otpEntity = PasswordResetOtp.builder()
                .email(email)
                .otpCode(otp)
                .createdAt(now)
                .expiresAt(expiresAt)
                .failedAttempts(0)
                .isUsed(false)
                .build();
        otpRepository.save(otpEntity);

        return Map.of(
                "message", "Mã xác thực OTP đã được tạo và lưu trữ an toàn trong CSDL (hiệu lực 5 phút).",
                "email", email,
                "expiresInSeconds", OTP_EXPIRY_MINUTES * 60,
                "cooldownSeconds", OTP_COOLDOWN_SECONDS,
                "otp", otp
        );
    }

    /**
     * Verifies the OTP code against brute-force limit (5 attempts) and updates password hash (UC-14, BR-02, BR-23).
     *
     * @param request reset password request with email, OTP code, and new password
     */
    @Transactional
    public void resetPassword(ResetPasswordRequest request) {
        String email = request.getEmail().toLowerCase().trim();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy tài khoản với email: " + email));

        if (user.getStatus() == UserStatus.BLOCKED) {
            throw new ForbiddenException("Tài khoản đang bị khóa. Hãy liên hệ quản trị viên.");
        }

        String inputOtp = request.getOtp().trim();
        OffsetDateTime now = OffsetDateTime.now();

        Optional<PasswordResetOtp> otpOpt =
                otpRepository.findTopByEmailAndIsUsedFalseOrderByCreatedAtDesc(email);

        if (otpOpt.isEmpty()) {
            throw new BadRequestException("Không tìm thấy yêu cầu đặt lại mật khẩu hoặc mã OTP đã hết hạn/đã sử dụng. Vui lòng xin mã mới.");
        }

        PasswordResetOtp otpEntity = otpOpt.get();

        // 1. Check expiration from the database
        if (now.isAfter(otpEntity.getExpiresAt())) {
            otpEntity.setUsed(true);
            otpEntity.setUsedAt(now);
            otpRepository.save(otpEntity);
            throw new BadRequestException("Mã xác thực OTP đã hết hạn (sau 5 phút). Vui lòng yêu cầu mã mới.");
        }

        // 2. Anti-Brute-force: Check the number of incorrect attempts from the database
        if (!otpEntity.getOtpCode().equals(inputOtp)) {
            int attempts = otpEntity.getFailedAttempts() + 1;
            otpEntity.setFailedAttempts(attempts);
            if (attempts >= MAX_FAILED_ATTEMPTS) {
                otpEntity.setUsed(true);
                otpEntity.setUsedAt(now);
                otpRepository.save(otpEntity);
                throw new BadRequestException(
                        "Bạn đã nhập sai mã OTP quá " + MAX_FAILED_ATTEMPTS + " lần. Mã xác thực đã bị hủy vì lý do bảo mật. Vui lòng xin mã mới."
                );
            }
            otpRepository.save(otpEntity);
            int remaining = MAX_FAILED_ATTEMPTS - attempts;
            throw new BadRequestException(
                    "Mã OTP không chính xác. Bạn còn " + remaining + " lần thử lại."
            );
        }

        // 3. Mark OTP as used in the database (Single-use token)
        otpEntity.setUsed(true);
        otpEntity.setUsedAt(now);
        otpRepository.save(otpEntity);

        // Update with new BCrypt encrypted password
        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
    }
}
