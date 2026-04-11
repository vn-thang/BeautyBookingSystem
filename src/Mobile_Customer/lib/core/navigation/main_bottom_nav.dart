// // lib/core/navigation/main_bottom_nav.dart
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../features/auth/presentation/bloc/auth_bloc.dart';
// import '../../features/auth/presentation/bloc/auth_state.dart';

// class MainBottomNav extends StatelessWidget {
//   const MainBottomNav({super.key});

//   static const Color _pink1 = Color(0xFFFF5C8A);

//   @override
//   Widget build(BuildContext context) {
//     final location = GoRouterState.of(context).uri.toString();

//     int index = 0;
//     if (location.startsWith('/booking')) index = 1;
//     if (location.startsWith('/chat')) index = 2;
//     if (location.startsWith('/notification')) index = 3;
//     if (location.startsWith('/profile')) index = 4;

//     Widget _softIcon(IconData icon, bool active) {
//       return Container(
//         padding: const EdgeInsets.all(6), 
//         decoration: BoxDecoration(
//           color: active ? _pink1.withOpacity(0.1) : Colors.transparent,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Icon(
//           icon,
//           size: 20, 
//           color: active ? _pink1 : Colors.grey[700],
//         ),
//       );
//     }

//     return Padding(
//       padding: const EdgeInsets.fromLTRB(12, 6, 12, 10), 
//       child: PhysicalModel(
//         color: Colors.transparent,
//         elevation: 10,
//         borderRadius: BorderRadius.circular(18),
//         shadowColor: Colors.black26,
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(18),
//           child: Container(
//             height: 64, 
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(18),
//               border: Border.all(color: Colors.grey.withOpacity(0.08)),
//             ),
//             child: BottomNavigationBar(
//               type: BottomNavigationBarType.fixed,
//               backgroundColor: Colors.transparent,
//               elevation: 0,
//               currentIndex: index,

//               selectedItemColor: _pink1,
//               unselectedItemColor: Colors.grey[600],

//               iconSize: 20, 
//               selectedFontSize: 10, 
//               unselectedFontSize: 10,

//               selectedLabelStyle: const TextStyle(
//                 fontSize: 10,
//                 fontWeight: FontWeight.w600,
//                 height: 1.1, 
//               ),
//               unselectedLabelStyle: const TextStyle(
//                 fontSize: 10,
//                 height: 1.1,
//               ),

//               onTap: (i) {
//                 switch (i) {
//                   case 0:
//                     context.go('/');
//                     break;
//                   case 1:
//                     context.go('/booking');
//                     break;
//                   case 2:
//                     final isLoggedIn =
//                         context.read<AuthBloc>().state is AuthAuthenticated;
//                     if (isLoggedIn) {
//                       context.go('/chat');
//                     } else {
//                       context.go('/login', extra: '/chat');
//                     }
//                     break;
//                   case 3:
//                     final isLoggedIn =
//                         context.read<AuthBloc>().state is AuthAuthenticated;
//                     if (isLoggedIn) {
//                       context.go('/notification');
//                     } else {
//                       context.go('/login', extra: '/notification');
//                     }
//                     break;
//                   case 4:
//                     context.go('/profile');
//                     break;
//                 }
//               },

//               items: [
//                 BottomNavigationBarItem(
//                   icon: _softIcon(Icons.home_outlined, index == 0),
//                   activeIcon: _softIcon(Icons.home_rounded, index == 0),
//                   label: 'Trang chủ',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: _softIcon(Icons.calendar_today_outlined, index == 1),
//                   activeIcon: _softIcon(Icons.calendar_today_rounded, index == 1),
//                   label: 'Lịch hẹn',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: _softIcon(Icons.chat_bubble_outline, index == 2),
//                   activeIcon: _softIcon(Icons.chat_bubble, index == 2),
//                   label: 'Chat',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: _softIcon(Icons.notifications_none, index == 3),
//                   activeIcon: _softIcon(Icons.notifications, index == 3),
//                   label: 'Thông báo',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: _softIcon(Icons.person_outline, index == 4),
//                   activeIcon: _softIcon(Icons.person, index == 4),
//                   label: 'Tài khoản',
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


// lib/core/navigation/main_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_customer/injection/service_locator.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/notification/presentation/bloc/notification_bloc.dart';
import '../../features/notification/presentation/bloc/notification_event.dart';
import '../../features/notification/presentation/bloc/notification_state.dart';

class MainBottomNav extends StatefulWidget {
  const MainBottomNav({super.key});

  @override
  State<MainBottomNav> createState() => _MainBottomNavState();
}

class _MainBottomNavState extends State<MainBottomNav> {
  static const Color _pink1 = Color(0xFFFF5C8A);
  
  // Khai báo biến để giữ duy nhất 1 instance của Bloc
  late final NotificationBloc _notificationBloc;

  @override
  void initState() {
    super.initState();
    // Lấy Bloc từ sl ngay từ đầu
    _notificationBloc = sl<NotificationBloc>();
    
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      // Gọi lấy dữ liệu ngay khi app load
      _notificationBloc.add(LoadNotifications(pageIndex: 1, pageSize: 50));
    }
  }

  Widget _softIcon(IconData icon, bool active, {int badgeCount = 0}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: active ? _pink1.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 22, // Tăng nhẹ size icon cho đẹp
            color: active ? _pink1 : Colors.grey[700],
          ),
        ),
        
        // HIỂN THỊ BADGE GIỐNG ẢNH MẪU
        if (badgeCount > 0)
          Positioned(
            top: -4, // Đẩy lên cao hơn icon một chút
            right: -4, // Đẩy sang phải một chút
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white, // Viền trắng bao quanh
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFE92323), // Màu đỏ rực rỡ như ảnh mẫu
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    badgeCount > 9 ? '9+' : '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    int index = 0;
    if (location.startsWith('/booking')) index = 1;
    if (location.startsWith('/chat')) index = 2;
    if (location.startsWith('/notification')) index = 3;
    if (location.startsWith('/profile')) index = 4;

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
              border: Border.all(color: Colors.grey.withValues(alpha: 0.08)),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex: index,
              selectedItemColor: _pink1,
              unselectedItemColor: Colors.grey[600],
              selectedFontSize: 10,
              unselectedFontSize: 10,
              onTap: (i) {
                switch (i) {
                  case 0: context.go('/'); break;
                  case 1: context.go('/booking'); break;
                  case 2:
                    if (context.read<AuthBloc>().state is AuthAuthenticated) {
                      context.go('/chat');
                    } else {
                      context.go('/login', extra: '/chat');
                    }
                    break;
                  case 3:
                    if (context.read<AuthBloc>().state is AuthAuthenticated) {
                      context.go('/notification');
                    } else {
                      context.go('/login', extra: '/notification');
                    }
                    break;
                  case 4: context.go('/profile'); break;
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
                
                // MỤC THÔNG BÁO CÓ SỐ ĐẾM
                BottomNavigationBarItem(
                  icon: BlocBuilder<NotificationBloc, NotificationState>(
                    bloc: _notificationBloc, // Dùng instance duy nhất đã lấy ở initState
                    builder: (context, state) {
                      int unread = 0;
                      if (state is NotificationLoaded) {
                        unread = state.unreadCount;
                      }
                      return _softIcon(Icons.notifications_none, index == 3, badgeCount: unread);
                    },
                  ),
                  activeIcon: BlocBuilder<NotificationBloc, NotificationState>(
                    bloc: _notificationBloc,
                    builder: (context, state) {
                      int unread = 0;
                      if (state is NotificationLoaded) {
                        unread = state.unreadCount;
                      }
                      return _softIcon(Icons.notifications, index == 3, badgeCount: unread);
                    },
                  ),
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