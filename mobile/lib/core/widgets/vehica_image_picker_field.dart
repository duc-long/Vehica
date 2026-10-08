// ==============================================================================
// VEHICA Design System — Image Picker & Uploader Field
// Supports selecting images from Camera / Gallery and automatically uploading to Supabase Storage CDN
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/services/media_upload_service.dart';
import 'package:vehica_mobile/core/widgets/vehica_image.dart';

class VehicaImagePickerField extends ConsumerStatefulWidget {
  final String label;
  final String? initialUrl;
  final TextEditingController? urlController;
  final String folder;
  final ValueChanged<String>? onUploaded;

  const VehicaImagePickerField({
    super.key,
    required this.label,
    this.initialUrl,
    this.urlController,
    this.folder = 'general',
    this.onUploaded,
  });

  @override
  ConsumerState<VehicaImagePickerField> createState() =>
      _VehicaImagePickerFieldState();
}

class _VehicaImagePickerFieldState
    extends ConsumerState<VehicaImagePickerField> {
  bool _isUploading = false;
  String? _currentUrl;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.urlController?.text.isNotEmpty == true
        ? widget.urlController!.text
        : widget.initialUrl;
  }

  Future<void> _handlePickImage(ImageSource source) async {
    final uploadService = ref.read(mediaUploadServiceProvider);

    final xFile = await uploadService.pickImage(source: source);
    if (xFile == null) return;

    setState(() => _isUploading = true);

    final uploadedUrl = await uploadService.uploadImage(
      xFile,
      folder: widget.folder,
    );

    setState(() => _isUploading = false);

    if (uploadedUrl != null && mounted) {
      setState(() => _currentUrl = uploadedUrl);
      if (widget.urlController != null) {
        widget.urlController!.text = uploadedUrl;
      }
      widget.onUploaded?.call(uploadedUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tải ảnh lên Supabase CDN thành công!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lỗi tải ảnh lên. Vui lòng thử lại.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showPickerSourceModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Chọn nguồn tải ảnh',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMuted,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                  ),
                  title: const Text('Thư viện ảnh thiết bị', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Chọn ảnh từ bộ nhớ thiết bị', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _handlePickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.tertiary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.photo_camera_rounded, color: AppColors.tertiary),
                  ),
                  title: const Text('Chụp ảnh từ Camera', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Mở camera để chụp ảnh mới', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _handlePickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _currentUrl != null && _currentUrl!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              // Image Preview or Placeholder
              Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 70,
                      height: 70,
                      child: hasImage
                          ? VehicaImage(
                              imageUrl: _currentUrl,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: AppColors.surfaceVariantLight,
                              child: const Icon(
                                Icons.image_outlined,
                                color: AppColors.textDisabled,
                                size: 30,
                              ),
                            ),
                    ),
                  ),
                  if (_isUploading)
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // Upload Actions & Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isUploading
                          ? 'Đang tải lên Supabase...'
                          : (hasImage ? 'Ảnh đã tải lên Supabase' : 'Chưa có ảnh tải lên'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: hasImage ? AppColors.success : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _isUploading ? null : _showPickerSourceModal,
                          icon: const Icon(Icons.upload_file_rounded, size: 16),
                          label: Text(
                            hasImage ? 'Đổi ảnh' : 'Tải ảnh lên',
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        if (hasImage)
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              setState(() => _currentUrl = null);
                              if (widget.urlController != null) {
                                widget.urlController!.clear();
                              }
                              widget.onUploaded?.call('');
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
