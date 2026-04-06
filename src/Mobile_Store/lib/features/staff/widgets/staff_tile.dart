import 'package:flutter/material.dart';
import '../models/staff_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class StaffTile extends StatelessWidget {
  final StaffModel staff;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const StaffTile({
    super.key,
    required this.staff,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvatar = staff.avatarUrl != null && staff.avatarUrl!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium, vertical: AppSpacing.sm),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: AppColors.surface,
          backgroundImage: hasAvatar
              ? NetworkImage(staff.avatarUrl!)
              : NetworkImage('https://ui-avatars.com/api/?name=${staff.fullName}&background=random'),
          onBackgroundImageError: (_, _) {}, 
        ),
        title: Text(
          staff.fullName,
          style: AppTextStyles.bodyText.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: staff.isActive ? AppColors.textMain : AppColors.textSub,
            decoration: staff.isActive ? TextDecoration.none : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Wrap(
            spacing: AppSpacing.sm, 
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  staff.position,
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
              if (!staff.isActive)
                Text(
                  'Đã nghỉ/Ẩn', 
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.error, fontStyle: FontStyle.italic)
                ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
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
                  Text('Sửa thông tin', style: AppTextStyles.bodyText)
                ]
              )
            ),
            PopupMenuItem(
              value: 'delete', 
              child: Row(
                children: [
                  const Icon(Icons.delete, color: AppColors.error, size: 20), 
                  const SizedBox(width: AppSpacing.sm), 
                  Text('Xóa/Ẩn', style: AppTextStyles.bodyText.copyWith(color: AppColors.error))
                ]
              )
            ),
          ],
          icon: const Icon(Icons.more_vert, color: AppColors.textSub),
        ),
      ),
    );
  }
}