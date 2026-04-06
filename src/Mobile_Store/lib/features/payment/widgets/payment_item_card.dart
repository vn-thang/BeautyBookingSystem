// import 'package:flutter/material.dart';
// import '../models/store_payment_model.dart';
// import '../../../core/utils/formatters.dart';

// class PaymentItemCard extends StatelessWidget {
//   final StorePaymentModel payment;
//   final bool isPending;
//   final bool isSuccess;
//   final VoidCallback? onConfirm;
//   final VoidCallback? onRefund;

//   const PaymentItemCard({
//     super.key,
//     required this.payment,
//     this.isPending = false,
//     this.isSuccess = false,
//     this.onConfirm,
//     this.onRefund,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isOnline = payment.paymentMethod.toLowerCase().contains('vnpay') || payment.paymentMethod.toLowerCase().contains('bank');

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
//         boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text('Mã đơn: #${payment.bookingId}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(color: isOnline ? Colors.blue.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
//                 child: Row(
//                   children: [
//                     Icon(isOnline ? Icons.account_balance : Icons.payments, size: 14, color: isOnline ? Colors.blue : Colors.green),
//                     const SizedBox(width: 4),
//                     Text(payment.paymentMethod, style: TextStyle(fontSize: 12, color: isOnline ? Colors.blue : Colors.green, fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Text(payment.customerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 4),
//           Text(Formatters.currency.format(payment.amount), style: const TextStyle(fontSize: 18, color: Color(0xFFDE4660), fontWeight: FontWeight.bold)),
          
//           if (payment.paidAt != null) ...[
//             const SizedBox(height: 4),
//             Text('Đã thanh toán: ${Formatters.dateTime.format(payment.paidAt!)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
//           ],
//           if (payment.transactionId != null && payment.transactionId!.isNotEmpty) ...[
//             const SizedBox(height: 4),
//             Text('Mã GD: ${payment.transactionId}', style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
//           ],

//           if (isPending || isSuccess) ...[
//             const Divider(height: 24),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 if (isPending && onConfirm != null)
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
//                     onPressed: onConfirm,
//                     child: const Text('XÁC NHẬN THU', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                   ),
//                 if (isSuccess && onRefund != null)
//                   OutlinedButton(
//                     style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
//                     onPressed: onRefund,
//                     child: const Text('HOÀN TIỀN'),
//                   ),
//               ],
//             )
//           ]
//         ],
//       ),
//     );
//   }
// }

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
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium), // Bo góc mềm mại hơn
        border: Border.all(color: AppColors.surface.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04), // Bóng đổ mượt và nhạt hơn
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Header (Mã đơn + Hình thức thanh toán)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mã đơn: #${payment.bookingId}', 
                style: AppTextStyles.bodyText.copyWith(
                  fontWeight: FontWeight.bold, 
                  color: AppColors.textSub,
                )
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isOnline ? Colors.blue.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1), 
                  borderRadius: BorderRadius.circular(20), // Dạng pill (bo tròn hẳn) đẹp hơn
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
          
          // Row 2: Khách hàng & Số tiền
          Text(
            payment.customerName, 
            style: AppTextStyles.bodyText.copyWith(fontSize: 16, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            Formatters.formatCurrency(payment.amount), 
            style: AppTextStyles.heading1.copyWith(fontSize: 18, color: AppColors.primary)
          ),
          
          // Row 3: Các thông tin phụ (Mã GD, Ngày) được gom vào khối nền xám
          if (payment.paidAt != null || (payment.transactionId != null && payment.transactionId!.isNotEmpty)) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimens.paddingSmall),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.05), // Nền xám nhạt để tách biệt thông tin
                borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (payment.paidAt != null)
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: AppColors.textSub),
                        const SizedBox(width: 4),
                        Text(
                          'Đã thanh toán: ${Formatters.formatDateTime(payment.paidAt!)}', 
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSub)
                        ),
                      ],
                    ),
                  if (payment.transactionId != null && payment.transactionId!.isNotEmpty) ...[
                    if (payment.paidAt != null) const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.receipt_long, size: 14, color: AppColors.textSub),
                        const SizedBox(width: 4),
                        Text(
                          'Mã GD: ${payment.transactionId}', 
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMain, fontWeight: FontWeight.bold)
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Row 4: Hành động (Nút bấm)
          if (isPending || isSuccess) ...[
            const Divider(height: 24, color: AppColors.surface),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isPending && onConfirm != null)
                  SizedBox(
                    height: 35, // Chỉnh cao lên 1 tí xíu cho dễ bấm
                    width: 170, // TĂNG WIDTH LÊN 160 ĐỂ CHỮ KHÔNG RỚT DÒNG
                    child: AppPrimaryButton(
                      text: 'XÁC NHẬN THU',
                      onPressed: onConfirm,
                    ),
                  ),
                if (isSuccess && onRefund != null)
                  SizedBox(
                    height: 35,
                    width: 140, // Tăng width dự phòng cho nút hoàn tiền
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