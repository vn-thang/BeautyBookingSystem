import 'package:flutter/material.dart';
import '../models/store_payment_model.dart';
import '../../../core/utils/formatters.dart';

class PaymentDialogs {
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
            onPressed: () => Navigator.pop(context, transIdController.text.trim()),
            child: const Text('XÁC NHẬN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

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
    return result ?? false; 
  }
}