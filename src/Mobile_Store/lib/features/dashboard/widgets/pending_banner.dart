import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart'; 

enum WarningType { pending, lowBalance }

class DashboardWarningBanner extends StatelessWidget {
  final WarningType type;
  final double? minimumBalance;

  const DashboardWarningBanner({
    super.key, 
    required this.type,
    this.minimumBalance,
  });

  @override
  Widget build(BuildContext context) {
    String message = 'Tài khoản đang chờ duyệt. Một số tính năng thống kê tạm thời bị khóa.';
    Color bgColor = AppColors.warning.withValues(alpha: 0.15);
    Color textColor = AppColors.warning;
    double? fontSize;

    if (type == WarningType.lowBalance) {
      final formattedBalance = Formatters.formatCurrency(minimumBalance ?? 0);
      message = 'Cửa hàng đang bị TẠM ẨN do số dư nhỏ hơn hạn mức tối thiểu ($formattedBalance). Vui lòng nạp thêm tiền!';
      bgColor = AppColors.error.withValues(alpha: 0.1);
      textColor = AppColors.error;
      fontSize = 13.0;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingMedium, 
        vertical: AppDimens.paddingSmall
      ),
      color: bgColor, 
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: textColor),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyText.copyWith(
                color: textColor, 
                fontWeight: type == WarningType.lowBalance ? FontWeight.bold : FontWeight.w600,
                fontSize: fontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}