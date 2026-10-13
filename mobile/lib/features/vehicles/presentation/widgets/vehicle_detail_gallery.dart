import 'package:flutter/material.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/widgets/vehica_badge.dart';
import 'package:vehica_mobile/core/widgets/vehica_image.dart';
import 'package:vehica_mobile/features/vehicles/domain/entities/vehicle_entity.dart';

class VehicleDetailGallery extends StatefulWidget {
  final VehicleEntity vehicle;
  final bool isDark;

  const VehicleDetailGallery({
    super.key,
    required this.vehicle,
    required this.isDark,
  });

  @override
  State<VehicleDetailGallery> createState() => _VehicleDetailGalleryState();
}

class _VehicleDetailGalleryState extends State<VehicleDetailGallery> {
  late final PageController _pageController;
  int _activeImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showFullscreenGallery(BuildContext context, List<String> images, int initialIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.95),
      builder: (ctx) {
        int currentIndex = initialIndex;
        final pageCtrl = PageController(initialPage: initialIndex);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: pageCtrl,
                      itemCount: images.length,
                      onPageChanged: (idx) {
                        setModalState(() => currentIndex = idx);
                      },
                      itemBuilder: (context, idx) {
                        return Center(
                          child: InteractiveViewer(
                            minScale: 0.8,
                            maxScale: 4.0,
                            child: VehicaImage(
                              imageUrl: images[idx],
                              fit: BoxFit.contain,
                              fallbackIcon: Icons.directions_car_filled_rounded,
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ),
                    ),
                    if (images.length > 1)
                      Positioned(
                        bottom: 24,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${currentIndex + 1} / ${images.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = widget.vehicle;
    final isDark = widget.isDark;
    final images = <String>{
      if (vehicle.primaryImageUrl != null && vehicle.primaryImageUrl!.isNotEmpty)
        vehicle.primaryImageUrl!,
      ...vehicle.images.map((img) => img.imageUrl),
    }.toList();

    return Column(
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned.fill(
                child: images.isNotEmpty
                    ? PageView.builder(
                        controller: _pageController,
                        itemCount: images.length,
                        onPageChanged: (idx) => setState(() => _activeImageIndex = idx),
                        itemBuilder: (context, idx) {
                          return GestureDetector(
                            onTap: () => _showFullscreenGallery(context, images, idx),
                            child: VehicaImage(
                              imageUrl: images[idx],
                              fit: BoxFit.cover,
                              fallbackIcon: Icons.directions_car_filled_rounded,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                        child: Icon(
                          Icons.directions_car_filled_rounded,
                          color: isDark ? AppColors.textDisabledDark : AppColors.textDisabled,
                          size: 72,
                        ),
                      ),
              ),

              // Top-Left Badges (Real Category Badge from DB)
              Positioned(
                top: 12,
                left: 12,
                child: VehicaBadge.subtle(
                  label: vehicle.type.name,
                  color: AppColors.primary,
                ),
              ),

              // Image dots indicator
              if (images.length > 1)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${_activeImageIndex + 1}/${images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Image Thumbnails (if multiple)
        if (images.length > 1) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final isSel = _activeImageIndex == idx;
                return GestureDetector(
                  onTap: () {
                    setState(() => _activeImageIndex = idx);
                    if (_pageController.hasClients) {
                      _pageController.animateToPage(
                        idx,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Container(
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSel
                            ? AppColors.primaryLight
                            : (isDark ? AppColors.borderDark : AppColors.borderLight),
                        width: isSel ? 2 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: VehicaImage(
                      imageUrl: images[idx],
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.directions_car_rounded,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
