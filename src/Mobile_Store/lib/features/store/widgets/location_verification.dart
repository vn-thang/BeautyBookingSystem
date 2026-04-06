import 'package:flutter/material.dart';
import 'package:mobile_store/core/theme/app_spacing.dart';
import 'package:mobile_store/shared/widgets/buttons/app_buttons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class LocationVerification extends StatelessWidget {
  final bool isGettingLocation;
  final double? latitude;
  final double? longitude;
  final VoidCallback onOpenMap;
  final VoidCallback onGetGPS;

  const LocationVerification({
    super.key,
    required this.isGettingLocation,
    this.latitude,
    this.longitude,
    required this.onOpenMap, 
    required this.onGetGPS,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppPrimaryButton(
          isLoading: isGettingLocation,
          onPressed: onOpenMap,
          icon: latitude != null ? Icons.map_rounded : Icons.map,
          text: latitude != null ? "Sửa vị trí trên bản đồ" : "Chọn vị trí trên bản đồ",
          color: latitude != null ? AppColors.success : AppColors.primary,
        ),
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: TextButton.icon(
            onPressed: isGettingLocation ? null : onGetGPS,
            icon: const Icon(Icons.my_location, size: 20),
            label: Text("Hoặc lấy vị trí GPS hiện tại", style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub, fontWeight: FontWeight.w600)),
            style: TextButton.styleFrom(foregroundColor: AppColors.textSub),
          ),
        ),
        if (latitude != null && longitude != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              "📍 Lat: ${latitude!.toStringAsFixed(5)}, Lng: ${longitude!.toStringAsFixed(5)}", 
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSub),
            ),
          ),
      ],
    );
  }
}