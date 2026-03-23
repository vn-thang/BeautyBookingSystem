import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFF7FB),
                Color(0xFFFFEEF5),
                Color(0xFFFFFFFF),
              ],
            ),
          ),
          child: SafeArea(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return _buildProfile(context, state.user);
                }

                if (state is AuthLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

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
                        color: Colors.white.withOpacity(0.82),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: const Color(0xFFFF6FAF).withOpacity(0.10),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEEF5),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFFFF6FAF).withOpacity(0.12),
                                  blurRadius: 22,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person_off_rounded,
                              size: 54,
                              color: Color(0xFFFF6FAF),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            "Bạn chưa đăng nhập",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4A4A4A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Vui lòng đăng nhập để xem và quản lý hồ sơ cá nhân của bạn.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => context.go("/login"),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFFF8FC1),
                                        Color(0xFFFF6FAF),
                                        Color(0xFFE85E9C),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFF6FAF)
                                            .withOpacity(0.28),
                                        blurRadius: 14,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.login_rounded,
                                          size: 19, color: Colors.white),
                                      SizedBox(width: 10),
                                      Text(
                                        "Đi đến trang đăng nhập",
                                        style: TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfile(BuildContext context, dynamic user) {
    final name = _safeName(user);
    final email = _safeEmail(user);
    final phone = _safePhone(user);
    final avatarUrl = _safeAvatarUrl(user);

    const pinkMain = Color(0xFFFF6FAF);
    const pinkDeep = Color(0xFFE85E9C);
    const pinkSoft = Color(0xFFFFEEF5);
    const textDark = Color(0xFF4A4A4A);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.82),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: pinkMain.withOpacity(0.10),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _backButton(context),
                    const Spacer(),
                    _iconCircle(
                      icon: Icons.settings_outlined,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(
                    color: pinkSoft,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: pinkMain.withOpacity(0.12),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _pickAndUploadAvatar(context),
                      child: ClipOval(
                        child: _buildAvatar(
                          avatarUrl: avatarUrl,
                          name: name,
                          email: email,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  name.isNotEmpty ? name : "Người dùng",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  email.isNotEmpty ? email : "Chưa có email",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (phone != null && phone.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4F8),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFFFD1E3)),
                    ),
                    child: Text(
                      phone,
                      style: const TextStyle(
                        color: pinkDeep,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 22),
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
                const SizedBox(height: 12),
                _infoTile(
                  icon: Icons.phone_outlined,
                  label: "Số điện thoại",
                  value: (phone != null && phone.isNotEmpty)
                      ? phone
                      : "Chưa cập nhật",
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _actionButton(
            context,
            text: "Cập nhật thông tin",
            icon: Icons.edit_outlined,
            primary: true,
            onTap: () => _showEditProfileDialog(context, user),
          ),
          const SizedBox(height: 12),
          _actionButton(
            context,
            text: "Đổi mật khẩu",
            icon: Icons.lock_outline_rounded,
            primary: false,
            onTap: () => _showChangePasswordDialog(context),
          ),
          const SizedBox(height: 12),
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
            color: const Color(0xFFFFEEF5),
            alignment: Alignment.center,
            child: const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
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
      color: const Color(0xFFFFEEF5),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: Color(0xFFFF6FAF),
        ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFDCE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4F8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFFFF6FAF), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF333333),
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
    final gradient = primary
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF8FC1),
              Color(0xFFFF6FAF),
              Color(0xFFE85E9C),
            ],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Color(0xFFFFF4F8),
            ],
          );

    final textColor = primary
        ? Colors.white
        : danger
            ? const Color(0xFFE25555)
            : const Color(0xFFE85E9C);

    final borderColor =
        danger ? const Color(0xFFFFD0D0) : const Color(0xFFFFD1E3);

    final iconColor = primary
        ? Colors.white
        : danger
            ? const Color(0xFFE25555)
            : const Color(0xFFE85E9C);

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
            gradient: gradient,
            border: Border.all(
              color: primary ? Colors.transparent : borderColor,
            ),
            boxShadow: [
              BoxShadow(
                color: primary
                    ? const Color(0xFFFF6FAF).withOpacity(0.28)
                    : Colors.black.withOpacity(0.05),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 19, color: iconColor),
              const SizedBox(width: 10),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14.5,
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

  Widget _backButton(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => context.pop(),
      child: const Padding(
        padding: EdgeInsets.all(4),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: Color(0xFFFF6FAF),
        ),
      ),
    );
  }

  Widget _iconCircle({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4F8),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFFFD1E3)),
          ),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFFE85E9C),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        backgroundColor: const Color(0xFFFFFBFD),
        title: const Text(
          "Đăng xuất",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF4A4A4A),
          ),
        ),
        content: const Text("Bạn chắc chắn muốn đăng xuất?"),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Huỷ"),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthBloc>().add(LogoutEvent());
              Navigator.pop(dialogContext);
              Future.microtask(() {
                context.go("/login");
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6FAF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text("Đăng xuất"),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final oldPass = TextEditingController();
    final newPass = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          backgroundColor: const Color(0xFFFFFBFD),
          title: const Text(
            "Đổi mật khẩu",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF4A4A4A),
            ),
          ),
          content: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogTextField(
                    controller: oldPass,
                    labelText: "Mật khẩu cũ",
                    obscureText: true,
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty) return "Vui lòng nhập mật khẩu cũ";
                      if (v.length < 6) return "Mật khẩu tối thiểu 6 ký tự";
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _dialogTextField(
                    controller: newPass,
                    labelText: "Mật khẩu mới",
                    obscureText: true,
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty) return "Vui lòng nhập mật khẩu mới";
                      if (v.length < 6) return "Mật khẩu tối thiểu 6 ký tự";
                      if (v == oldPass.text.trim()) {
                        return "Mật khẩu mới phải khác mật khẩu cũ";
                      }
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
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Huỷ"),
            ),
            ElevatedButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;

                Navigator.pop(dialogContext);
                context.read<AuthBloc>().add(
                      ChangePasswordEvent(
                        oldPass.text.trim(),
                        newPass.text.trim(),
                      ),
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6FAF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text("Xác nhận"),
            ),
          ],
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context, dynamic user) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: _safeName(user));
    final emailController = TextEditingController(text: _safeEmail(user));
    final avatarUrl = _safeAvatarUrl(user);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          backgroundColor: const Color(0xFFFFFBFD),
          title: const Text(
            "Cập nhật thông tin",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF4A4A4A),
            ),
          ),
          content: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _pickAndUploadAvatar(context),
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFFEEF5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6FAF).withOpacity(0.12),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _buildAvatar(
                          avatarUrl: avatarUrl,
                          name: _safeName(user),
                          email: _safeEmail(user),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Bấm vào ảnh để đổi avatar",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _dialogTextField(
                    controller: nameController,
                    labelText: "Tên",
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty) return "Vui lòng nhập tên";
                      if (v.length < 2) return "Tên phải có ít nhất 2 ký tự";
                      if (v.length > 60) return "Tên không được quá 60 ký tự";

                      final nameRegex = RegExp(
                        r"^[\p{L}\s'.-]+$",
                        unicode: true,
                      );
                      if (!nameRegex.hasMatch(v)) {
                        return "Tên chỉ nên chứa chữ và khoảng trắng";
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _dialogTextField(
                    controller: emailController,
                    labelText: "Email",
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.isEmpty) return "Vui lòng nhập email";

                      final emailRegex =
                          RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$');
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
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Huỷ"),
            ),
            ElevatedButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;

                Navigator.pop(dialogContext);

                context.read<AuthBloc>().add(
                      UpdateProfileEvent(
                        nameController.text.trim(),
                        emailController.text.trim(),
                        null,
                      ),
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6FAF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text("Lưu"),
            ),
          ],
        );
      },
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
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF333333),
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        errorMaxLines: 2,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFFDCE8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF6FAF), width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE85E9C), width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE85E9C), width: 1.2),
        ),
      ),
    );
  }

  Future<ImageSource?> _showImageSourceSheet(BuildContext context) async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      useRootNavigator: true,
      backgroundColor: const Color(0xFFFFFBFD),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD1E3),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text("Chụp ảnh"),
                onTap: () {
                  Navigator.pop(sheetContext, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text("Chọn từ thư viện"),
                onTap: () {
                  Navigator.pop(sheetContext, ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadAvatar(BuildContext context) async {
    final source = await _showImageSourceSheet(context);
    if (source == null) return;
    if (!context.mounted) return;

    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (image == null) return;
    if (!context.mounted) return;

    context.read<AuthBloc>().add(UploadAvatarEvent(image));
  }

  String _safeName(dynamic user) {
    try {
      final value = user.name;
      final text = value?.toString().trim() ?? '';
      return text;
    } catch (_) {
      return '';
    }
  }

  String _safeEmail(dynamic user) {
    try {
      final value = user.email;
      final text = value?.toString().trim() ?? '';
      return text;
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
