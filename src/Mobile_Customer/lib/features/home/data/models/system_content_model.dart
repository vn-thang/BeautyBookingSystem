class SystemContentModel {
  final int id;
  final int type;
  final String title;
  final String content;
  final bool isActive;

  SystemContentModel({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.isActive,
  });

  factory SystemContentModel.fromJson(Map<String, dynamic> json) {
    return SystemContentModel(
      id: json['id'] ?? 0,
      type: json['type'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }
}