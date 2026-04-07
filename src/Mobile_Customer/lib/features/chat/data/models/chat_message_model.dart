import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    super.id,
    required super.role,
    required super.content,
    required super.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final roleString = (json['role'] as String).toLowerCase();
    final role = switch (roleString) {
      'user' => ChatRole.user,
      'assistant' => ChatRole.assistant,
      'system' => ChatRole.system,
      _ => ChatRole.assistant,
    };

    return ChatMessageModel(
      id: json['id']?.toString(),
      role: role,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
