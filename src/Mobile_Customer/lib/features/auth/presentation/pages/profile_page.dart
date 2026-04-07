import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_text_styles.dart';

import '../../../home/data/datasources/home_remote_datasource.dart';
import '../../../home/domain/entities/favorite_service.dart';
import '../../../home/domain/entities/favorite_store.dart';

class ProfilePage extends StatelessWidget {
  final HomeRemoteDataSource homeRemoteDataSource;

  const ProfilePage({
    super.key,
    required this.homeRemoteDataSource,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.surface,
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
                          Text(
                            "Bạn chưa đăng nhập",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.pageTitle,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Vui lòng đăng nhập để xem và quản lý hồ sơ cá nhân của bạn.",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMuted,
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            child: _actionButton(
                              context,
                              text: "Đi đến trang đăng nhập",
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
              },
            ),
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
          _profileHeader(context, user),
          const SizedBox(height: 18),
          _sectionTitle("Hồ sơ"),
          _menuTile(
            icon: Icons.person_outline_rounded,
            title: "Thông tin cá nhân",
            subtitle: "Xem và chỉnh sửa hồ sơ của bạn",
            onTap: () => _showProfileBottomSheet(context, user),
          ),
          const SizedBox(height: 18),
          _sectionTitle("Yêu thích"),
          _menuTile(
            icon: Icons.favorite_border_rounded,
            title: "Danh sách yêu thích",
            subtitle: "Xem cửa hàng và dịch vụ đã lưu",
            onTap: () => _showFavoritesBottomSheet(context),
          ),
          const SizedBox(height: 18),
          _sectionTitle("Cài đặt"),
          _menuTile(
            icon: Icons.lock_outline_rounded,
            title: "Đổi mật khẩu",
            onTap: () => _showChangePasswordDialog(context),
          ),
          const SizedBox(height: 10),
          _menuTile(
            icon: Icons.privacy_tip_outlined,
            title: "Chính sách về quyền riêng tư",
            onTap: () => _showInfoSheet(
              context,
              title: "Chính sách về quyền riêng tư",
              content:
                  "Đây là nơi bạn đặt nội dung chính sách quyền riêng tư của ứng dụng.",
            ),
          ),
          const SizedBox(height: 10),
          _menuTile(
            icon: Icons.description_outlined,
            title: "Điều khoản dịch vụ",
            onTap: () => _showInfoSheet(
              context,
              title: "Điều khoản dịch vụ",
              content:
                  "Đây là nơi bạn đặt nội dung điều khoản dịch vụ của ứng dụng.",
            ),
          ),
          const SizedBox(height: 10),
          _menuTile(
            icon: Icons.rule_outlined,
            title: "Điều khoản sử dụng",
            onTap: () => _showInfoSheet(
              context,
              title: "Điều khoản sử dụng",
              content:
                  "Đây là nơi bạn đặt nội dung điều khoản sử dụng của ứng dụng.",
            ),
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

  Widget _profileHeader(BuildContext context, dynamic user) {
    final name = _safeName(user);
    final email = _safeEmail(user);
    final phone = _safePhone(user);
    final avatarUrl = _safeAvatarUrl(user);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: AppDecorations.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              _iconCircle(
                icon: Icons.settings_outlined,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              gradient: AppDecorations.heroGradient,
              shape: BoxShape.circle,
              boxShadow: AppDecorations.avatarShadow,
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
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10, top: 2),
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
    String? subtitle,
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

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
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

  Widget _backButton(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => context.pop(),
      child: const Padding(
        padding: EdgeInsets.all(4),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: AppColors.primary,
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
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  void _showProfileBottomSheet(BuildContext context, dynamic user) {
    final name = _safeName(user);
    final email = _safeEmail(user);
    final phone = _safePhone(user);
    final avatarUrl = _safeAvatarUrl(user);

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 96,
                  height: 96,
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
                const SizedBox(height: 16),
                Text(
                  name.isNotEmpty ? name : "Người dùng",
                  style: AppTextStyles.pageTitle,
                ),
                const SizedBox(height: 6),
                Text(
                  email.isNotEmpty ? email : "Chưa có email",
                  style: AppTextStyles.bodyMuted,
                ),
                if (phone != null && phone.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _infoTile(
                    icon: Icons.phone_outlined,
                    label: "Số điện thoại",
                    value: phone,
                  ),
                ],
                const SizedBox(height: 12),
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
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: _actionButton(
                    context,
                    text: "Chỉnh sửa thông tin",
                    icon: Icons.edit_outlined,
                    primary: true,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _showEditProfileDialog(context, user);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFavoritesBottomSheet(BuildContext context) {
    final future = _loadFavoriteData();

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return DefaultTabController(
          length: 2,
          child: FutureBuilder<_FavoriteBundle>(
            future: future,
            builder: (context, snapshot) {
              final loading =
                  snapshot.connectionState == ConnectionState.waiting;
              final error = snapshot.hasError;
              final data = snapshot.data;

              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  height: MediaQuery.of(sheetContext).size.height * 0.78,
                  child: Column(
                    children: [
                      Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.borderSoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Yêu thích",
                            style: AppTextStyles.sectionTitle,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const TabBar(
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textSecondary,
                        indicatorColor: AppColors.primary,
                        tabs: [
                          Tab(text: "Cửa hàng"),
                          Tab(text: "Dịch vụ"),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: error
                            ? _favoriteErrorState()
                            : loading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                    ),
                                  )
                                : TabBarView(
                                    children: [
                                      _favoriteStoreList(
                                        data?.stores ?? const [],
                                      ),
                                      _favoriteServiceList(
                                        data?.services ?? const [],
                                      ),
                                    ],
                                  ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _favoriteEmptyCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: AppDecorations.softShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: AppTextStyles.bodyMuted,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showInfoSheet(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderSoft,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(title, style: AppTextStyles.sectionTitle),
              ),
              const SizedBox(height: 12),
              Text(
                content,
                style: AppTextStyles.bodyMuted,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        backgroundColor: AppColors.surface,
        title: const Text(
          "Đăng xuất",
          style: AppTextStyles.sectionTitle,
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
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
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
          backgroundColor: AppColors.surface,
          title: const Text(
            "Đổi mật khẩu",
            style: AppTextStyles.sectionTitle,
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
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
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
          backgroundColor: AppColors.surface,
          title: const Text(
            "Cập nhật thông tin",
            style: AppTextStyles.sectionTitle,
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
                        gradient: AppDecorations.heroGradient,
                        boxShadow: AppDecorations.avatarShadow,
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
                    style: AppTextStyles.caption,
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

                      final nameRegex =
                          RegExp(r"^[\p{L}\s'.-]+$", unicode: true);
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

  Future<ImageSource?> _showImageSourceSheet(BuildContext context) async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      useRootNavigator: true,
      backgroundColor: AppColors.surface,
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
                  color: AppColors.borderSoft,
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

  Future<_FavoriteBundle> _loadFavoriteData() async {
    final response = await homeRemoteDataSource.getHomeFavorites();

    final storeList = (response['favoriteStores'] as List? ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .map(
          (json) => FavoriteStore(
            id: (json['id'] as num).toInt(),
            name: json['name']?.toString() ?? '',
            address: json['address']?.toString(),
            logoUrl: json['logoUrl']?.toString(),
            coverImageUrl: json['coverImageUrl']?.toString(),
            averageRating: (json['averageRating'] as num?)?.toDouble(),
            totalReviews: (json['totalReviews'] as num?)?.toInt(),
            distanceKm: (json['distanceKm'] as num?)?.toDouble(),
          ),
        )
        .toList();

    final serviceList = (response['favoriteServices'] as List? ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .map(
          (json) => FavoriteService(
            id: (json['id'] as num).toInt(),
            name: json['name']?.toString() ?? '',
            imageUrl: json['imageUrl']?.toString(),
            price: (json['price'] as num?)?.toDouble(),
            storeId: (json['storeId'] as num?)?.toInt(),
            storeName: json['storeName']?.toString(),
          ),
        )
        .toList();

    return _FavoriteBundle(
      stores: storeList,
      services: serviceList,
    );
  }

  Widget _favoriteErrorState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: _favoriteEmptyCard(
        icon: Icons.error_outline_rounded,
        title: "Không tải được dữ liệu yêu thích",
        subtitle: "Vui lòng thử lại sau.",
      ),
    );
  }

  Widget _favoriteStoreList(List<FavoriteStore> stores) {
    if (stores.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: [
          _favoriteEmptyCard(
            icon: Icons.storefront_outlined,
            title: "Chưa có cửa hàng yêu thích",
            subtitle: "Các cửa hàng bạn lưu sẽ hiển thị ở đây.",
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: stores.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = stores[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSoft),
            boxShadow: AppDecorations.softShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: item.coverImageUrl != null &&
                          item.coverImageUrl!.isNotEmpty
                      ? Image.network(
                          item.coverImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.storefront_rounded,
                            color: AppColors.primary,
                          ),
                        )
                      : const Icon(
                          Icons.storefront_rounded,
                          color: AppColors.primary,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.address ?? "Chưa có địa chỉ",
                      style: AppTextStyles.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.averageRating != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        "⭐ ${item.averageRating!.toStringAsFixed(1)}"
                        "${item.totalReviews != null ? " (${item.totalReviews})" : ""}",
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _favoriteServiceList(List<FavoriteService> services) {
    if (services.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: [
          _favoriteEmptyCard(
            icon: Icons.spa_outlined,
            title: "Chưa có dịch vụ yêu thích",
            subtitle: "Các dịch vụ bạn lưu sẽ hiển thị ở đây.",
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: services.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = services[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSoft),
            boxShadow: AppDecorations.softShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                      ? Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.spa_rounded,
                            color: AppColors.primary,
                          ),
                        )
                      : const Icon(
                          Icons.spa_rounded,
                          color: AppColors.primary,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.storeName ?? "Chưa rõ cửa hàng",
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.price != null
                          ? "${item.price!.toStringAsFixed(0)} đ"
                          : "Liên hệ",
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FavoriteBundle {
  final List<FavoriteStore> stores;
  final List<FavoriteService> services;

  const _FavoriteBundle({
    required this.stores,
    required this.services,
  });
}
