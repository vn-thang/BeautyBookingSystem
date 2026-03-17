// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../models/store_payment_model.dart';

// class PaymentDialogs {
//   static void showConfirmDialog(BuildContext context, StorePaymentModel payment, Function(String) onConfirm) {
//     final TextEditingController transIdController = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Xác nhận thu tiền', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Xác nhận thu ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(payment.amount)} từ khách ${payment.customerName}?'),
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
//             onPressed: () {
//               Navigator.pop(context);
//               onConfirm(transIdController.text.trim());
//             },
//             child: const Text('XÁC NHẬN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//           ),
//         ],
//       ),
//     );
//   }

//   static void showRefundDialog(BuildContext context, StorePaymentModel payment, VoidCallback onRefund) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Xác nhận hoàn tiền', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
//         content: Text('Bạn có chắc chắn hoàn tiền cho đơn #${payment.bookingId}?'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('HỦY', style: TextStyle(color: Colors.grey))),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () {
//               Navigator.pop(context);
//               onRefund();
//             },
//             child: const Text('HOÀN TIỀN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../models/store_payment_model.dart';
import '../../../core/utils/formatters.dart';

class PaymentDialogs {
  // Đổi thành Future<String?> để trả mã giao dịch về
  static Future<String?> showConfirmDialog(BuildContext context, StorePaymentModel payment) async {
    final TextEditingController transIdController = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận thu tiền', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Xác nhận thu ${Formatters.currency.format(payment.amount)} từ khách ${payment.customerName}?'),
            const SizedBox(height: 12),
            TextFormField(
              controller: transIdController,
              decoration: InputDecoration(
                labelText: 'Mã giao dịch (Nếu chuyển khoản)',
                hintText: 'VD: MB123456789',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('HỦY', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            // Truyền Text về khi gọi lệnh đóng màn hình
            onPressed: () => Navigator.pop(context, transIdController.text.trim()),
            child: const Text('XÁC NHẬN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Đổi thành Future<bool>
  static Future<bool> showRefundDialog(BuildContext context, StorePaymentModel payment) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hoàn tiền', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc chắn hoàn tiền cho đơn #${payment.bookingId}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('HỦY', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('HOÀN TIỀN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    // Nếu ấn ra ngoài popup để đóng thì result là null -> trả về false
    return result ?? false; 
  }
}