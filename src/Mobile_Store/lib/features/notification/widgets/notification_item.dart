import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../../../core/utils/date_formatter.dart'; 

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationItem({super.key, required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      tileColor: isRead ? Colors.transparent : Colors.blue.withValues(alpha: 0.05),
      leading: CircleAvatar(
        backgroundColor: isRead ? Colors.grey.shade200 : Colors.blue.shade100,
        child: Icon(Icons.notifications, color: isRead ? Colors.grey : Colors.blue),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          color: isRead ? Colors.black87 : Colors.black,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            notification.message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: isRead ? Colors.grey.shade700 : Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormatter.formatDateTime(notification.createdAt),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}