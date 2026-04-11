class SendChatRequestModel {
  final String? sessionKey;
  final String message;
  final double? userLat;
  final double? userLng;

  SendChatRequestModel({
    this.sessionKey,
    required this.message,
    this.userLat,
    this.userLng,
  });

  Map<String, dynamic> toJson() {
    return {
      'sessionKey': sessionKey,
      'message': message,
      'userLat': userLat,
      'userLng': userLng,
    };
  }
}
