import 'package:flutter/material.dart';
import 'package:mobile_store/shared/widgets/buttons/app_buttons.dart';
import 'package:mobile_store/shared/widgets/feedback/snackbar_helper.dart';
import 'package:mobile_store/shared/widgets/inputs/app_text_field.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class WalletDialogs {
  static Future<double?> showTopUpDialog(BuildContext context) async {
    final TextEditingController amountController = TextEditingController();
    double? selectedAmount;

    return showDialog<double>(
      context: context,
      barrierDismissible: true, 
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Widget buildQuickAmountBtn(double amount) {
              final isSelected = selectedAmount == amount;
              return OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.white,
                  side: BorderSide(color: isSelected ? AppColors.primary : AppColors.surface),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusSmall)),
                
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onPressed: () {
                  setState(() {
                    selectedAmount = amount;
                    amountController.text = amount.toInt().toString();
                  });
                },
                child: Text(
                  Formatters.formatCurrency(amount),
                  style: AppTextStyles.bodyText.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textMain,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13, 
                  ),
                ),
              );
            }

            return AlertDialog(
              backgroundColor: AppColors.white,
            
              scrollable: true, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusLarge)),
              title: Text('Nạp tiền vào ví', style: AppTextStyles.heading1.copyWith(fontSize: 20)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Chọn số tiền nạp nhanh:', style: AppTextStyles.bodyText),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      buildQuickAmountBtn(100000),
                      buildQuickAmountBtn(200000),
                      buildQuickAmountBtn(500000),
                      buildQuickAmountBtn(1000000),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: amountController,
                    label: 'Số tiền',
                    hint: 'Nhập số tiền...', 
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                   
                      if (selectedAmount != null) {
                        setState(() => selectedAmount = null); 
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('HỦY', style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub, fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  width: 120, 
                  child: AppPrimaryButton(
                    text: 'TIẾP TỤC',
                    onPressed: () {
                      final amount = double.tryParse(amountController.text.trim()) ?? 0;
                      if (amount >= 10000) {
                        Navigator.pop(context, amount);
                      } else {
                        SnackBarHelper.showError(context, 'Số tiền nạp tối thiểu là 10.000 VNĐ');
                      }
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}