import '../repositories/chat_repository.dart';

class SendChatMessageUseCase {
  final ChatRepository repository;

  SendChatMessageUseCase(this.repository);

  Future<SendChatResult> call({
    String? sessionKey,
    required String message,
  }) {
    return repository.sendMessage(
      sessionKey: sessionKey,
      message: message,
    );
  }
}
