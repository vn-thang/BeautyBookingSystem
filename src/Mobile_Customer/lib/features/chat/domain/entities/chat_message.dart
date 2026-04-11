enum ChatRole { user, assistant, system }

class ChatMessage {
  final String? id;
  final ChatRole role;
  final String content;
  final DateTime createdAt;

  const ChatMessage({
    this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  bool get isUser => role == ChatRole.user;

  bool get isAssistant => role == ChatRole.assistant;
}
