import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart'; 
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../store/screens/update_profile_screen.dart';
import '../models/store_dashboard_model.dart'; 

class DashboardHeader extends StatelessWidget {
  final StoreHeaderModel header;
  
  const DashboardHeader({super.key, required this.header});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppDimens.radiusLarge)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UpdateProfileScreen()),
          );
        },
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + AppDimens.paddingLarge + 10, 
            left: AppDimens.paddingMedium, 
            right: AppDimens.paddingMedium, 
            bottom: AppDimens.paddingLarge + 10
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                child: Container(
                  width: 55, height: 55, color: Colors.white24,
                  child: (header.logoUrl != null && header.logoUrl!.isNotEmpty)
                      ? Image.network(
                          header.logoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Icon(Icons.store, color: AppColors.white, size: 30),
                        )
                      : const Icon(Icons.store, color: AppColors.white, size: 30),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            header.name.isNotEmpty ? header.name : 'Chưa cập nhật tên', 
                            style: AppTextStyles.bodyText.copyWith(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 14), 
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Địa chỉ: ${header.address.isNotEmpty ? header.address : "Chưa cập nhật"}', 
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.white.withValues(alpha: 0.9), fontSize: 13), 
                      maxLines: 1, overflow: TextOverflow.ellipsis
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}