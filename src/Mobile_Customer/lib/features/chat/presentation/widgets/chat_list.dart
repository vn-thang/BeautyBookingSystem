// chat_list.dart
import 'package:flutter/material.dart';

import '../../domain/entities/chat_message.dart';
import 'chat_bubble.dart';

class ChatList extends StatelessWidget {
  final List<ChatMessage> messages;
  final void Function(String href) onOpenLink;

  const ChatList({
    super.key,
    required this.messages,
    required this.onOpenLink,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];

        return ChatBubble(
          message: message,
          onOpenLink: onOpenLink,
        );
      },
    );
  }
}
