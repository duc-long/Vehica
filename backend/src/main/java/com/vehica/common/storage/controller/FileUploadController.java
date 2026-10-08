package com.vehica.common.storage.controller;

import com.vehica.common.response.ApiResponse;
import com.vehica.common.storage.dto.StorageDtos;
import com.vehica.common.storage.service.SupabaseStorageService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.List;

/**
 * ==============================================================================================
 * [BACKEND FILE UPLOAD CONTROLLER]
 * - SERVICE LAYER    : SupabaseStorageService
 * - LINKED SCREENS   : S02 (Avatar Upload), S07 (Vehicle Images), S13 (Brand Logos)
 * - USE CASES        : Upload direct to Supabase Storage CDN
 * ==============================================================================================
 */
@RestController
@RequestMapping("/api/v1/storage")
@RequiredArgsConstructor
@Tag(name = "00. Storage & Uploads", description = "Supabase Storage File Upload and Management APIs")
public class FileUploadController {

    private final SupabaseStorageService storageService;

    /**
     * Uploads a single media file to Supabase Storage CDN.
     */
    @PostMapping(value = "/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Upload a single image file to Supabase Storage")
    public ResponseEntity<ApiResponse<StorageDtos.FileUploadResponse>> uploadFile(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "folder", defaultValue = "general") String folder,
            @RequestParam(value = "bucket", required = false) String bucket) {

        StorageDtos.FileUploadResponse response = storageService.uploadFile(file, folder, bucket);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Tải ảnh lên Supabase Storage thành công", response));
    }

    /**
     * Uploads multiple media files in batch to Supabase Storage CDN.
     */
    @PostMapping(value = "/upload-multiple", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Upload multiple image files to Supabase Storage")
    public ResponseEntity<ApiResponse<List<StorageDtos.FileUploadResponse>>> uploadMultipleFiles(
            @RequestParam("files") List<MultipartFile> files,
            @RequestParam(value = "folder", defaultValue = "general") String folder,
            @RequestParam(value = "bucket", required = false) String bucket) {

        List<StorageDtos.FileUploadResponse> results = new ArrayList<>();
        for (MultipartFile file : files) {
            results.add(storageService.uploadFile(file, folder, bucket));
        }

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Tải " + results.size() + " ảnh lên Supabase Storage thành công", results));
    }

    /**
     * Deletes media file from Supabase Storage CDN.
     */
    @DeleteMapping("/delete")
    @Operation(summary = "Delete an image file from Supabase Storage")
    public ResponseEntity<ApiResponse<Void>> deleteFile(
            @RequestParam("path") String path,
            @RequestParam(value = "bucket", required = false) String bucket) {

        storageService.deleteFile(path, bucket);
        return ResponseEntity.ok(ApiResponse.success("Xóa file khỏi Supabase Storage thành công", null));
    }
}
