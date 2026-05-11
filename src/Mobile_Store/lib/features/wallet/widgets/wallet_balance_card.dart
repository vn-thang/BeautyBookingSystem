import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../models/wallet_transaction_model.dart';

class WalletBalanceCard extends StatelessWidget {
  final WalletDashboardModel dashboard; 
  final VoidCallback onTopUpPressed;
  final VoidCallback onWithdrawPressed; 

  const WalletBalanceCard({
    super.key,
    required this.dashboard,
    required this.onTopUpPressed,
    required this.onWithdrawPressed, 
  });

 @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingLarge),
      margin: const EdgeInsets.all(AppDimens.paddingMedium),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          Text('SỐ DƯ HIỆN TẠI', style: AppTextStyles.labelSmall.copyWith(color: AppColors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          // 🎯 Đã thêm FittedBox để thu nhỏ font nếu số dư tỷ phú
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              Formatters.formatCurrency(dashboard.currentBalance), 
              style: AppTextStyles.heading1.copyWith(color: AppColors.white, fontSize: 32),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          
         Container(
            padding: const EdgeInsets.all(AppDimens.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
            ),
            child: Column( // 🎯 Đã đổi từ Row sang Column
              children: [
                _buildStatItem('Tổng nạp tháng', dashboard.totalTopUpThisMonth, true),
                
                // Kẻ ngang phân cách giữa 2 dòng
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Divider(height: 1, color: AppColors.white.withValues(alpha: 0.3)), 
                ),
                
                _buildStatItem('Tổng phí trừ', dashboard.totalFeeThisMonth, false),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: 4), // 🎯 Giảm padding ngang
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusSmall)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  // 🎯 3. Bọc Flexible và FittedBox cho nhãn của nút
                  label: Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('NẠP TIỀN', style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary))
                    ),
                  ),
                  onPressed: onTopUpPressed,
                ),
              ),
              const SizedBox(width: AppSpacing.md), 
              
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: 4), // 🎯 Giảm padding ngang
                    side: const BorderSide(color: AppColors.white),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusSmall)),
                    elevation: 0, 
                  ),
                  icon: const Icon(Icons.account_balance_wallet_outlined, size: 20),
                   // 🎯 4. Bọc Flexible và FittedBox cho nhãn của nút
                  label: Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('RÚT TIỀN', style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold, color: AppColors.white))
                    ),
                  ),
                  onPressed: onWithdrawPressed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🎯 Cập nhật lại _buildStatItem để hỗ trợ căn lề (nếu cần) và bóp nhỏ text
 Widget _buildStatItem(String title, double amount, bool isTopUp) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Nhãn bên trái
        Text(
          title, 
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.white.withValues(alpha: 0.8), fontSize: 13)
        ),
        
        const SizedBox(width: 8), // Khoảng đệm an toàn
        
        // Số tiền bên phải (có FittedBox để tự bóp nếu số quá dài, nhưng giờ có rất nhiều không gian)
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              '${isTopUp ? '+' : '-'}${Formatters.formatCurrency(amount)}',
              style: AppTextStyles.bodyText.copyWith(
                color: isTopUp ? const Color(0xFF69F0AE) : const Color.fromARGB(255, 60, 57, 46), 
                fontSize: 12, // Tăng nhẹ size chữ cho dễ nhìn
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ),
      ],
    );
  }
}