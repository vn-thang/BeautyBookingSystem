import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  NotificationModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.message,
    required super.type,
    required super.isRead,
    required super.createdAt,
  });

 factory NotificationModel.fromJson(Map<String, dynamic> json) {
  DateTime createdAt;

  try {
    String raw = json['createdAt']?.toString() ?? '';

    bool hasTimezone =
        raw.endsWith('Z') ||
        RegExp(r'[\+\-]\d{2}:\d{2}$').hasMatch(raw);

    if (hasTimezone) {
      createdAt = DateTime.parse(raw).toLocal();
    } else {
      // Ép UTC rồi convert VN
      createdAt = DateTime.parse('${raw}Z').toLocal();
    }
  } catch (_) {
    createdAt = DateTime.now();
  }

  return NotificationModel(
    id: (json['id'] as num?)?.toInt() ?? 0,
    userId: (json['userId'] as num?)?.toInt() ?? 0,
    title: json['title'] as String? ?? '',
    message: json['message'] as String? ?? '',
    type: (json['type'] as num?)?.toInt() ?? 0,
    isRead: json['isRead'] as bool? ?? false,
    createdAt: createdAt,
  );
}
}