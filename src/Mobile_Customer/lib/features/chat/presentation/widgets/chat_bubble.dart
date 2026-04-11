// chat_bubble.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../domain/entities/chat_message.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_decorations.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final void Function(String href) onOpenLink;

  const ChatBubble({
    super.key,
    required this.message,
    required this.onOpenLink,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 6),
            bottomRight: Radius.circular(isUser ? 6 : 18),
          ),
          border: isUser
              ? null
              : Border.all(
                  color: AppColors.borderSoft,
                ),
          boxShadow:
              isUser ? AppDecorations.softShadow : AppDecorations.cardShadow,
        ),
        child: isUser
            ? Text(
                message.content,
                style: AppTextStyles.body.copyWith(
                  color: Colors.white,
                  height: 1.45,
                ),
              )
            : MarkdownBody(
                data: message.content,
                selectable: true,
                onTapLink: (text, href, title) {
                  if (href != null && href.isNotEmpty) {
                    onOpenLink(href);
                  }
                },
                styleSheet: MarkdownStyleSheet(
                  p: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  a: AppTextStyles.body.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  strong: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  em: const TextStyle(
                    fontStyle: FontStyle.italic,
                  ),
                  code: const TextStyle(
                    fontSize: 13,
                    backgroundColor: AppColors.surfaceSoft,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
      ),
    );
  }
}
