package com.vehica.user.repository;

import com.vehica.common.enums.UserStatus;
import com.vehica.user.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

/**
 * ==============================================================================================
 * [BACKEND USER REPOSITORY]
 * - LINKED SCREENS   : S01 (Login), S11 (Register), S02 (Profile), S09 (Admin User Management)
 * - USE CASES        : UC-01, UC-02, UC-03, UC-10 (User Management)
 * - BUSINESS RULES   : BR-01 (Unique Email), BR-03 (Account Status ACTIVE/BLOCKED)
 * ==============================================================================================
 */
@Repository
public interface UserRepository extends JpaRepository<User, UUID> {

    /**
     * Finds user by email for authentication and credential validation (BR-01, BR-03).
     */
    Optional<User> findByEmail(String email);

    /**
     * Checks if email address is already registered in the system (BR-01).
     */
    boolean existsByEmail(String email);

    /**
     * Searches and paginates users by keyword and status filter for the admin portal (S09, UC-10).
     */
    @Query("SELECT u FROM User u WHERE " +
           "(:keyword IS NULL OR :keyword = '' OR " +
           "LOWER(u.email) LIKE LOWER(CONCAT('%', CAST(:keyword AS string), '%')) OR " +
           "LOWER(u.fullName) LIKE LOWER(CONCAT('%', CAST(:keyword AS string), '%')) OR " +
           "u.phone LIKE CONCAT('%', CAST(:keyword AS string), '%')) AND " +
           "(:status IS NULL OR u.status = :status)")
    Page<User> searchUsers(@Param("keyword") String keyword, @Param("status") UserStatus status, Pageable pageable);

    /**
     * Counts users by account status for KPI dashboard analytics (S10, UC-11).
     */
    long countByStatus(UserStatus status);
}
