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
  String rawDate = json['createdAt'] ?? '';
  
  DateTime parsedDate;
  if (rawDate.isNotEmpty && !rawDate.endsWith('Z') && !rawDate.contains('+')) {
    parsedDate = DateTime.parse('${rawDate}Z'); 
  } else {
    parsedDate = DateTime.parse(rawDate);
  }

  return NotificationModel(
    id: json['id'],
    title: json['title'] ?? '',
    message: json['message'] ?? '',
    type: json['type'] ?? 0,
    isRead: json['isRead'] ?? false,
    createdAt: parsedDate,
  );
}
}