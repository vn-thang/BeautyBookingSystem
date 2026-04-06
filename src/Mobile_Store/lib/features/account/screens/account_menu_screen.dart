import 'package:flutter/material.dart';
import 'package:mobile_store/shared/widgets/inputs/app_header.dart';
import '../widgets/account_menu_item.dart';
import 'update_account_screen.dart'; 
import 'change_password_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';

class AccountMenuScreen extends StatelessWidget {
  const AccountMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'Cài đặt tài khoản'),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingMedium),
        children: [
          AccountMenuItem(
            icon: Icons.person_outline,
            title: 'Thông tin cá nhân',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountUpdateProfileScreen())),
          ),
          const Divider(height: 1, color: AppColors.surface),
          
          AccountMenuItem(
            icon: Icons.lock_outline,
            title: 'Đổi mật khẩu',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
          ),
          const Divider(height: 1, color: AppColors.surface),
        ],
      ),
    );
  }
}