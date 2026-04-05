import '../entities/chat_message.dart';

abstract class ChatRepository {
  Future<SendChatResult> sendMessage({
    String? sessionKey,
    required String message,
    double? userLat,
    double? userLng,
  });

  Future<List<ChatMessage>> getHistory(String sessionKey);
}

class SendChatResult {
  final String sessionKey;
  final String reply;

  SendChatResult({
    required this.sessionKey,
    required this.reply,
  });
}
