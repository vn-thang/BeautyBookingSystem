import 'package:flutter/material.dart';
import 'package:mobile_store/shared/widgets/feedback/snackbar_helper.dart';
import 'package:mobile_store/shared/widgets/inputs/app_header.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../services/support_api.dart';
import '../models/contact_info_model.dart';
import '../widgets/contact_card.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  late Future<ContactInfoModel> _contactInfoFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _contactInfoFuture = SupportApi.getContactInfo();
    });
  }

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    if (phoneNumber == 'Đang cập nhật') return;
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    _launchInExternalApp(context, launchUri);
  }

  Future<void> _sendEmail(BuildContext context, String email) async {
    if (email == 'Đang cập nhật') return;
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'Cần hỗ trợ từ BeautyBooking'},
    );
    _launchInExternalApp(context, emailLaunchUri);
  }

  Future<void> _openZalo(BuildContext context, String phoneNumber) async {
    if (phoneNumber == 'Đang cập nhật') return;
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final Uri zaloUri = Uri.parse('https://zalo.me/$cleanPhone');
    
    try {
      bool launched = await launchUrl(zaloUri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(zaloUri, mode: LaunchMode.inAppBrowserView);
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarHelper.showError(context, 'Không thể kết nối tới Zalo. Vui lòng thử lại!');
      }
    }
  }

  Future<void> _launchInExternalApp(BuildContext context, Uri url) async {
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          SnackBarHelper.showError(context, 'Không thể mở ứng dụng. Vui lòng thử lại!');
        }
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarHelper.showError(context, 'Có lỗi xảy ra hoặc thiết bị không hỗ trợ.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: "Liên hệ & Hỗ trợ"),
      body: FutureBuilder<ContactInfoModel>(
        future: _contactInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          
          final contactInfo = snapshot.data ?? ContactInfoModel(hotline: '', email: '', zalo: '');

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => _loadData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(), 
              padding: const EdgeInsets.all(AppDimens.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppDimens.paddingLarge),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.support_agent_rounded, size: 80, color: AppColors.primary),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    "Chúng tôi có thể giúp gì cho bạn?",
                    style: AppTextStyles.heading1.copyWith(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    "Hãy chọn một trong các phương thức dưới đây để kết nối với đội ngũ chăm sóc khách hàng của chúng tôi.",
                    style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  ContactCard(
                    icon: Icons.phone_in_talk_outlined,
                    title: "Gọi Hotline",
                    subtitle: "${contactInfo.hotline} - Phục vụ 24/7",
                    color: AppColors.success,
                    onTap: () => _makePhoneCall(context, contactInfo.hotline),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  ContactCard(
                    icon: Icons.chat_bubble_outline,
                    title: "Chat qua Zalo",
                    subtitle: "Phản hồi nhanh chóng",
                    color: const Color(0xFF0068FF), 
                    onTap: () => _openZalo(context, contactInfo.zalo),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  ContactCard(
                    icon: Icons.email_outlined,
                    title: "Gửi Email",
                    subtitle: contactInfo.email,
                    color: AppColors.warning, 
                    onTap: () => _sendEmail(context, contactInfo.email),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}