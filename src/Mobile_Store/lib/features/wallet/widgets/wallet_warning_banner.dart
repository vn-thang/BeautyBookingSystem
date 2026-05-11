import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';

class WalletWarningBanner extends StatelessWidget {
  final double minimumBalance;

  const WalletWarningBanner({super.key, required this.minimumBalance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.error.withValues(alpha: 0.1), 
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Cửa hàng đang bị TẠM ẨN do số dư nhỏ hơn hạn mức tối thiểu (${Formatters.formatCurrency(minimumBalance)}).'
              +'Vui lòng nạp thêm tiền để tiếp tục sử dụng!',
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.error, 
                fontWeight: FontWeight.bold, 
                fontSize: 13
              ),
            ),
          ),
        ],
      ),
    );
  }
}