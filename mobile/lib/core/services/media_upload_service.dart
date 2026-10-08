// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// SERVICE : MediaUploadService - Service to select & upload images to Supabase Storage
// ==============================================================================

import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vehica_mobile/app/providers.dart';
import 'package:vehica_mobile/core/constants/api_endpoints.dart';
import 'package:vehica_mobile/core/network/api_client.dart';

final mediaUploadServiceProvider = Provider<MediaUploadService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MediaUploadService(apiClient);
});

class MediaUploadService {
  final ApiClient _apiClient;
  final ImagePicker _picker = ImagePicker();

  MediaUploadService(this._apiClient);

  /// Open image picker interface from Gallery or Device Camera
  Future<XFile?> pickImage({
    ImageSource source = ImageSource.gallery,
    double maxWidth = 1920,
    double maxHeight = 1080,
    int imageQuality = 85,
  }) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
      return file;
    } catch (e) {
      return null;
    }
  }

  /// Upload an image file to Supabase Storage via Spring Boot REST API
  /// [folder]: storage directory ('brands', 'vehicles', 'avatars', 'general')
  /// Returns: Public Supabase CDN URL (String) or null if failed
  Future<String?> uploadImage(
    XFile file, {
    String folder = 'general',
  }) async {
    try {
      final Uint8List bytes = await file.readAsBytes();
      final String fileName = file.name.isNotEmpty
          ? file.name
          : 'upload_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final formData = FormData.fromMap({
        'folder': folder,
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        ),
      });

      final response = await _apiClient.post(
        ApiEndpoints.uploadImage,
        data: formData,
      );

      if (response != null && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        return data['fileUrl']?.toString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Upload vehicle image and automatically link directly to `vehicle_images` table
  Future<String?> uploadVehicleImage({
    required String vehicleId,
    required XFile file,
    bool isPrimary = false,
  }) async {
    try {
      final Uint8List bytes = await file.readAsBytes();
      final String fileName = file.name.isNotEmpty
          ? file.name
          : 'vehicle_${vehicleId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final formData = FormData.fromMap({
        'isPrimary': isPrimary,
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        ),
      });

      final response = await _apiClient.post(
        ApiEndpoints.uploadVehicleImage(vehicleId),
        data: formData,
      );

      if (response != null && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        return data['imageUrl']?.toString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
