package com.vehica.user.repository;

import com.vehica.user.entity.PasswordResetOtp;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * ==============================================================================================
 * [BACKEND OTP REPOSITORY]
 * - LINKED SCREENS   : S14 (Forgot Password & Reset OTP)
 * - USE CASES        : UC-14 (Forgot & Reset Password)
 * - BUSINESS RULES   : BR-23 (OTP 5-minute expiry, 60s cooldown anti-spam, 5 failed attempts limit)
 * ==============================================================================================
 */
@Repository
public interface PasswordResetOtpRepository extends JpaRepository<PasswordResetOtp, UUID> {

    /**
     * Retrieves the latest unused OTP token for the specified email address (UC-14).
     */
    Optional<PasswordResetOtp> findTopByEmailAndIsUsedFalseOrderByCreatedAtDesc(String email);

    /**
     * Retrieves all active unused OTP tokens for rate-limiting and invalidation (BR-23).
     */
    List<PasswordResetOtp> findAllByEmailAndIsUsedFalse(String email);

    /**
     * Cleans up expired or consumed OTP records from the database (BR-23).
     */
    @Modifying
    @Query("DELETE FROM PasswordResetOtp o WHERE o.expiresAt < :now OR o.isUsed = true")
    void deleteExpiredOrUsedOtps(@Param("now") OffsetDateTime now);
}
