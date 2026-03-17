import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/store_booking_model.dart';

class BookingCard extends StatelessWidget {
  final StoreBookingListModel booking;
  final VoidCallback onTap;

  const BookingCard({super.key, required this.booking, required this.onTap});

  (String, Color) _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ('Chờ duyệt', Colors.orange);
      case 'confirmed':
        return ('Đã duyệt', Colors.blue);
      case 'completed':
        return ('Hoàn thành', Colors.green);
      case 'cancelled':
        return ('Đã hủy', Colors.red);
      default:
        return ('Không rõ', Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(booking.status);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final dateFormat = DateFormat('HH:mm • EE, dd/MM/yyyy', 'vi_VN');

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 60,
                height: 60,
                color: Colors.grey.shade100,
                child: const Icon(Icons.receipt_long, color: Colors.grey, size: 30),
              ),
            ),
            const SizedBox(width: 12),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          booking.customerName, 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '• ${statusInfo.$1}', 
                        style: TextStyle(color: statusInfo.$2, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(booking.finalPrice), 
                    style: const TextStyle(color: Color(0xFFDE4660), fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(booking.createdAt), // Ngày tạo/Ngày hẹn
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}