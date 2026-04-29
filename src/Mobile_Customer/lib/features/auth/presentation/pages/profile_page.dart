import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_customer/features/home/data/datasources/home_remote_datasource.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_text_styles.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required HomeRemoteDataSource homeRemoteDataSource,
  });

  Future<void> _logout(BuildContext context) async {
    try {
      await fb_auth.FirebaseAuth.instance.signOut();

      final googleSignIn = GoogleSignIn(
        serverClientId:
            '361936167810-bs47k71bsrvrcg8bt0d3780focaif9b7.apps.googleusercontent.com',
      );

      await googleSignIn.signOut();
    } catch (_) {}

    if (context.mounted) {
      context.read<AuthBloc>().add(LogoutEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
            ),
          );
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppDecorations.pageGradient,
          ),
          child: SafeArea(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return _buildProfile(context, state.user);
                }

                if (state is AuthLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                return _buildGuestView(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.borderSoft),
            boxShadow: AppDecorations.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  gradient: AppDecorations.heroGradient,
                  shape: BoxShape.circle,
                  boxShadow: AppDecorations.avatarShadow,
                ),
                child: const Icon(
                  Icons.person_off_rounded,
                  size: 54,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "Bạn chưa đăng nhập",
                textAlign: TextAlign.center,
                style: AppTextStyles.pageTitle,
              ),
              const SizedBox(height: 8),
              const Text(
                "Vui lòng đăng nhập để quản lý tài khoản của bạn.",
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: _actionButton(
                  context,
                  text: "Đi đến đăng nhập",
                  icon: Icons.login_rounded,
                  primary: true,
                  onTap: () => context.go("/login"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfile(BuildContext context, dynamic user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _profileHeader(user),
          const SizedBox(height: 18),
          _sectionTitle("Hồ sơ"),
          _menuTile(
            icon: Icons.person_outline_rounded,
            title: "Thông tin cá nhân",
            subtitle: "Xem và chỉnh sửa hồ sơ",
            onTap: () => context.push('/profile/info'),
          ),
          const SizedBox(height: 18),
          _sectionTitle("Yêu thích"),
          _menuTile(
            icon: Icons.favorite_border_rounded,
            title: "Danh sách yêu thích",
            subtitle: "Cửa hàng và dịch vụ đã lưu",
            onTap: () => context.push('/profile/favorites'),
          ),
          const SizedBox(height: 18),
          _sectionTitle("Cài đặt"),
          _menuTile(
            icon: Icons.settings_outlined,
            title: "Cài đặt",
            subtitle: "Mật khẩu, chính sách, điều khoản",
            onTap: () => context.push('/settings'),
          ),
          const SizedBox(height: 18),
          _actionButton(
            context,
            text: "Đăng xuất",
            icon: Icons.logout_rounded,
            primary: false,
            danger: true,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _profileHeader(dynamic user) {
    final name = _safeName(user);
    final avatarUrl = _safeAvatarUrl(user);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: AppDecorations.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              gradient: AppDecorations.heroGradient,
              shape: BoxShape.circle,
              boxShadow: AppDecorations.avatarShadow,
            ),
            child: ClipOval(
              child: _buildAvatar(
                avatarUrl: avatarUrl,
                name: name,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            name.isNotEmpty ? name : "Người dùng",
            textAlign: TextAlign.center,
            style: AppTextStyles.pageTitle,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
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
                child: Icon(
                  icon,
                  size: 22,
                  color: iconColor ?? AppColors.primary,
                ),
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
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption,
                    ),
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

  Widget _buildAvatar({
    required String? avatarUrl,
    required String name,
  }) {
    if (avatarUrl != null && avatarUrl.trim().isNotEmpty) {
      return Image.network(
        avatarUrl.trim(),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _avatarFallback(name),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        },
      );
    }

    return _avatarFallback(name);
  }

  Widget _avatarFallback(String name) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppDecorations.heroGradient,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(name),
        style: AppTextStyles.sectionTitle.copyWith(
          fontSize: 36,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required String text,
    required IconData icon,
    required bool primary,
    bool danger = false,
    required VoidCallback onTap,
  }) {
    final color = primary ? AppColors.primary : AppColors.surface;

    final textColor = primary
        ? AppColors.surface
        : danger
            ? AppColors.danger
            : AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 16,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: primary ? AppColors.primary : AppColors.borderSoft,
            ),
            boxShadow: AppDecorations.softShadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 19, color: textColor),
              const SizedBox(width: 10),
              Text(
                text,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          backgroundColor: AppColors.surface,
          title: const Text(
            "Đăng xuất",
            style: AppTextStyles.sectionTitle,
          ),
          content: const Text(
            "Bạn chắc chắn muốn đăng xuất?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Huỷ"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _logout(context);

                if (context.mounted) {
                  context.go("/login");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
              ),
              child: const Text("Đăng xuất"),
            ),
          ],
        );
      },
    );
  }

  String _safeName(dynamic user) {
    try {
      return user.name?.toString().trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  String? _safeAvatarUrl(dynamic user) {
    try {
      final text = user.avatarUrl?.toString().trim();

      if (text == null || text.isEmpty) return null;
      return text;
    } catch (_) {
      return null;
    }
  }

  String _initials(String name) {
    if (name.trim().isEmpty) return "U";

    final parts = name.trim().split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
