// import 'package:flutter/material.dart';
// import '../models/store_payment_model.dart';
// import '../../../core/utils/formatters.dart';

// class PaymentDialogs {
//   static Future<String?> showConfirmDialog(BuildContext context, StorePaymentModel payment) async {
//     final TextEditingController transIdController = TextEditingController();
    
//     return showDialog<String>(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Xác nhận thu tiền', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Xác nhận thu ${Formatters.currency.format(payment.amount)} từ khách ${payment.customerName}?'),
//             const SizedBox(height: 12),
//             TextFormField(
//               controller: transIdController,
//               decoration: InputDecoration(
//                 labelText: 'Mã giao dịch (Nếu chuyển khoản)',
//                 hintText: 'VD: MB123456789',
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('HỦY', style: TextStyle(color: Colors.grey))),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//             onPressed: () => Navigator.pop(context, transIdController.text.trim()),
//             child: const Text('XÁC NHẬN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//           ),
//         ],
//       ),
//     );
//   }

//   static Future<bool> showRefundDialog(BuildContext context, StorePaymentModel payment) async {
//     final result = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Xác nhận hoàn tiền', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
//         content: Text('Bạn có chắc chắn hoàn tiền cho đơn #${payment.bookingId}?'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('HỦY', style: TextStyle(color: Colors.grey))),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('HOÀN TIỀN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//           ),
//         ],
//       ),
//     );
//     return result ?? false; 
//   }
// }


import 'package:flutter/material.dart';
import '../models/store_payment_model.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/buttons/app_buttons.dart';

class PaymentDialogs {
  static Future<String?> showConfirmDialog(BuildContext context, StorePaymentModel payment) async {
    final TextEditingController transIdController = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
        title: Text(
          'Xác nhận thu tiền', 
          style: AppTextStyles.heading1.copyWith(color: AppColors.primary, fontSize: 18)
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xác nhận thu ${Formatters.formatCurrency(payment.amount)} từ khách ${payment.customerName}?',
              style: AppTextStyles.bodyText,
            ),
            const SizedBox(height: AppSpacing.xl),
            
            AppTextField(
              label: 'Mã giao dịch',
              hint: 'VD: MB123456789 (Tùy chọn)',
              icon: Icons.receipt_long_outlined,
              controller: transIdController,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text('HỦY', style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub, fontWeight: FontWeight.bold))
          ),
          SizedBox(
            width: 140,
            child: AppPrimaryButton(
              text: 'XÁC NHẬN',
              onPressed: () => Navigator.pop(context, transIdController.text.trim()),
            ),
          ),
        ],
      ),
    );
  }

  static Future<bool> showRefundDialog(BuildContext context, StorePaymentModel payment) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
        title: Text(
          'Xác nhận hoàn tiền', 
          style: AppTextStyles.heading1.copyWith(color: AppColors.error, fontSize: 18)
        ),
        content: Text(
          'Bạn có chắc chắn hoàn tiền cho đơn #${payment.bookingId}?',
          style: AppTextStyles.bodyText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: Text('HỦY', style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub, fontWeight: FontWeight.bold))
          ),
          SizedBox(
            width: 140,
            child: AppPrimaryButton(
              text: 'HOÀN TIỀN',
              // Nếu bạn có AppErrorButton cho hành động nguy hiểm, có thể thay ở đây
              color: AppColors.error, 
              onPressed: () => Navigator.pop(context, true),
            ),
          ),
        ],
      ),
    );
    return result ?? false; 
  }
}