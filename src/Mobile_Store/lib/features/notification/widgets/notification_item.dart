import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../../../core/utils/formatters.dart'; 
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationItem({super.key, required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium, vertical: AppDimens.paddingSmall),
      tileColor: isRead ? AppColors.white : AppColors.primary.withValues(alpha: 0.05), 
      leading: CircleAvatar(
        backgroundColor: isRead ? AppColors.surface : AppColors.primary.withValues(alpha: 0.1),
        child: Icon(
          Icons.notifications, 
          color: isRead ? AppColors.textSub : AppColors.primary
        ),
      ),
      title: Text(
        notification.title,
        style: AppTextStyles.bodyText.copyWith(
          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          color: isRead ? AppColors.textMain.withValues(alpha: 0.8) : AppColors.textMain,
          fontSize: 15,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            notification.message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyText.copyWith(
              color: isRead ? AppColors.textSub : AppColors.textMain,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            Formatters.formatDateTime(notification.createdAt),
            style: AppTextStyles.labelSmall,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}