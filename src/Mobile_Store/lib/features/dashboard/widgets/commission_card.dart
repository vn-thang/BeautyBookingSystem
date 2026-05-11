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
            // 🎯 CỤM TIÊU ĐỀ: Bấm được toàn dải, bỏ chữ thay bằng Icon >>
            InkWell(
              onTap: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const StoreWalletScreen())
                );
              },
              borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0), // Padding dọc 12 cho dễ bấm
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.pie_chart, color: AppColors.warning, size: 24), 
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Thống kê chi tiêu', 
                              style: AppTextStyles.bodyText.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Chỉ để lại icon mũi tên kép
                    const Icon(Icons.keyboard_double_arrow_right, color: AppColors.textSub, size: 24),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppDimens.paddingLarge),
            
            // 🎯 CỤM 3 CỘT: Đã tăng SizedBox width lên 16 để chữ không bị dính vào nhau
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: StatItemWidget(
                    icon: Icons.monetization_on, 
                    iconColor: AppColors.warning, 
                    value: Formatters.formatCurrency(comm.totalCommission), 
                    label: 'Hoa hồng'
                  ),
                ),
                const SizedBox(width: 12), // Tăng khoảng cách lên 16 cho thoáng
                Expanded(
                  child: StatItemWidget(
                    icon: Icons.phone_android, 
                    iconColor: Colors.blue, 
                    value: Formatters.formatCurrency(comm.appUsageFee), 
                    label: 'Sử dụng app'
                  ),
                ),
                const SizedBox(width: 12), // Tăng khoảng cách lên 16 cho thoáng
                Expanded(
                  child: StatItemWidget(
                    icon: Icons.account_balance, 
                    iconColor: AppColors.error, 
                    value: Formatters.formatCurrency(comm.totalWithdrawn), 
                    label: 'Tổng tiền đã rút'
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