import 'package:flutter/material.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';

class BookingStepProgressBar extends StatelessWidget {
  final int currentStep;
  final bool isDark;

  const BookingStepProgressBar({
    super.key,
    required this.currentStep,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final steps = ['Lịch thuê', 'Xem lại đơn', 'Hoàn tất'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            final stepBefore = index ~/ 2;
            final isPassed = currentStep > stepBefore;
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: isPassed
                    ? AppColors.primary
                    : (isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
            );
          }
          final stepIdx = index ~/ 2;
          final isActive = currentStep == stepIdx;
          final isCompleted = currentStep > stepIdx;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? AppColors.primary
                      : (isActive ? AppColors.primary : Colors.transparent),
                  border: Border.all(
                    color: (isActive || isCompleted)
                        ? AppColors.primary
                        : (isDark ? AppColors.borderDark : AppColors.borderLight),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                      : Text(
                          '${stepIdx + 1}',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? Colors.white
                                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                steps[stepIdx],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                  color: isActive
                      ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
