
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_api.dart';
import '../widgets/notification_item.dart'; 
import '../widgets/notification_detail_sheet.dart'; 

class NotificationScreen extends StatefulWidget {
  final VoidCallback? onCountChanged;
  const NotificationScreen({super.key, this.onCountChanged});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isLoading = true;
  List<NotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }


  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    try {
      final data = await NotificationApi.getNotifications();
      setState(() => _notifications = data);
    } catch (e) {
      _showSnackBar(e.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleMarkAllAsRead() async {
    try {
      await NotificationApi.markAllAsRead();
      setState(() {
        for (var n in _notifications) { n.isRead = true; }
      });
      widget.onCountChanged?.call();
      _showSnackBar('Đã đánh dấu tất cả là đã đọc');
    } catch (e) {
      _showSnackBar(e.toString().replaceAll('Exception: ', ''), isError: true);
    }
  }

  Future<void> _handleTapNotification(NotificationModel notification) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => NotificationDetailSheet(notification: notification),
    );

    if (!notification.isRead) {
      try {
        await NotificationApi.markAsRead(notification.id);
        setState(() => notification.isRead = true);
        widget.onCountChanged?.call();
      } catch (e) {
        _showSnackBar(e.toString().replaceAll('Exception: ', ''), isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = _notifications.any((n) => !n.isRead);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.done_all, color: hasUnread ? Colors.blue : Colors.grey),
            tooltip: 'Đánh dấu tất cả đã đọc',
            onPressed: hasUnread ? _handleMarkAllAsRead : null,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchNotifications,
              child: _buildBody(),
            ),
    );
  }

  Widget _buildBody() {
    if (_notifications.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 200),
          Center(child: Text('Bạn không có thông báo nào.', style: TextStyle(color: Colors.grey, fontSize: 16))),
        ],
      );
    }

    return ListView.separated(
      itemCount: _notifications.length,
      separatorBuilder: (_, _) => const Divider(height: 1, thickness: 1, color: Colors.black12),
      itemBuilder: (context, index) {
        final item = _notifications[index];
        return NotificationItem(
          notification: item,
          onTap: () => _handleTapNotification(item),
        );
      },
    );
  }
}