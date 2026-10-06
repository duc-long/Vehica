package com.vehica.common.keepalive.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Response payload for Supabase ping and keepalive health check")
public class PingResponse {

    @Schema(description = "Application and Supabase connectivity status", example = "UP")
    private String status;

    @Schema(description = "Message indicating health status", example = "Pong! Supabase connection is active")
    private String message;

    @Schema(description = "Database connection state", example = "CONNECTED")
    private String database;

    @Schema(description = "Query execution latency in milliseconds", example = "15")
    private Long latencyMs;

    @Schema(description = "Database server current timestamp from Supabase")
    private String databaseTime;

    @Schema(description = "Timestamp when ping check was executed")
    private LocalDateTime timestamp;
}
