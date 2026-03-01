import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  const AppBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFFFF5C8A),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/booking');
            break;
          case 2:
            context.go('/history');
            break;
          case 3:
            context.go('/profile');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Trang chủ"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: "Đặt lịch"),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: "Lịch sử"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Tài khoản"),
      ],
    );
  }
}