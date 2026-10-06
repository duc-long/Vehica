// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - SPRING BOOT BACKEND
// ==============================================================================
// SERVICE LAYER           : SupabaseKeepAliveService
// CORE FUNCTION           : Automated Keep-Alive heartbeat mechanism for cloud database
// ==============================================================================

package com.vehica.common.keepalive.service;

import com.vehica.common.keepalive.dto.PingResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Slf4j
@Service
@RequiredArgsConstructor
public class SupabaseKeepAliveService {

    private final JdbcTemplate jdbcTemplate;

    /**
     * Executes a lightweight database query to maintain active connection and measure roundtrip latency.
     *
     * @return ping health response with database status and latency
     */
    public PingResponse pingDatabase() {
        long startTime = System.currentTimeMillis();
        try {
            // Query DB server timestamp to verify active connection and execute DB activity
            String dbTime = jdbcTemplate.queryForObject("SELECT NOW()::text", String.class);
            long latencyMs = System.currentTimeMillis() - startTime;

            log.info("[Supabase KeepAlive] Ping OK! Latency: {} ms, DB Time: {}", latencyMs, dbTime);

            return PingResponse.builder()
                    .status("UP")
                    .database("CONNECTED")
                    .message("Pong! Supabase connection is active and healthy.")
                    .latencyMs(latencyMs)
                    .databaseTime(dbTime)
                    .timestamp(LocalDateTime.now())
                    .build();
        } catch (Exception e) {
            long latencyMs = System.currentTimeMillis() - startTime;
            log.error("[Supabase KeepAlive] Ping FAILED after {} ms. Error: {}", latencyMs, e.getMessage());

            return PingResponse.builder()
                    .status("DEGRADED")
                    .database("DISCONNECTED")
                    .message("Error pinging Supabase: " + e.getMessage())
                    .latencyMs(latencyMs)
                    .timestamp(LocalDateTime.now())
                    .build();
        }
    }
}
