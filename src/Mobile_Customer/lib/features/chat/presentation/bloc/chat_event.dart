import '../../domain/entities/chat_message.dart';

abstract class ChatEvent {}

class ChatStarted extends ChatEvent {
  final String? sessionKey;
  ChatStarted({
    this.sessionKey,
  });
}

class ChatSendPressed extends ChatEvent {
  final String message;

  ChatSendPressed(this.message);
}

class ChatHistoryLoaded extends ChatEvent {
  final List<ChatMessage> messages;
  ChatHistoryLoaded(this.messages);
}
