package com.vehica.common.keepalive.scheduler;

import com.vehica.common.keepalive.service.SupabaseKeepAliveService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
@ConditionalOnProperty(name = "app.supabase.ping-enabled", havingValue = "true", matchIfMissing = true)
public class SupabaseKeepAliveScheduler {

    private final SupabaseKeepAliveService keepAliveService;

    /**
     * Initial ping upon application startup to warm up the DB pool and verify Supabase connection.
     */
    @EventListener(ApplicationReadyEvent.class)
    public void onStartup() {
        log.info("[Supabase KeepAlive] Initial startup keep-alive check executing...");
        keepAliveService.pingDatabase();
    }

    /**
     * Periodic scheduled keep-alive ping.
     * Default: Every 4 hours (0 0 *\/4 * * *).
     * Supabase pauses projects after 7 days of inactivity; pinging every 4 hours ensures 100% active state.
     */
    @Scheduled(
            cron = "${app.supabase.ping-cron:0 0 */4 * * *}",
            zone = "Asia/Ho_Chi_Minh"
    )
    public void scheduleKeepAlive() {
        log.info("[Supabase KeepAlive] Scheduled periodic keep-alive query running...");
        keepAliveService.pingDatabase();
    }
}
