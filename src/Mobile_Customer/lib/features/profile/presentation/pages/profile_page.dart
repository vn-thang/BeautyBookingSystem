import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tài khoản")),
      body: const Center(child: Text("Thông tin tài khoản")),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}