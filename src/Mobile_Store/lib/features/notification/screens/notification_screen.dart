import 'package:flutter/material.dart';
import 'package:mobile_store/features/notification/widgets/notification_detail_sheet.dart';
import 'package:mobile_store/features/notification/widgets/notification_item.dart';
import 'package:mobile_store/shared/widgets/inputs/app_header.dart';
import '../../../shared/widgets/feedback/snackbar_helper.dart';
import '../models/notification_model.dart';
import '../services/notification_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

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
      if (mounted) SnackBarHelper.showError(context, e.toString());
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
      if (mounted) SnackBarHelper.showSuccess(context, 'Đã đánh dấu tất cả là đã đọc');
    } catch (e) {
      if (mounted) SnackBarHelper.showError(context, e.toString());
    }
  }

  Future<void> _handleTapNotification(NotificationModel notification) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))
      ),
      builder: (context) => NotificationDetailSheet(notification: notification),
    );

    if (!notification.isRead) {
      try {
        await NotificationApi.markAsRead(notification.id);
        setState(() => notification.isRead = true);
        widget.onCountChanged?.call();
      } catch (e) {
        if (mounted) SnackBarHelper.showError(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = _notifications.any((n) => !n.isRead);

    return Scaffold(
      backgroundColor: AppColors.background, 
      appBar: AppHeader(
        title: 'Thông báo',
        actions: [
          IconButton(
            icon: Icon(
              Icons.done_all, 
              color: hasUnread ? AppColors.white : AppColors.white.withValues(alpha: 0.5)
            ),
            tooltip: 'Đánh dấu tất cả đã đọc',
            onPressed: hasUnread ? _handleMarkAllAsRead : null,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _fetchNotifications,
              child: _buildBody(),
            ),
    );
  }

  Widget _buildBody() {
    if (_notifications.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 200),
          Center(
            child: Column(
              children: [
                const Icon(Icons.notifications_off_outlined, size: 80, color: AppColors.surface),
                const SizedBox(height: 16),
                Text(
                  'Bạn không có thông báo nào.', 
                  style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub, fontSize: 16)
                ),
              ],
            )
          ),
        ],
      );
    }

    return ListView.separated(
      itemCount: _notifications.length,
      separatorBuilder: (_, _) => Divider(height: 1, thickness: 1, color: AppColors.textSub.withValues(alpha: 0.1)),
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