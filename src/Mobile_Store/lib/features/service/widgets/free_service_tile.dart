import 'package:flutter/material.dart';
import '../../../shared/models/service_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';

class FreeServiceTile extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onTap;

  const FreeServiceTile({
    super.key,
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isActive = service.isActive;
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.paddingSmall),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5, offset: const Offset(0, 2))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium, vertical: AppDimens.paddingSmall),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
          child: Image.network(
            (service.imageUrl != null && service.imageUrl!.isNotEmpty) 
                ? service.imageUrl! 
                : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(service.name)}&background=random', 
            width: 50, height: 50, fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 50, height: 50, color: AppColors.background, 
              child: const Icon(Icons.image, color: AppColors.textSub, size: 20)
            ),
          ),
        ),
        title: Text(
          service.name, 
          style: AppTextStyles.labelSmall.copyWith(
            color: isActive ? AppColors.textMain : AppColors.textSub
          )
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${service.price.toInt()} đ', 
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)
            ),
            if (!isActive) 
              Text(
                'Đang tạm ẩn', 
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.error, fontStyle: FontStyle.italic)
              ),
          ],
        ),
        trailing: const Icon(Icons.edit_outlined, color: AppColors.textSub, size: 20),
        onTap: onTap,
      ),
    );
  }
}