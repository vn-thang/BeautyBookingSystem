import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../injection/service_locator.dart'; 
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late final NotificationBloc _notificationBloc;

  @override
  void initState() {
    super.initState();
    _notificationBloc = sl<NotificationBloc>();
    
    _notificationBloc.add(LoadNotifications(pageIndex: 1, pageSize: 50)); 
  }

  @override
  void dispose() {
    super.dispose();
  }

String _formatDate(DateTime? date) {
  if (date == null) return '--:--';

  return DateFormat(
    'HH:mm • dd/MM/yyyy',
  ).format(date);
}

  void _onNotificationTap(NotificationEntity notif) {
 
    if (!notif.isRead) {
      _notificationBloc.add(MarkNotificationAsRead(notif.id));
    }
    
    _showNotificationDetailBottomSheet(notif);
  }

  void _showNotificationDetailBottomSheet(NotificationEntity notif) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, 
      isScrollControlled: true, 
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.event_note_rounded, 
                      color: AppColors.primary, 
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notif.title,
                            style: AppTextStyles.caption.copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(notif.createdAt),
                            style: AppTextStyles.bodyMuted.copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                const Divider(color: AppColors.borderSoft),
                const SizedBox(height: 16),
                
                Text(
                  notif.message,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 15,
                    height: 1.5, 
                  ),
                ),
                
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Đóng',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _notificationBloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          centerTitle: true,
          title: const Text('Thông báo', style: AppTextStyles.sectionTitle),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          actions: [
            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                if (state is NotificationLoaded && state.unreadCount > 0) {
                  return TextButton(
                    onPressed: () {
                      _notificationBloc.add(MarkAllNotificationsAsRead());
                    },
                    child: Text(
                      'Đọc tất cả',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            )
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (state is NotificationFailure) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(state.message, style: AppTextStyles.bodyMuted),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        onPressed: () => _notificationBloc.add(LoadNotifications(pageIndex: 1, pageSize: 50)),
                        child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                );
              }

              if (state is NotificationLoaded) {
                final notifications = state.notifications;

                if (notifications.isEmpty) {
                  return const Center(
                    child: Text(
                      'Bạn chưa có thông báo nào.',
                      style: AppTextStyles.bodyMuted,
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    _notificationBloc.add(LoadNotifications(pageIndex: 1, pageSize: 50));
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.borderSoft,
                    ),
                    itemBuilder: (context, index) {
                      final notif = notifications[index];
                      return _buildNotificationItem(notif);
                    },
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationEntity notif) {
    final bgColor = notif.isRead 
        ? AppColors.surface 
        : AppColors.primary.withValues(alpha: 0.05);

    return Material(
      color: bgColor,
      child: InkWell(
        onTap: () => _onNotificationTap(notif),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: notif.isRead 
                      ? AppColors.surfaceSoft 
                      : AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  notif.isRead ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                  color: notif.isRead ? AppColors.textSecondary : AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notif.title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.bold,
                        color: notif.isRead ? AppColors.textPrimary : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notif.message,
                      maxLines: 2, 
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMuted.copyWith(
                        color: notif.isRead ? AppColors.textSecondary : AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(notif.createdAt),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (!notif.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}