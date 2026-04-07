import '../../domain/entities/chat_message.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isSending;
  final bool isLoading;
  final String? sessionKey;
  final double? lat;
  final double? lon;
  final String? error;

  const ChatState({
    required this.messages,
    required this.isSending,
    required this.isLoading,
    this.sessionKey,
    this.lat,
    this.lon,
    this.error,
  });

  factory ChatState.initial() {
    return const ChatState(
      messages: [],
      isSending: false,
      isLoading: false,
      sessionKey: null,
      lat: null,
      lon: null,
      error: null,
    );
  }

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
    bool? isLoading,
    String? sessionKey,
    double? lat,
    double? lon,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      isLoading: isLoading ?? this.isLoading,
      sessionKey: sessionKey ?? this.sessionKey,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      error: error ?? this.error,
    );
  }
}
