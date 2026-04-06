import 'package:flutter/material.dart';
import '../models/service_group_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class ServiceGroupCard extends StatelessWidget {
  final ServiceGroupModel group;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const ServiceGroupCard({
    super.key,
    required this.group,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.textMain.withValues(alpha: 0.03),
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.paddingMedium),
            child: Row(
              children: [
                ClipOval(
                  child: Image.network(
                    'https://picsum.photos/100', 
                    width: 50, 
                    height: 50, 
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 50, 
                      height: 50, 
                      color: AppColors.surface, 
                      child: const Icon(Icons.image, color: AppColors.textSub)
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name, 
                        style: AppTextStyles.bodyText.copyWith(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold
                        )
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Số dịch vụ: ${group.services.length}', 
                        style: AppTextStyles.labelSmall
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit', 
                      child: Row(
                        children: [
                          const Icon(Icons.edit, size: 20, color: AppColors.textMain), 
                          const SizedBox(width: AppSpacing.sm), 
                          Text('Sửa nhóm', style: AppTextStyles.bodyText)
                        ]
                      )
                    ),
                    PopupMenuItem(
                      value: 'delete', 
                      child: Row(
                        children: [
                          const Icon(Icons.delete, color: AppColors.error, size: 20), 
                          const SizedBox(width: AppSpacing.sm), 
                          Text(
                            'Xóa nhóm', 
                            style: AppTextStyles.bodyText.copyWith(color: AppColors.error)
                          )
                        ]
                      )
                    ),
                  ],
                  icon: const Icon(Icons.more_vert, color: AppColors.textSub),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}