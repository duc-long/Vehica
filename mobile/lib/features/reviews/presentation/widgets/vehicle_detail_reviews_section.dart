import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/services/vehica_feedback.dart';
import 'package:vehica_mobile/core/widgets/vehica_image.dart';
import 'package:vehica_mobile/core/widgets/vehica_skeleton.dart';
import 'package:vehica_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:vehica_mobile/features/reviews/domain/entities/review_entity.dart';
import 'package:vehica_mobile/features/reviews/presentation/controllers/review_controller.dart';
import 'package:vehica_mobile/features/reviews/presentation/widgets/write_review_bottom_sheet.dart';
import 'package:vehica_mobile/features/vehicles/domain/entities/vehicle_entity.dart';

class VehicleDetailReviewsSection extends ConsumerWidget {
  final VehicleEntity vehicle;
  final bool isDark;

  const VehicleDetailReviewsSection({
    super.key,
    required this.vehicle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewState = ref.watch(reviewControllerProvider(vehicle.id));
    final summary = reviewState.summary;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Title & Write Review Button ──────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'Đánh giá & Nhận xét',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (summary != null && summary.totalReviews > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 14, color: AppColors.accentGold),
                            const SizedBox(width: 3),
                            Text(
                              summary.averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.accentGold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Button to open write review
              TextButton.icon(
                onPressed: () => _handleWriteReview(context, ref, reviewState),
                icon: Icon(
                  reviewState.myReview != null ? Icons.edit_outlined : Icons.rate_review_outlined,
                  size: 16,
                  color: AppColors.primaryLight,
                ),
                label: Text(
                  reviewState.myReview != null ? 'Sửa đánh giá' : 'Viết đánh giá',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Rental Verified Trust Notice ──────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceVariantDark.withValues(alpha: 0.5)
                  : AppColors.surfaceVariantLight.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded, size: 14, color: AppColors.primaryLight),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Đánh giá được xác thực từ khách hàng đã thuê xe này',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Summary Score & Star Breakdown Bar ──────────────────────────────
          if (reviewState.isLoading && summary == null)
            const VehicaSkeleton(width: double.infinity, height: 90)
          else if (summary != null && summary.totalReviews > 0)
            _buildRatingSummary(summary)
          else
            _buildEmptyState(context),

          // ── Reviews List ───────────────────────────────────────────────────
          if (reviewState.reviews.isNotEmpty) ...[
            const SizedBox(height: 16),
            Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
            const SizedBox(height: 14),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviewState.reviews.length,
              separatorBuilder: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(
                  height: 1,
                  color: isDark ? AppColors.borderDark.withValues(alpha: 0.5) : AppColors.borderLight,
                ),
              ),
              itemBuilder: (context, index) {
                final review = reviewState.reviews[index];
                return _ReviewItemTile(
                  review: review,
                  isDark: isDark,
                  isMyReview: review.id == reviewState.myReview?.id,
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingSummary(ReviewSummaryEntity summary) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Average Score Box
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                summary.averageRating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  letterSpacing: -1,
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < summary.averageRating.round() ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 15,
                    color: AppColors.accentGold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${summary.totalReviews} lượt đánh giá',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),

          // Rating Breakdown Bars
          Expanded(
            child: Column(
              children: List.generate(5, (index) {
                final star = 5 - index;
                final count = summary.ratingCounts[star] ?? 0;
                final ratio = summary.totalReviews > 0 ? count / summary.totalReviews : 0.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.5),
                  child: Row(
                    children: [
                      Text(
                        '$star',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(Icons.star_rounded, size: 11, color: AppColors.accentGold),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 5.5,
                            backgroundColor: isDark ? Colors.white10 : Colors.black12,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentGold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 18,
                        child: Text(
                          '$count',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? AppColors.textDisabledDark : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark.withValues(alpha: 0.5) : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 32,
            color: isDark ? AppColors.textDisabledDark : AppColors.textDisabled,
          ),
          const SizedBox(height: 8),
          Text(
            'Chưa có đánh giá nào cho xe này',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Hãy thuê xe và trở thành người đầu tiên chia sẻ cảm nhận!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _handleWriteReview(BuildContext context, WidgetRef ref, ReviewState reviewState) {
    final authState = ref.read(authControllerProvider);
    if (!authState.isAuthenticated) {
      VehicaFeedback.showInfo('Vui lòng đăng nhập để viết đánh giá.');
      return;
    }

    // Nếu người dùng đã từng review rồi -> cho phép sửa
    if (reviewState.myReview != null) {
      WriteReviewBottomSheet.show(
        context,
        vehicle: vehicle,
        initialReview: reviewState.myReview,
      );
      return;
    }

    // Nếu người dùng chưa từng hoàn thành chuyến đi -> hiển thị modal thông báo quy định
    if (reviewState.eligibility != null && !reviewState.eligibility!.eligible) {
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: AppColors.primaryLight,
              size: 32,
            ),
          ),
          title: Text(
            'Quy định đánh giá xe',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          content: Text(
            'Để đảm bảo tính trung thực và khách quan, chỉ những khách hàng đã thuê và hoàn tất chuyến đi với chiếc xe này mới có thể viết đánh giá & nhận xét.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text(
                'Đã hiểu',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryLight,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    WriteReviewBottomSheet.show(
      context,
      vehicle: vehicle,
      initialReview: reviewState.myReview,
    );
  }
}

class _ReviewItemTile extends StatelessWidget {
  final ReviewEntity review;
  final bool isDark;
  final bool isMyReview;

  const _ReviewItemTile({
    required this.review,
    required this.isDark,
    required this.isMyReview,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User Info & Stars Header
        Row(
          children: [
            // User Avatar
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              clipBehavior: Clip.antiAlias,
              child: review.userAvatarUrl != null && review.userAvatarUrl!.isNotEmpty
                  ? VehicaImage(
                      imageUrl: review.userAvatarUrl!,
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.person_rounded,
                    )
                  : Center(
                      child: Text(
                        review.userFullName.isNotEmpty ? review.userFullName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 10),

            // User Name & Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          review.userFullName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isMyReview) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Bạn',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    dateFormat.format(review.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textDisabledDark : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Stars
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  i < review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 15,
                  color: AppColors.accentGold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Review Text
        Text(
          review.reviewText,
          style: TextStyle(
            fontSize: 13,
            height: 1.45,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
