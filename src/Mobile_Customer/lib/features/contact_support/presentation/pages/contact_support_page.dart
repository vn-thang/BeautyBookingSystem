import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/contact_support_bloc.dart';
import '../bloc/contact_support_event.dart';
import '../bloc/contact_support_state.dart';

class ContactSupportPage extends StatefulWidget {
  const ContactSupportPage({super.key});

  @override
  State<ContactSupportPage> createState() => _ContactSupportPageState();
}

class _ContactSupportPageState extends State<ContactSupportPage> {
  @override
  void initState() {
    super.initState();
    context.read<ContactSupportBloc>().add(LoadContactInfoEvent());
  }

  Future<void> _launchInExternalApp(BuildContext context, Uri url) async {
    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể mở ứng dụng. Vui lòng thử lại!'),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Có lỗi xảy ra hoặc thiết bị không hỗ trợ.'),
          ),
        );
      }
    }
  }

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final phone = phoneNumber.replaceAll(RegExp(r'\s+'), '').trim();
    if (phone.isEmpty || phone == 'Đang cập nhật') return;

    final Uri uri = Uri.parse('tel:$phone');
    await _launchInExternalApp(context, uri);
  }

  Future<void> _sendEmail(BuildContext context, String email) async {
    final mail = email.trim();
    if (mail.isEmpty || mail == 'Đang cập nhật') return;

    final Uri uri = Uri.parse(
      'mailto:$mail?subject=${Uri.encodeComponent('Cần hỗ trợ từ BeautyBooking')}',
    );
    await _launchInExternalApp(context, uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppDecorations.pageGradient,
        ),
        child: SafeArea(
          child: BlocBuilder<ContactSupportBloc, ContactSupportState>(
            builder: (context, state) {
              if (state is ContactSupportLoading ||
                  state is ContactSupportInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (state is ContactSupportError) {
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    context
                        .read<ContactSupportBloc>()
                        .add(LoadContactInfoEvent());
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: _buildErrorState(state.message),
                  ),
                );
              }

              if (state is! ContactSupportLoaded) {
                return const SizedBox.shrink();
              }

              final contactInfo = state.contactInfo;

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  context
                      .read<ContactSupportBloc>()
                      .add(LoadContactInfoEvent());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Liên hệ & Hỗ trợ',
                            style: AppTextStyles.sectionTitle,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildHeroCard(),
                      const SizedBox(height: 18),
                      Text(
                        'Chúng tôi có thể giúp gì cho bạn?',
                        style: AppTextStyles.pageTitle.copyWith(fontSize: 19),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Chọn một trong các phương thức bên dưới để liên hệ với đội ngũ chăm sóc khách hàng.',
                        style: AppTextStyles.bodyMuted,
                      ),
                      const SizedBox(height: 22),
                      _contactTile(
                        icon: Icons.phone_in_talk_outlined,
                        title: 'Gọi Hotline',
                        subtitle: '${contactInfo.hotline} • Phục vụ 24/7',
                        iconColor: AppColors.success,
                        onTap: () =>
                            _makePhoneCall(context, contactInfo.hotline),
                      ),
                      const SizedBox(height: 12),
                      _contactTile(
                        icon: Icons.email_outlined,
                        title: 'Gửi Email',
                        subtitle: contactInfo.email,
                        iconColor: AppColors.warning,
                        onTap: () => _sendEmail(context, contactInfo.email),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: AppDecorations.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              gradient: AppDecorations.heroGradient,
              shape: BoxShape.circle,
              boxShadow: AppDecorations.avatarShadow,
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'BeautyBooking luôn sẵn sàng hỗ trợ bạn',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Nếu có thắc mắc về tài khoản, đặt lịch hoặc thanh toán, hãy liên hệ với chúng tôi.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMuted,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderSoft),
          boxShadow: AppDecorations.cardShadow,
        ),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.danger,
                size: 36,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Không tải được thông tin hỗ trợ',
              textAlign: TextAlign.center,
              style: AppTextStyles.pageTitle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: 8),
            Text(
              'Kéo xuống để thử lại.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderSoft),
            boxShadow: AppDecorations.softShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
