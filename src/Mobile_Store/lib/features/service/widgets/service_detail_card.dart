
import 'package:flutter/material.dart';
import '../../../shared/models/service_model.dart';
import '../../../core/utils/formatters.dart'; 
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class ServiceDetailCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ServiceDetailCard({
    super.key,
    required this.service,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
        boxShadow: [
          BoxShadow(color: AppColors.textMain.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimens.paddingMedium),
            decoration: BoxDecoration(
              color: service.isActive == false ? AppColors.background : AppColors.primary.withValues(alpha: 0.1), 
              shape: BoxShape.circle
            ),
            child: Icon(
              Icons.cut, 
              color: service.isActive == false ? AppColors.textSub : AppColors.primary, 
              size: 24
            ),
          ),
          const SizedBox(width: AppDimens.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: AppTextStyles.bodyText.copyWith(
                    color: service.isActive == false ? AppColors.textSub : AppColors.textMain,
                    decoration: service.isActive == false ? TextDecoration.lineThrough : null, 
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 14, color: AppColors.textSub),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${service.durationMinutes} phút', 
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSub)
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                height: 30, width: 30,
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_vert, color: AppColors.textSub),
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit', 
                      child: Row(children: [
                        const Icon(Icons.edit, size: 20, color: AppColors.textMain), 
                        const SizedBox(width: AppSpacing.sm), 
                        Text('Chỉnh sửa', style: AppTextStyles.bodyText)
                      ])
                    ),
                    PopupMenuItem(
                      value: 'delete', 
                      child: Row(children: [
                        const Icon(Icons.delete, size: 20, color: AppColors.error), 
                        const SizedBox(width: AppSpacing.sm), 
                        Text('Xóa dịch vụ', style: AppTextStyles.bodyText.copyWith(color: AppColors.error))
                      ])
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                Formatters.formatCurrency(service.price),
                style: AppTextStyles.bodyText.copyWith(
                  color: service.isActive == false ? AppColors.textSub : AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}