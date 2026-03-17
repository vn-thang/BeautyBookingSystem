import 'package:flutter/material.dart';
import '../widgets/account_menu_item.dart';
import 'update_account_screen.dart'; // Đã sửa tên file import cho khớp class bên dưới
import 'change_password_screen.dart';
import '../../../core/theme/app_colors.dart';

class AccountMenuScreen extends StatelessWidget {
  const AccountMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Cài đặt tài khoản',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary, // Màu nền đỏ/hồng
        foregroundColor: AppColors.background, // Chữ trắng
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          AccountMenuItem(
            icon: Icons.person_outline,
            title: 'Thông tin cá nhân',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountUpdateProfileScreen())),
          ),
          const Divider(height: 1),
          AccountMenuItem(
            icon: Icons.lock_outline,
            title: 'Đổi mật khẩu',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
          ),
          const Divider(height: 1),
          const SizedBox(height: 24),
          
        ],
      ),
    );
  }
}