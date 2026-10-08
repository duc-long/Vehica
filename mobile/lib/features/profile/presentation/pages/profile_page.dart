// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// SCREEN       : S02 - Profile Page
// STYLE        : Dark Slate Luxury, Emerald Teal Accent
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/services/media_upload_service.dart';
import 'package:vehica_mobile/core/widgets/vehica_back_button.dart';
import 'package:vehica_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:vehica_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:vehica_mobile/core/services/vehica_feedback.dart';
import 'package:vehica_mobile/features/profile/presentation/widgets/profile_avatar_sheet.dart';
import 'package:vehica_mobile/features/profile/presentation/widgets/profile_header_card.dart';
import 'package:vehica_mobile/features/profile/presentation/widgets/profile_info_card.dart';
import 'package:vehica_mobile/features/profile/presentation/widgets/profile_logout_tile.dart';
import 'package:vehica_mobile/features/profile/presentation/widgets/profile_security_tile.dart';
import 'package:vehica_mobile/features/profile/presentation/widgets/profile_stats_card.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final success = await ref.read(authControllerProvider.notifier).updateProfile(
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
        );

    setState(() {
      _isSaving = false;
      if (success) _isEditing = false;
    });

    if (mounted) {
      if (success) {
        VehicaFeedback.showSuccess('Cập nhật hồ sơ thành công!');
      } else {
        VehicaFeedback.showError('Có lỗi xảy ra khi lưu thông tin');
      }
    }
  }

  Future<void> _handlePickAndUploadAvatar(ImageSource source) async {
    final messenger = ScaffoldMessenger.of(context);
    final uploadService = ref.read(mediaUploadServiceProvider);

    try {
      final xFile = await uploadService.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (xFile == null) return;

      setState(() => _isUploadingAvatar = true);
      final user = ref.read(authControllerProvider).user;

      final uploadedUrl = await uploadService.uploadImage(xFile, folder: 'avatars');

      if (uploadedUrl != null && user != null) {
        final success = await ref.read(authControllerProvider.notifier).updateProfile(
              fullName: user.fullName,
              phone: user.phone,
              avatarUrl: uploadedUrl,
            );
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(success
                  ? 'Tải lên & cập nhật ảnh đại diện thành công!'
                  : 'Lỗi khi lưu ảnh đại diện'),
              backgroundColor: success ? AppColors.success : AppColors.error,
            ),
          );
        }
      } else if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Không thể tải ảnh lên hệ thống lưu trữ. Vui lòng thử lại!'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
  }

  Future<void> _handleRemoveAvatar(UserEntity user) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isUploadingAvatar = true);

    final success = await ref.read(authControllerProvider.notifier).updateProfile(
          fullName: user.fullName,
          phone: user.phone,
          avatarUrl: null,
        );

    setState(() => _isUploadingAvatar = false);

    if (mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(success ? 'Đã gỡ ảnh đại diện' : 'Lỗi khi gỡ ảnh đại diện'),
          backgroundColor: success ? AppColors.primary : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    const totalBookings = 0;

    if (user == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: const Center(child: Text('Chưa đăng nhập')),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: const VehicaBackButton(),
        title: Text(
          'Hồ sơ cá nhân',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileHeaderCard(
                user: user,
                isUploadingAvatar: _isUploadingAvatar,
                isEditing: _isEditing,
                onTapAvatar: () => showProfileAvatarSheet(
                  context,
                  user: user,
                  onPickSource: _handlePickAndUploadAvatar,
                  onRemoveAvatar: () => _handleRemoveAvatar(user),
                ),
                onToggleEdit: () {
                  setState(() {
                    _isEditing = !_isEditing;
                    if (!_isEditing) {
                      _fullNameController.text = user.fullName;
                      _phoneController.text = user.phone;
                    }
                  });
                },
                isDark: isDark,
              ),
              const SizedBox(height: 14),
              ProfileStatsCard(
                totalBookings: totalBookings,
                isDark: isDark,
                onTapBookings: () => context.push('/bookings'),
              ),
              const SizedBox(height: 18),
              ProfileInfoCard(
                user: user,
                fullNameController: _fullNameController,
                phoneController: _phoneController,
                isEditing: _isEditing,
                isSaving: _isSaving,
                onSave: _handleSave,
                isDark: isDark,
              ),
              const SizedBox(height: 18),
              ProfileSecurityTile(
                isDark: isDark,
                onTap: () => context.push('/forgot-password'),
              ),
              const SizedBox(height: 18),
              ProfileLogoutTile(
                isDark: isDark,
                onTap: () => showProfileLogoutDialog(
                  context,
                  onConfirm: () async {
                    await ref.read(authControllerProvider.notifier).logout();
                    if (context.mounted) context.go('/login');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
