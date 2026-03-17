import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/customer_profile_model.dart';

class ServiceHistoryCard extends StatelessWidget {
  final CustomerServiceHistoryModel history;

  const ServiceHistoryCard({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    // Format ngày hiển thị
    String displayDate = history.appointmentDate != null 
        ? dateFormat.format(history.appointmentDate!) 
        : 'Không rõ ngày';

    // Cắt bớt giây trong StartTime (từ "09:30:00" thành "09:30")
    String displayTime = history.startTime;
    if (displayTime.length >= 5) {
      displayTime = displayTime.substring(0, 5); 
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$displayTime - $displayDate',
                    style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
                Text(
                  currencyFormat.format(history.price),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            Text(
              history.serviceName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.content_cut, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  'Thợ thực hiện: ${history.staffName}',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}