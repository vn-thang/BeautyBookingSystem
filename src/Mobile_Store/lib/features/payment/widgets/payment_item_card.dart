import 'package:flutter/material.dart';
import '../models/store_payment_model.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/buttons/app_buttons.dart';

class PaymentItemCard extends StatelessWidget {
  final StorePaymentModel payment;
  final bool isPending;
  final bool isSuccess;
  final VoidCallback? onConfirm;
  final VoidCallback? onRefund;

  const PaymentItemCard({
    super.key,
    required this.payment,
    this.isPending = false,
    this.isSuccess = false,
    this.onConfirm,
    this.onRefund,
  });

@override
  Widget build(BuildContext context) {
    final isOnline = payment.paymentMethod.toLowerCase().contains('vnpay') || 
                     payment.paymentMethod.toLowerCase().contains('bank');

    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium), 
        border: Border.all(color: AppColors.surface.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04), 
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Mã đơn: #${payment.bookingId}', 
                  style: AppTextStyles.bodyText.copyWith(
                    fontWeight: FontWeight.bold, 
                    color: AppColors.textSub,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8), 
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isOnline ? Colors.blue.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1), 
                  borderRadius: BorderRadius.circular(20), 
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOnline ? Icons.account_balance : Icons.payments, 
                      size: 14, 
                      color: isOnline ? Colors.blue : AppColors.success
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      payment.paymentMethod, 
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isOnline ? Colors.blue : AppColors.success, 
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          Text(
            payment.customerName, 
            style: AppTextStyles.bodyText.copyWith(fontSize: 16, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            Formatters.formatCurrency(payment.amount), 
            style: AppTextStyles.heading1.copyWith(fontSize: 18, color: AppColors.primary)
          ),
          
          if (payment.paidAt != null || (payment.transactionId != null && payment.transactionId!.isNotEmpty)) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimens.paddingSmall),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.05), 
                borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (payment.paidAt != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2), 
                          child: Icon(Icons.access_time, size: 14, color: AppColors.textSub),
                        ),
                        const SizedBox(width: 4),
                       
                        Expanded(
                          child: Text(
                            'Đã thanh toán: ${Formatters.formatDateTime(payment.paidAt!)}', 
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSub)
                          ),
                        ),
                      ],
                    ),
                  if (payment.transactionId != null && payment.transactionId!.isNotEmpty) ...[
                    if (payment.paidAt != null) const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start, // 🎯 Căn trên
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(Icons.receipt_long, size: 14, color: AppColors.textSub),
                        ),
                        const SizedBox(width: 4),
                       
                        Expanded(
                          child: Text(
                            'Mã GD: ${payment.transactionId}', 
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMain, fontWeight: FontWeight.bold)
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],

          if (isPending || isSuccess) ...[
            const Divider(height: 24, color: AppColors.surface),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isPending && onConfirm != null)
                  SizedBox(
                    height: 35, 
                    width: 170, 
                    child: AppPrimaryButton(
                      text: 'XÁC NHẬN THU',
                      onPressed: onConfirm,
                    ),
                  ),
                if (isSuccess && onRefund != null)
                  SizedBox(
                    height: 35,
                    width: 140, 
                    child: AppOutlineButton(
                      text: 'HOÀN TIỀN',
                      onTap: onRefund!, 
                    ),
                  ),
              ],
            )
          ]
        ],
      ),
    );
  }
}