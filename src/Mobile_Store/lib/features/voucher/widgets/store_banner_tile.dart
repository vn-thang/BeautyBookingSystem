import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/store_banner_model.dart';

class StoreBannerTile extends StatelessWidget {
  final StoreBannerModel banner;
  final ValueChanged<bool> onToggleStatus;
  final VoidCallback onDelete;

  const StoreBannerTile({
    super.key, 
    required this.banner, 
    required this.onToggleStatus, 
    required this.onDelete
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
      clipBehavior: Clip.antiAlias, 
      elevation: 2,
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 21 / 9,
            child: Image.network(
              banner.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.surface,
                child: const Icon(Icons.broken_image, color: AppColors.textSub, size: 40),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(AppDimens.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (banner.title != null && banner.title!.isNotEmpty) ...[
                  Text(
                    banner.title!, 
                    style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold, fontSize: 16)
                  ),
                  const SizedBox(height: 4),
                ],
                if (banner.description != null && banner.description!.isNotEmpty) ...[
                  Text(
                    banner.description!, 
                    style: AppTextStyles.labelSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Switch(
                          value: banner.isActive,
                          onChanged: onToggleStatus,
                          activeColor: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          banner.isActive ? 'Đang hiển thị' : 'Đã ẩn',
                          style: AppTextStyles.bodyText.copyWith(
                            color: banner.isActive ? AppColors.success : AppColors.textSub,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error, size: 20),
                      onPressed: onDelete,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}