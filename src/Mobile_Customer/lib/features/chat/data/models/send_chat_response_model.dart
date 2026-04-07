class SendChatResponseModel {
  final String sessionKey;
  final String reply;

  SendChatResponseModel({
    required this.sessionKey,
    required this.reply,
  });

  factory SendChatResponseModel.fromJson(Map<String, dynamic> json) {
    return SendChatResponseModel(
      sessionKey: json['sessionKey'] as String,
      reply: json['reply'] as String,
    );
  }
}
