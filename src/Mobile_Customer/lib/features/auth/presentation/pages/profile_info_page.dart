import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'edit_profile_page.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_text_styles.dart';

class ProfileInfoPage extends StatefulWidget {
  const ProfileInfoPage({super.key});

  @override
  State<ProfileInfoPage> createState() => _ProfileInfoPageState();
}

class _ProfileInfoPageState extends State<ProfileInfoPage> {
  bool _isSaving = false;
  int _pendingSaveSteps = 0;
  dynamic _currentUser;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthBloc>().add(CheckAuthEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        return current is AuthAuthenticated ||
            current is AuthSuccess ||
            current is AuthError;
      },
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (mounted) {
            setState(() {
              _currentUser = state.user;
            });
          }
          return;
        }

        if (state is AuthSuccess) {
          if (_pendingSaveSteps > 0) {
            _pendingSaveSteps -= 1;
          }

          if (_pendingSaveSteps <= 0) {
            if (mounted) {
              setState(() {
                _isSaving = false;
                _pendingSaveSteps = 0;
              });
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger,
              ),
            );
          }
          return;
        }

        if (state is AuthError) {
          if (mounted) {
            setState(() {
              _isSaving = false;
              _pendingSaveSteps = 0;
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      },
      builder: (context, state) {
        final user = _resolveUser(state);

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppDecorations.pageGradient,
            ),
            child: SafeArea(
              child: user == null
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : _buildContent(context, user),
            ),
          ),
        );
      },
    );
  }

  dynamic _resolveUser(AuthState state) {
    if (state is AuthAuthenticated) {
      _currentUser = state.user;
      return state.user;
    }

    return _currentUser;
  }

  Widget _buildContent(BuildContext context, dynamic user) {
    final name = _safeName(user);
    final email = _safeEmail(user);
    final phone = _safePhone(user);
    final avatarUrl = _safeAvatarUrl(user);

    return SingleChildScrollView(
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
                "Thông tin cá nhân",
                style: AppTextStyles.sectionTitle,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.borderSoft),
              boxShadow: AppDecorations.cardShadow,
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _isSaving ? null : () => _changeAvatar(context),
                  child: Stack(
                    alignment: Alignment.bottomRight,
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
                            email: email,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: AppColors.surface, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          size: 16,
                          color: AppColors.surface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "Chạm vào ảnh để đổi avatar",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _infoTile(
            icon: Icons.badge_outlined,
            label: "Họ và tên",
            value: name.isNotEmpty ? name : "Chưa cập nhật",
          ),
          const SizedBox(height: 12),
          _infoTile(
            icon: Icons.email_outlined,
            label: "Email",
            value: email.isNotEmpty ? email : "Chưa cập nhật",
          ),
          if (phone != null && phone.isNotEmpty) ...[
            const SizedBox(height: 12),
            _infoTile(
              icon: Icons.phone_outlined,
              label: "Số điện thoại",
              value: phone,
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: _actionButton(
              context,
              text: _isSaving ? "Đang lưu..." : "Chỉnh sửa thông tin",
              icon: Icons.edit_outlined,
              primary: true,
              onTap:
                  _isSaving ? () {} : () => _openEditProfilePage(context, user),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changeAvatar(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Chụp ảnh'),
                  onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Chọn từ thư viện'),
                  onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (!mounted || image == null) return;

    setState(() {
      _isSaving = true;
      _pendingSaveSteps = 1;
    });

    context.read<AuthBloc>().add(UploadAvatarEvent(image));
  }

  Future<void> _openEditProfilePage(BuildContext context, dynamic user) async {
    final result = await Navigator.push<EditProfileResult>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePage(user: user),
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      _isSaving = true;
      _pendingSaveSteps = 1;
    });

    context.read<AuthBloc>().add(
          UpdateProfileEvent(
            result.fullName.trim(),
            result.email.trim(),
            null,
          ),
        );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
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
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: primary ? AppColors.primary : AppColors.surface,
            border: Border.all(
              color: primary ? AppColors.primary : AppColors.borderSoft,
            ),
            boxShadow: AppDecorations.softShadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 19,
                color: primary
                    ? AppColors.surface
                    : danger
                        ? AppColors.danger
                        : AppColors.primary,
              ),
              const SizedBox(width: 10),
              Text(
                text,
                style: AppTextStyles.body.copyWith(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: primary
                      ? AppColors.surface
                      : danger
                          ? AppColors.danger
                          : AppColors.primary,
                ),
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
    required String email,
  }) {
    if (avatarUrl != null && avatarUrl.trim().isNotEmpty) {
      return Image.network(
        avatarUrl.trim(),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _avatarFallback(name: name, email: email),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            decoration: const BoxDecoration(
              gradient: AppDecorations.heroGradient,
            ),
            alignment: Alignment.center,
            child: const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          );
        },
      );
    }

    return _avatarFallback(name: name, email: email);
  }

  Widget _avatarFallback({required String name, required String email}) {
    final initials = _initials(name, email);
    return Container(
      decoration: const BoxDecoration(
        gradient: AppDecorations.heroGradient,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTextStyles.sectionTitle.copyWith(
          color: AppColors.primary,
          fontSize: 36,
        ),
      ),
    );
  }

  String _safeName(dynamic user) {
    try {
      final value = user.name;
      return value?.toString().trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  String _safeEmail(dynamic user) {
    try {
      final value = user.email;
      return value?.toString().trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  String? _safePhone(dynamic user) {
    try {
      final value = user.phone;
      final text = value?.toString().trim();
      if (text == null || text.isEmpty) return null;
      return text;
    } catch (_) {
      return null;
    }
  }

  String? _safeAvatarUrl(dynamic user) {
    try {
      final value = user.avatarUrl;
      final text = value?.toString().trim();
      if (text == null || text.isEmpty) return null;
      return text;
    } catch (_) {
      return null;
    }
  }

  String _initials(String name, String email) {
    final source = name.trim().isNotEmpty ? name.trim() : email.trim();
    if (source.isEmpty) return "U";

    final parts =
        source.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return source[0].toUpperCase();

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
