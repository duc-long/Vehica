import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/widgets/vehica_button.dart';

class HomeFleetCtaBanner extends StatelessWidget {
  const HomeFleetCtaBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.sizeOf(context).width;
        final isNarrow = screenWidth < 360;
        final isVeryNarrow = screenWidth < 280;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            isVeryNarrow ? 10 : (isNarrow ? 14 : 20),
            4,
            isVeryNarrow ? 10 : (isNarrow ? 14 : 20),
            100,
          ),
          child: Container(
            padding: EdgeInsets.all(isNarrow ? 14 : 20),
            decoration: BoxDecoration(
              color: const Color(0xFF132228),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.antiAlias,
              children: [
                // Faded background car watermark icon on right side - never takes horizontal flex space!
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Icon(
                    Icons.directions_car_filled_rounded,
                    size: isNarrow ? 70 : 84,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Khám phá hơn 50+ mẫu xe',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Từ sedan tiện lợi đến SUV sang trọng đáp ứng mọi hành trình.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: isNarrow ? double.infinity : 180),
                      child: VehicaButton(
                        text: 'Xem toàn bộ xe',
                        trailingIcon: Icons.arrow_forward_rounded,
                        height: 40,
                        fontSize: 13,
                        padding: EdgeInsets.symmetric(horizontal: isNarrow ? 12 : 18),
                        borderRadius: 12,
                        type: VehicaButtonType.secondary,
                        onPressed: () => context.push('/vehicles'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
