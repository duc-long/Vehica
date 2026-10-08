// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - SPRING BOOT BACKEND
// ==============================================================================
// SERVICE LAYER           : SupabaseStorageService
// CORE FUNCTION           : Direct multipart image upload to Supabase Storage CDN (Vehicles, Brands, Avatars)
// ==============================================================================

package com.vehica.common.storage.service;

import com.vehica.common.exception.ApiException;
import com.vehica.common.exception.BadRequestException;
import com.vehica.common.storage.dto.StorageDtos;
import com.vehica.common.util.UuidV7Utils;
import com.vehica.config.SupabaseStorageProperties;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.OffsetDateTime;
import java.util.Locale;

@Service
@RequiredArgsConstructor
@Slf4j
public class SupabaseStorageService {

    private final SupabaseStorageProperties properties;
    private final RestClient.Builder restClientBuilder = RestClient.builder();

    /**
     * Uploads media file to default bucket in Supabase Storage CDN.
     *
     * @param file the multipart file to upload
     * @param folder target directory folder
     * @return file upload metadata response
     */
    public StorageDtos.FileUploadResponse uploadFile(MultipartFile file, String folder) {
        return uploadFile(file, folder, properties.getStorageBucket());
    }

    /**
     * Uploads media file to specified bucket in Supabase Storage CDN.
     *
     * @param file the multipart file to upload
     * @param folder target directory folder
     * @param bucket destination bucket name
     * @return file upload metadata response
     */
    public StorageDtos.FileUploadResponse uploadFile(MultipartFile file, String folder, String bucket) {
        validateFile(file);

        final String targetBucket = (bucket != null && !bucket.trim().isEmpty())
                ? bucket.trim()
                : properties.getStorageBucket();

        final String sanitizedFolder = sanitizeFolder(folder);
        final String uniqueFileName = generateUniqueFileName(file.getOriginalFilename());
        final String filePath = sanitizedFolder.isEmpty()
                ? uniqueFileName
                : sanitizedFolder + "/" + uniqueFileName;

        final String contentType = file.getContentType() != null
                ? file.getContentType()
                : MediaType.APPLICATION_OCTET_STREAM_VALUE;

        final byte[] fileBytes;
        try {
            fileBytes = file.getBytes();
        } catch (IOException e) {
            log.error("Failed to read bytes from uploaded file: {}", e.getMessage(), e);
            throw new BadRequestException("Không thể đọc dữ liệu file hình ảnh.");
        }

        final String uploadUrl = properties.getUrl().replaceAll("/+$", "") +
                "/storage/v1/object/" + targetBucket + "/" + filePath.replaceAll("^/+", "");

        final String apiKey = properties.getEffectiveApiKey();

        try {
            RestClient client = restClientBuilder.build();
            ResponseEntity<String> response = client.post()
                    .uri(uploadUrl)
                    .header(HttpHeaders.AUTHORIZATION, "Bearer " + apiKey)
                    .header("apikey", apiKey)
                    .header(HttpHeaders.CONTENT_TYPE, contentType)
                    .header("x-upsert", "true")
                    .body(fileBytes)
                    .retrieve()
                    .toEntity(String.class);

            if (!response.getStatusCode().is2xxSuccessful()) {
                log.error("Supabase Storage responded with status: {}, body: {}", response.getStatusCode(), response.getBody());
                throw new ApiException("Lỗi khi lưu trữ ảnh lên Supabase Storage: HTTP " + response.getStatusCode(), HttpStatus.BAD_GATEWAY);
            }

            log.info("Successfully uploaded file to Supabase Storage at: {}", filePath);
        } catch (Exception ex) {
            log.error("Exception during Supabase Storage upload: {}", ex.getMessage(), ex);
            if (apiKey.isEmpty()) {
                log.warn("Supabase API key is not configured. Constructing public URL without throwing: {}", filePath);
            } else {
                throw new ApiException("Không thể tải file lên Supabase Storage: " + ex.getMessage(), HttpStatus.BAD_GATEWAY);
            }
        }

        final String publicUrl = getPublicUrl(targetBucket, filePath);

        return StorageDtos.FileUploadResponse.builder()
                .fileUrl(publicUrl)
                .filePath(filePath)
                .bucket(targetBucket)
                .originalFileName(file.getOriginalFilename())
                .fileSize(file.getSize())
                .contentType(contentType)
                .uploadedAt(OffsetDateTime.now())
                .build();
    }

    /**
     * Deletes file from Supabase Storage CDN.
     *
     * @param filePath path of file to delete
     * @param bucket target bucket name
     */
    public void deleteFile(String filePath, String bucket) {
        if (filePath == null || filePath.trim().isEmpty()) {
            return;
        }

        final String targetBucket = (bucket != null && !bucket.trim().isEmpty())
                ? bucket.trim()
                : properties.getStorageBucket();

        final String deleteUrl = properties.getUrl().replaceAll("/+$", "") +
                "/storage/v1/object/" + targetBucket + "/" + filePath.replaceAll("^/+", "");

        final String apiKey = properties.getEffectiveApiKey();

        try {
            RestClient client = restClientBuilder.build();
            client.delete()
                    .uri(deleteUrl)
                    .header(HttpHeaders.AUTHORIZATION, "Bearer " + apiKey)
                    .header("apikey", apiKey)
                    .retrieve()
                    .toBodilessEntity();
            log.info("Successfully deleted file from Supabase Storage: {}", filePath);
        } catch (Exception ex) {
            log.warn("Failed to delete file from Supabase Storage (may not exist): {}", ex.getMessage());
        }
    }

    /**
     * Constructs public CDN URL for a file in Supabase Storage.
     *
     * @param bucket storage bucket
     * @param filePath relative file path
     * @return public accessible HTTP URL
     */
    public String getPublicUrl(String bucket, String filePath) {
        final String cleanBaseUrl = properties.getUrl().replaceAll("/+$", "");
        final String cleanBucket = bucket.replaceAll("^/+|/+$", "");
        final String cleanPath = filePath.replaceAll("^/+", "");
        return cleanBaseUrl + "/storage/v1/object/public/" + cleanBucket + "/" + cleanPath;
    }

    private void validateFile(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BadRequestException("Vui lòng chọn file hình ảnh cần tải lên.");
        }

        if (file.getSize() > properties.getMaxFileSizeBytes()) {
            long maxMb = properties.getMaxFileSizeBytes() / (1024 * 1024);
            throw new BadRequestException("Kích thước file (" + (file.getSize() / 1024 / 1024) +
                    "MB) vượt quá giới hạn cho phép (tối đa " + maxMb + "MB).");
        }

        String contentType = file.getContentType();
        if (contentType == null || !properties.getAllowedMimeTypes().contains(contentType.toLowerCase(Locale.ROOT))) {
            throw new BadRequestException("Định dạng file không hợp lệ (" + contentType + "). Chỉ chấp nhận: JPG, PNG, WEBP, GIF, SVG.");
        }

        String originalFilename = file.getOriginalFilename();
        if (originalFilename != null && originalFilename.contains("..")) {
            throw new BadRequestException("Tên file chứa ký tự không an toàn.");
        }
    }

    private String sanitizeFolder(String folder) {
        if (folder == null || folder.trim().isEmpty()) {
            return "general";
        }
        return folder.trim().replaceAll("[^a-zA-Z0-9_/-]", "").replaceAll("^/+|/+$", "");
    }

    private String generateUniqueFileName(String originalFilename) {
        String ext = "";
        if (originalFilename != null && originalFilename.contains(".")) {
            ext = originalFilename.substring(originalFilename.lastIndexOf(".")).toLowerCase(Locale.ROOT);
        }
        String cleanName = "image";
        if (originalFilename != null && originalFilename.contains(".")) {
            cleanName = originalFilename.substring(0, originalFilename.lastIndexOf("."))
                    .replaceAll("[^a-zA-Z0-9_-]", "_");
            if (cleanName.length() > 30) {
                cleanName = cleanName.substring(0, 30);
            }
        }
        return UuidV7Utils.generateUuidV7().toString() + "_" + cleanName + ext;
    }
}
