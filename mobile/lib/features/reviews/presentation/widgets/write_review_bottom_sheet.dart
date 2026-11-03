import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/services/vehica_feedback.dart';
import 'package:vehica_mobile/core/widgets/vehica_button.dart';
import 'package:vehica_mobile/features/reviews/domain/entities/review_entity.dart';
import 'package:vehica_mobile/features/reviews/presentation/controllers/review_controller.dart';
import 'package:vehica_mobile/features/vehicles/domain/entities/vehicle_entity.dart';

class WriteReviewBottomSheet extends ConsumerStatefulWidget {
  final VehicleEntity vehicle;
  final ReviewEntity? initialReview;

  const WriteReviewBottomSheet({
    super.key,
    required this.vehicle,
    this.initialReview,
  });

  static Future<bool?> show(
    BuildContext context, {
    required VehicleEntity vehicle,
    ReviewEntity? initialReview,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WriteReviewBottomSheet(
        vehicle: vehicle,
        initialReview: initialReview,
      ),
    );
  }

  @override
  ConsumerState<WriteReviewBottomSheet> createState() => _WriteReviewBottomSheetState();
}

class _WriteReviewBottomSheetState extends ConsumerState<WriteReviewBottomSheet> {
  late int _rating;
  late final TextEditingController _textController;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  final List<String> _ratingLabels = [
    'Rất tệ',
    'Chưa hài lòng',
    'Bình thường',
    'Rất hài lòng',
    'Tuyệt vời xuất sắc',
  ];

  @override
  void initState() {
    super.initState();
    _rating = widget.initialReview?.rating ?? 5;
    _textController = TextEditingController(text: widget.initialReview?.reviewText ?? '');
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    try {
      await ref.read(reviewControllerProvider(widget.vehicle.id).notifier).submitReview(
            rating: _rating,
            reviewText: _textController.text.trim(),
          );

      if (mounted) {
        VehicaFeedback.showSuccess(
          widget.initialReview != null
              ? 'Cập nhật đánh giá thành công!'
              : 'Cảm ơn bạn đã gửi đánh giá cho ${widget.vehicle.name}!',
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        VehicaFeedback.showError('Không thể gửi đánh giá: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isEditing = widget.initialReview != null;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottomInset),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white24 : Colors.black12),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                isEditing ? 'Chỉnh sửa đánh giá' : 'Đánh giá & Nhận xét',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.vehicle.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(height: 20),

              // Interactive 5 Star Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  final isSelected = starIndex <= _rating;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _rating = starIndex);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: AnimatedScale(
                        scale: isSelected ? 1.08 : 0.95,
                        duration: const Duration(milliseconds: 180),
                        child: Icon(
                          isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 38,
                          color: isSelected ? AppColors.accentGold : (isDark ? Colors.white30 : Colors.black26),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),

              // Star label text
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  '$_rating sao — ${_ratingLabels[_rating - 1]}',
                  key: ValueKey(_rating),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Review Text Field
              TextFormField(
                controller: _textController,
                maxLines: 4,
                maxLength: 1000,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Hãy chia sẻ cảm nhận của bạn về khả năng vận hành, độ sạch sẽ và trải nghiệm xe...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textDisabledDark : AppColors.textDisabled,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().length < 5) {
                    return 'Vui lòng nhập nhận xét ít nhất 5 ký tự.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Submit Button
              VehicaButton(
                text: isEditing ? 'Cập nhật đánh giá' : 'Gửi đánh giá',
                icon: Icons.send_rounded,
                isLoading: _isSubmitting,
                type: VehicaButtonType.primary,
                height: 48,
                onPressed: _isSubmitting ? null : _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
