package com.vehica.common.storage.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.OffsetDateTime;

public class StorageDtos {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class FileUploadResponse {
        private String fileUrl;
        private String filePath;
        private String bucket;
        private String originalFileName;
        private Long fileSize;
        private String contentType;
        private OffsetDateTime uploadedAt;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DeleteFileRequest {
        private String path;
        private String bucket;
    }
}
