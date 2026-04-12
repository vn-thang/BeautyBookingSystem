import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

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
                backgroundColor: AppColors.surface,
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
                const SizedBox(height: 10),
                Text(
                  "Ảnh avatar sẽ thay đổi trong màn chỉnh sửa",
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Text(
                  name.isNotEmpty ? name : "Người dùng",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.pageTitle,
                ),
                const SizedBox(height: 6),
                Text(
                  email.isNotEmpty ? email : "Chưa có email",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMuted,
                ),
                if (phone != null && phone.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSoft,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.borderSoft),
                    ),
                    child: Text(
                      phone,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
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
              onTap: _isSaving
                  ? () {}
                  : () => _showEditProfileDialog(context, user),
            ),
          ),
        ],
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

  Future<void> _showEditProfileDialog(
      BuildContext context, dynamic user) async {
    final result = await showDialog<_EditProfileResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _EditProfileDialog(
          user: user,
        );
      },
    );

    if (!mounted || result == null) return;

    setState(() {
      _isSaving = true;
      _pendingSaveSteps = result.selectedAvatar != null ? 2 : 1;
    });

    final bloc = context.read<AuthBloc>();

    bloc.add(
      UpdateProfileEvent(
        result.fullName.trim(),
        result.email.trim(),
        null,
      ),
    );

    if (result.selectedAvatar != null) {
      bloc.add(
        UploadAvatarEvent(result.selectedAvatar!),
      );
    }
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

class _EditProfileResult {
  final String fullName;
  final String email;
  final XFile? selectedAvatar;

  const _EditProfileResult({
    required this.fullName,
    required this.email,
    required this.selectedAvatar,
  });
}

class _EditProfileDialog extends StatefulWidget {
  final dynamic user;

  const _EditProfileDialog({
    required this.user,
  });

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  XFile? _selectedAvatar;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController(text: _safeName(widget.user));
    _emailController = TextEditingController(text: _safeEmail(widget.user));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = _safeAvatarUrl(widget.user);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      backgroundColor: AppColors.surface,
      title: const Text(
        "Cập nhật thông tin",
        style: AppTextStyles.sectionTitle,
      ),
      content: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                customBorder: const CircleBorder(),
                onTap: _chooseSource,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppDecorations.heroGradient,
                    boxShadow: AppDecorations.avatarShadow,
                  ),
                  child: ClipOval(
                    child: _selectedAvatar != null
                        ? Image.file(
                            File(_selectedAvatar!.path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : _buildAvatar(
                            avatarUrl: avatarUrl,
                            name: _safeName(widget.user),
                            email: _safeEmail(widget.user),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Bấm vào ảnh để đổi avatar",
                style: AppTextStyles.caption,
              ),
              if (_selectedAvatar != null) ...[
                const SizedBox(height: 6),
                Text(
                  "Ảnh này chỉ được lưu khi bấm Lưu",
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              _dialogTextField(
                controller: _nameController,
                labelText: "Tên",
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return "Vui lòng nhập tên";
                  if (v.length < 2) return "Tên phải có ít nhất 2 ký tự";
                  if (v.length > 60) return "Tên không được quá 60 ký tự";

                  final nameRegex = RegExp(r"^[\p{L}\s'.-]+$", unicode: true);
                  if (!nameRegex.hasMatch(v)) {
                    return "Tên chỉ nên chứa chữ và khoảng trắng";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _dialogTextField(
                controller: _emailController,
                labelText: "Email",
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return "Vui lòng nhập email";

                  final emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$');
                  if (!emailRegex.hasMatch(v)) return "Email không hợp lệ";

                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Huỷ"),
        ),
        ElevatedButton(
          onPressed: _onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text("Lưu"),
        ),
      ],
    );
  }

  Future<void> _chooseSource() async {
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
      _selectedAvatar = image;
    });
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    Navigator.pop(
      context,
      _EditProfileResult(
        fullName: _nameController.text,
        email: _emailController.text,
        selectedAvatar: _selectedAvatar,
      ),
    );
  }

  Widget _dialogTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTextStyles.body.copyWith(
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: AppTextStyles.bodyMuted,
        filled: true,
        fillColor: AppColors.surfaceSoft,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        errorMaxLines: 2,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.borderSoft),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppColors.primary, width: 1.2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppColors.danger, width: 1.2),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppColors.danger, width: 1.2),
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
