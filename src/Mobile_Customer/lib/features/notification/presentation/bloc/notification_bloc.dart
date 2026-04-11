import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_notifications.dart';
import '../../domain/usecases/get_unread_count.dart';
import '../../domain/usecases/mark_as_read.dart';
import '../../domain/usecases/mark_all_as_read.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotifications getNotifications;
  final GetUnreadCount getUnreadCount;
  final MarkAsRead markAsRead;
  final MarkAllAsRead markAllAsRead;

  NotificationBloc({
    required this.getNotifications,
    required this.getUnreadCount,
    required this.markAsRead,
    required this.markAllAsRead,
  }) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationAsRead>(_onMarkAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllAsRead);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      // Gọi cả 2 API lấy danh sách và đếm số lượng chưa đọc
      final notifications = await getNotifications(
        pageIndex: event.pageIndex, 
        pageSize: event.pageSize
      );
      final unreadCount = await getUnreadCount();
      
      emit(NotificationLoaded(
        notifications: notifications, 
        unreadCount: unreadCount
      ));
    } catch (e) {
      emit(NotificationFailure(e.toString()));
    }
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await markAsRead(event.id);
      // Tải lại list sau khi đọc thành công
      add(LoadNotifications());
    } catch (e) {
      emit(NotificationFailure(e.toString()));
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationActionInProgress());
    try {
      await markAllAsRead();
      add(LoadNotifications());
    } catch (e) {
      emit(NotificationFailure(e.toString()));
    }
  }
}