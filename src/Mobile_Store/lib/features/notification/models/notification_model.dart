class NotificationModel {
  final int id;
  final String title;
  final String message;
  final int type;
  bool isRead; 
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 0,
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}