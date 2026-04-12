import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/screens/custom_webview_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_text_styles.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppDecorations.pageGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
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
                      "Cài đặt",
                      style: AppTextStyles.sectionTitle,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _menuTile(
                  icon: Icons.lock_outline_rounded,
                  title: "Đổi mật khẩu",
                  subtitle: "Cập nhật mật khẩu đăng nhập",
                  onTap: () => context.push('/settings/change-password'),
                ),
                const SizedBox(height: 12),
                _menuTile(
                  icon: Icons.privacy_tip_outlined,
                  title: "Chính sách bảo mật",
                  subtitle: "Xem chính sách bảo mật của ứng dụng",
                  onTap: () => context.push('/settings/privacy-policy'),
                ),
                const SizedBox(height: 12),
                _menuTile(
                  icon: Icons.description_outlined,
                  title: "Điều khoản sử dụng",
                  subtitle: "Mở trang điều khoản và chính sách",
                  onTap: () => _openTermsWebPage(context),
                ),
                const SizedBox(height: 12),
                _menuTile(
                  icon: Icons.support_agent_rounded,
                  title: "Liên hệ & hỗ trợ",
                  subtitle: "Gọi hotline, chat Zalo, gửi email",
                  onTap: () => context.push('/settings/contact-support'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSoft),
            boxShadow: AppDecorations.softShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 22, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
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
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
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

  void _openTermsWebPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CustomWebViewScreen(
          title: 'Điều khoản và Chính sách',
          url: 'http://localhost:5173/chinh-sach-chung',
        ),
      ),
    );
  }
}
