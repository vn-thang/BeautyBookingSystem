import 'package:flutter/material.dart';
import 'package:mobile_store/features/wallet/screens/store_wallet_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart'; // Thay bằng đường dẫn file Formatters của bạn
import '../../../shared/widgets/cards/stat_item_widget.dart';
import '../models/store_dashboard_model.dart'; 

class CommissionCard extends StatelessWidget {
  final CommissionModel comm;
  
  const CommissionCard({super.key, required this.comm});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0, 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusSmall)),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingMedium),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.pie_chart, color: AppColors.warning, size: 24), 
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Thống kê chi tiêu', 
                      style: AppTextStyles.bodyText.copyWith(fontSize: 16, fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
               GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const StoreWalletScreen())
                    );
                  },
                  child: Text(
                    'Xem tất cả >', 
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w500)
                  )
                ),
              ],
            ),
            const SizedBox(height: AppDimens.paddingLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                StatItemWidget(
                  icon: Icons.monetization_on, 
                  iconColor: AppColors.warning, 
                  value: Formatters.formatCurrency(comm.totalCommission), 
                  label: 'Hoa hồng'
                ),
                StatItemWidget(
                  icon: Icons.phone_android, 
                  iconColor: Colors.blue, 
                  value: Formatters.formatCurrency(comm.appUsageFee), 
                  label: 'Sử dụng app'
                ),
                StatItemWidget(
                  icon: Icons.account_balance, 
                  iconColor: AppColors.error, 
                  value: Formatters.formatCurrency(comm.totalWithdrawn), 
                  label: 'Tổng tiền đã rút'
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}