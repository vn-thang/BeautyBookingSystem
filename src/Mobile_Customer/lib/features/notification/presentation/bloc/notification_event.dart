abstract class NotificationEvent {}

class LoadNotifications extends NotificationEvent {
  final int pageIndex;
  final int pageSize;

  LoadNotifications({this.pageIndex = 1, this.pageSize = 20});
}

class MarkNotificationAsRead extends NotificationEvent {
  final int id;
  MarkNotificationAsRead(this.id);
}

class MarkAllNotificationsAsRead extends NotificationEvent {}