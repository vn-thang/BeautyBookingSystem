// chat_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/chat_input.dart';
import '../widgets/chat_list.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_decorations.dart';

class ChatPage extends StatefulWidget {
  final String? sessionKey;

  const ChatPage({
    super.key,
    this.sessionKey,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static const String _lastSessionKeyPref = 'chat_last_session_key';

  @override
  void initState() {
    super.initState();
    _bootstrapChat();
  }

  Future<void> _bootstrapChat() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSessionKey =
        widget.sessionKey ?? prefs.getString(_lastSessionKeyPref);

    if (!mounted) return;

    context.read<ChatBloc>().add(
          ChatStarted(sessionKey: savedSessionKey),
        );
  }

  Future<void> _startNewChat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastSessionKeyPref);

    if (!mounted) return;

    context.read<ChatBloc>().add(
          ChatStarted(sessionKey: null),
        );
  }

  void _handleChatLink(String href) {
    final uri = Uri.tryParse(href);
    if (uri == null) return;

    if (uri.scheme != 'beautybooking') return;

    final type = uri.host;
    final id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    if (id == null || id.isEmpty) return;

    switch (type) {
      case 'store':
        context.go('/store/$id');
        break;
      case 'service':
        context.go('/service-detail/$id');
        break;
      case 'voucher':
        context.go('/vouchers/$id');
        break;
      case 'booking':
        context.go('/booking');
        break;
      default:
        break;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderSoft),
            boxShadow: AppDecorations.softShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Bắt đầu cuộc trò chuyện',
                textAlign: TextAlign.center,
                style: AppTextStyles.sectionTitle,
              ),
              SizedBox(height: 10),
              Text(
                'Bạn có thể hỏi về cửa hàng, dịch vụ, voucher, booking, vị trí và giá.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewChatButton() {
    return SizedBox(
      width: 52,
      height: 52,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        color: AppColors.surface,
        elevation: 10,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.borderSoft),
        ),
        offset: const Offset(0, -4),
        onSelected: (value) {
          if (value == 'new_chat') {
            _startNewChat();
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem<String>(
            value: 'new_chat',
            child: Text(
              'Chat mới',
              style: AppTextStyles.body,
            ),
          ),
        ],
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderSoft),
            boxShadow: AppDecorations.softShadow,
          ),
          child: const Center(
            child: Icon(
              Icons.add_rounded,
              size: 24,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listenWhen: (previous, current) =>
          previous.sessionKey != current.sessionKey &&
          current.sessionKey != null &&
          current.sessionKey!.isNotEmpty,
      listener: (context, state) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_lastSessionKeyPref, state.sessionKey!);
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppDecorations.pageGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    boxShadow: AppDecorations.topBarShadow,
                  ),
                  child: const Text(
                    'Chat hỗ trợ AI',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.pageTitle,
                  ),
                ),
                Expanded(
                  child: BlocBuilder<ChatBloc, ChatState>(
                    builder: (context, state) {
                      return Column(
                        children: [
                          Expanded(
                            child: state.messages.isEmpty
                                ? _buildEmptyState()
                                : ChatList(
                                    messages: state.messages,
                                    onOpenLink: _handleChatLink,
                                  ),
                          ),
                          if (state.error != null)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.danger.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.danger.withValues(alpha: 0.18),
                                  ),
                                ),
                                child: Text(
                                  state.error!,
                                  style: AppTextStyles.error.copyWith(
                                    color: AppColors.danger,
                                  ),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _buildNewChatButton(),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ChatInput(
                                    isSending: state.isSending,
                                    onSend: (message) {
                                      context.read<ChatBloc>().add(
                                            ChatSendPressed(message),
                                          );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
