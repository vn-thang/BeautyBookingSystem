import 'package:flutter/material.dart';
import 'package:mobile_store/shared/widgets/buttons/app_buttons.dart';
import '../models/notification_model.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';

class NotificationDetailSheet extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailSheet({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppDimens.paddingLarge, 
        right: AppDimens.paddingLarge, 
        top: AppDimens.paddingLarge, 
        bottom: MediaQuery.of(context).padding.bottom + AppDimens.paddingLarge
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 5,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.textSub.withValues(alpha: 0.3), 
                borderRadius: BorderRadius.circular(10)
              ),
            ),
          ),
          
          Text(
            notification.title, 
            style: AppTextStyles.heading1.copyWith(fontSize: 18)
          ),
          const SizedBox(height: AppSpacing.sm),
          
          Text(
            Formatters.formatDateTime(notification.createdAt),
            style: AppTextStyles.labelSmall,
          ),
          
          const Divider(height: 30, color: AppColors.surface),

          Flexible(
            child: SingleChildScrollView(
              child: Text(
                notification.message,
                style: AppTextStyles.bodyText.copyWith(fontSize: 15, height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.paddingLarge),
          
          AppPrimaryButton(
            text: 'Đóng',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}