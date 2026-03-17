import 'package:flutter/material.dart';
import '../models/store_payment_model.dart';
import '../../../core/utils/formatters.dart';

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
    final isOnline = payment.paymentMethod.toLowerCase().contains('vnpay') || payment.paymentMethod.toLowerCase().contains('bank');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mã đơn: #${payment.bookingId}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: isOnline ? Colors.blue.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                child: Row(
                  children: [
                    Icon(isOnline ? Icons.account_balance : Icons.payments, size: 14, color: isOnline ? Colors.blue : Colors.green),
                    const SizedBox(width: 4),
                    Text(payment.paymentMethod, style: TextStyle(fontSize: 12, color: isOnline ? Colors.blue : Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(payment.customerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(Formatters.currency.format(payment.amount), style: const TextStyle(fontSize: 18, color: Color(0xFFDE4660), fontWeight: FontWeight.bold)),
          
          if (payment.paidAt != null) ...[
            const SizedBox(height: 4),
            Text('Đã thanh toán: ${Formatters.dateTime.format(payment.paidAt!)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
          if (payment.transactionId != null && payment.transactionId!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Mã GD: ${payment.transactionId}', style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
          ],

          if (isPending || isSuccess) ...[
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isPending && onConfirm != null)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    onPressed: onConfirm,
                    child: const Text('XÁC NHẬN THU', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                if (isSuccess && onRefund != null)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                    onPressed: onRefund,
                    child: const Text('HOÀN TIỀN'),
                  ),
              ],
            )
          ]
        ],
      ),
    );
  }
}