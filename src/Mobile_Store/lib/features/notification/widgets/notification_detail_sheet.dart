// file: lib/features/notification/widgets/notification_detail_sheet.dart
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../../../core/utils/date_formatter.dart'; 

class NotificationDetailSheet extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailSheet({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, 
        right: 20, 
        top: 24, 
        bottom: MediaQuery.of(context).padding.bottom + 20
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thanh kéo nhỏ
          Center(
            child: Container(
              width: 40, height: 5,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
            ),
          ),
          
          // Tiêu đề
          Text(notification.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          
          // Thời gian (Sử dụng DateFormatter vừa tạo)
          Text(
            DateFormatter.formatDateTime(notification.createdAt),
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const Divider(height: 30),
          
          // Nội dung chi tiết
          Flexible(
            child: SingleChildScrollView(
              child: Text(
                notification.message,
                style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Nút đóng
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}