package com.vehica.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

import java.util.Set;

@Configuration
@ConfigurationProperties(prefix = "app.supabase")
@Data
public class SupabaseStorageProperties {

    private String url;
    private String anonKey;
    private String serviceRoleKey;
    private String storageBucket = "vehica-media";
    private long maxFileSizeBytes = 10 * 1024 * 1024; // 10MB
    private boolean pingEnabled = true;
    private String pingCron = "0 0 */4 * * *";

    private Set<String> allowedMimeTypes = Set.of(
            "image/jpeg",
            "image/jpg",
            "image/png",
            "image/webp",
            "image/gif",
            "image/svg+xml"
    );

    public String getEffectiveApiKey() {
        if (serviceRoleKey != null && !serviceRoleKey.trim().isEmpty()) {
            return serviceRoleKey.trim();
        }
        return anonKey != null ? anonKey.trim() : "";
    }
}
