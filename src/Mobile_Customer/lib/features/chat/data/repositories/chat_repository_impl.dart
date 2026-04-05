import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/send_chat_request_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl(this.remoteDataSource);

  @override
  Future<SendChatResult> sendMessage({
    String? sessionKey,
    required String message,
    double? userLat,
    double? userLng,
  }) async {
    final response = await remoteDataSource.sendMessage(
      SendChatRequestModel(
        sessionKey: sessionKey,
        message: message,
        userLat: userLat,
        userLng: userLng,
      ),
    );

    return SendChatResult(
      sessionKey: response.sessionKey,
      reply: response.reply,
    );
  }

  @override
  Future<List<ChatMessage>> getHistory(String sessionKey) {
    return remoteDataSource.getHistory(sessionKey);
  }
}
