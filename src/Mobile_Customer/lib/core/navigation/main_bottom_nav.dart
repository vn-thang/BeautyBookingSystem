// lib/core/navigation/main_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';

class MainBottomNav extends StatelessWidget {
  const MainBottomNav({super.key});

  static const Color _pink1 = Color(0xFFFF5C8A);

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    int index = 0;
    if (location.startsWith('/booking')) index = 1;
    if (location.startsWith('/chat')) index = 2;
    if (location.startsWith('/notification')) index = 3;
    if (location.startsWith('/profile')) index = 4;

    Widget _softIcon(IconData icon, bool active) {
      return Container(
        padding: const EdgeInsets.all(6), 
        decoration: BoxDecoration(
          color: active ? _pink1.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20, 
          color: active ? _pink1 : Colors.grey[700],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10), 
      child: PhysicalModel(
        color: Colors.transparent,
        elevation: 10,
        borderRadius: BorderRadius.circular(18),
        shadowColor: Colors.black26,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 64, 
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.withOpacity(0.08)),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex: index,

              selectedItemColor: _pink1,
              unselectedItemColor: Colors.grey[600],

              iconSize: 20, 
              selectedFontSize: 10, 
              unselectedFontSize: 10,

              selectedLabelStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                height: 1.1, 
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 10,
                height: 1.1,
              ),

              onTap: (i) {
                switch (i) {
                  case 0:
                    context.go('/');
                    break;
                  case 1:
                    context.go('/booking');
                    break;
                  case 2:
                    final isLoggedIn =
                        context.read<AuthBloc>().state is AuthAuthenticated;
                    if (isLoggedIn) {
                      context.go('/chat');
                    } else {
                      context.go('/login', extra: '/chat');
                    }
                    break;
                  case 3:
                    final isLoggedIn =
                        context.read<AuthBloc>().state is AuthAuthenticated;
                    if (isLoggedIn) {
                      context.go('/notification');
                    } else {
                      context.go('/login', extra: '/notification');
                    }
                    break;
                  case 4:
                    context.go('/profile');
                    break;
                }
              },

              items: [
                BottomNavigationBarItem(
                  icon: _softIcon(Icons.home_outlined, index == 0),
                  activeIcon: _softIcon(Icons.home_rounded, index == 0),
                  label: 'Trang chủ',
                ),
                BottomNavigationBarItem(
                  icon: _softIcon(Icons.calendar_today_outlined, index == 1),
                  activeIcon: _softIcon(Icons.calendar_today_rounded, index == 1),
                  label: 'Lịch hẹn',
                ),
                BottomNavigationBarItem(
                  icon: _softIcon(Icons.chat_bubble_outline, index == 2),
                  activeIcon: _softIcon(Icons.chat_bubble, index == 2),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: _softIcon(Icons.notifications_none, index == 3),
                  activeIcon: _softIcon(Icons.notifications, index == 3),
                  label: 'Thông báo',
                ),
                BottomNavigationBarItem(
                  icon: _softIcon(Icons.person_outline, index == 4),
                  activeIcon: _softIcon(Icons.person, index == 4),
                  label: 'Tài khoản',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}