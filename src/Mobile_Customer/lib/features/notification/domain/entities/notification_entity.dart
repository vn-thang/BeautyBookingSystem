class NotificationEntity {
  final int id;
  final int userId;
  final String title;
  final String message;
  final int type;
  final bool isRead;
  final DateTime createdAt;

  NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });
}