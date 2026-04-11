import 'package:dio/dio.dart';
import '../models/chat_message_model.dart';
import '../models/send_chat_request_model.dart';
import '../models/send_chat_response_model.dart';

class ChatRemoteDataSource {
  final Dio dio;
  ChatRemoteDataSource(this.dio);

  Future<SendChatResponseModel> sendMessage(SendChatRequestModel model) async {
    final res = await dio.post(
      'chat/send',
      data: model.toJson(),
    );

    return SendChatResponseModel.fromJson(
      Map<String, dynamic>.from(res.data),
    );
  }

  Future<List<ChatMessageModel>> getHistory(String sessionKey) async {
    final res = await dio.get('chat/history/$sessionKey');

    return (res.data as List)
        .map((e) => ChatMessageModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
