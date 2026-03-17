// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../models/voucher_model.dart';

// class VoucherTile extends StatelessWidget {
//   final VoucherModel voucher;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;

//   const VoucherTile({super.key, required this.voucher, required this.onEdit, required this.onDelete});

//   @override
//   Widget build(BuildContext context) {
//     Color statusColor;
//     if (voucher.status == 'Đang diễn ra') {statusColor = Colors.green;}
//     else if (voucher.status == 'Sắp diễn ra') {statusColor = Colors.orange;}
//     else {statusColor = Colors.grey;}

//     final formatter = NumberFormat('#,###');
//     final discountText = voucher.discountType == 0 
//         ? '${formatter.format(voucher.discountValue)}đ' 
//         : '${voucher.discountValue}%';

//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                   decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
//                   child: Text(voucher.code, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16)),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
//                   child: Text(voucher.status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Text('Giảm $discountText (Tối đa ${formatter.format(voucher.maxDiscount)}đ)', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
//             const SizedBox(height: 4),
//             Text('Đơn tối thiểu: ${formatter.format(voucher.minOrderValue)}đ', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
//             const SizedBox(height: 4),
//             Text('HSD: ${DateFormat('dd/MM/yyyy HH:mm').format(voucher.endDate)}', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('Đã dùng: ${voucher.usedCount} / ${voucher.usageLimit}', style: const TextStyle(fontWeight: FontWeight.w500)),
//                 Row(
//                   children: [
//                     IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 20), onPressed: onEdit, constraints: const BoxConstraints()),
//                     const SizedBox(width: 8),
//                     IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: onDelete, constraints: const BoxConstraints()),
//                   ],
//                 )
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/voucher_model.dart';

class VoucherTile extends StatelessWidget {
  final VoucherModel voucher;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const VoucherTile({super.key, required this.voucher, required this.onEdit, required this.onDelete});

  Color _getStatusColor() {
    switch (voucher.status) {
      case 'Đang diễn ra': return Colors.green;
      case 'Sắp diễn ra': return Colors.orange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final formatter = NumberFormat('#,###');
    
    final discountText = voucher.discountType == 0 
        ? '${formatter.format(voucher.discountValue)}đ' 
        : '${voucher.discountValue.toStringAsFixed(0)}%';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Text(voucher.code, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(voucher.status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Giảm $discountText (Tối đa ${formatter.format(voucher.maxDiscount)}đ)', 
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)
            ),
            const SizedBox(height: 4),
            Text('Đơn tối thiểu: ${formatter.format(voucher.minOrderValue)}đ', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
            const SizedBox(height: 4),
            Text('HSD: ${DateFormat('dd/MM/yyyy HH:mm').format(voucher.endDate)}', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Đã dùng: ${voucher.usedCount} / ${voucher.usageLimit}', style: const TextStyle(fontWeight: FontWeight.w500)),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 20), onPressed: onEdit, constraints: const BoxConstraints()),
                    const SizedBox(width: 8),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: onDelete, constraints: const BoxConstraints()),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}