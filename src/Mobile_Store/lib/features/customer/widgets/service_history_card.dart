import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart'; // Áp dụng Formatters
import '../models/customer_profile_model.dart';

class ServiceHistoryCard extends StatelessWidget {
  final CustomerServiceHistoryModel history;

  const ServiceHistoryCard({super.key, required this.history});

 @override
  Widget build(BuildContext context) {
    String displayDate = history.appointmentDate != null 
        ? Formatters.formatDateOnly(history.appointmentDate) 
        : 'Không rõ ngày';

    String displayTime = history.startTime;
    if (displayTime.length >= 5) {
      displayTime = displayTime.substring(0, 5); 
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
        side: BorderSide(color: AppColors.textSub.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                    ),
                    child: Text(
                      '$displayTime - $displayDate',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary, 
                        fontWeight: FontWeight.w600, 
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm), 
                Flexible(
                  child: Text(
                    Formatters.formatCurrency(history.price), 
                    style: AppTextStyles.bodyText.copyWith(
                      fontWeight: FontWeight.bold, 
                      color: AppColors.error,
                    ),
                    textAlign: TextAlign.right, 
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Divider(height: 1, color: AppColors.surface), 
            ),
            
            Text(
              history.serviceName,
              style: AppTextStyles.bodyText.copyWith(
                fontWeight: FontWeight.bold, 
                fontSize: 16,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: AppSpacing.sm), 
            Row(
              children: [
                const Icon(Icons.content_cut, size: 14, color: AppColors.textSub),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Thợ thực hiện: ${history.staffName}',
                    style: AppTextStyles.labelSmall.copyWith(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}