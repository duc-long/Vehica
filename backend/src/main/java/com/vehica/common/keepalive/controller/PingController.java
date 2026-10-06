package com.vehica.common.keepalive.controller;

import com.vehica.common.keepalive.dto.PingResponse;
import com.vehica.common.keepalive.service.SupabaseKeepAliveService;
import com.vehica.common.response.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/ping")
@RequiredArgsConstructor
@Tag(name = "00. Health & KeepAlive", description = "Endpoints for health checks and Supabase keepalive pings")
public class PingController {

    private final SupabaseKeepAliveService keepAliveService;

    @GetMapping
    @Operation(
            summary = "Ping Supabase and check backend health",
            description = "Executes a lightweight query against Supabase PostgreSQL to verify connectivity and keep the database active."
    )
    public ResponseEntity<ApiResponse<PingResponse>> ping() {
        PingResponse response = keepAliveService.pingDatabase();
        return ResponseEntity.ok(ApiResponse.success(response.getMessage(), response));
    }

    @PostMapping("/trigger")
    @Operation(
            summary = "Manually trigger Supabase keepalive query",
            description = "Forces an immediate SQL query execution to record activity in Supabase and prevent pause."
    )
    public ResponseEntity<ApiResponse<PingResponse>> triggerKeepAlive() {
        PingResponse response = keepAliveService.pingDatabase();
        return ResponseEntity.ok(ApiResponse.success("KeepAlive query successfully triggered.", response));
    }
}
