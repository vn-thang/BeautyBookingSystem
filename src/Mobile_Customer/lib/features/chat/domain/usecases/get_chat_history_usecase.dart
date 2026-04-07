import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class GetChatHistoryUseCase {
  final ChatRepository repository;

  GetChatHistoryUseCase(this.repository);

  Future<List<ChatMessage>> call(String sessionKey) {
    return repository.getHistory(sessionKey);
  }
}
