import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class PendingBanner extends StatelessWidget {
  const PendingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingMedium, 
        vertical: AppDimens.paddingSmall
      ),
      color: AppColors.warning.withValues(alpha: 0.15), 
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Tài khoản đang chờ duyệt. Một số tính năng thống kê tạm thời bị khóa.',
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.warning, 
                fontWeight: FontWeight.w600
              ),
            ),
          ),
        ],
      ),
    );
  }
}