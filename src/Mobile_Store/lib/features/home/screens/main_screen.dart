import 'dart:async'; 
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart'; 
import '../../../core/theme/app_text_styles.dart'; 
import '../../../shared/widgets/dialogs/permission_dialog.dart';

import '../../dashboard/screens/store_dashboard_screen.dart';
import '../../store/screens/store_management_screen.dart';  
import '../../booking/screens/booking_management_screen.dart';  
import '../../notification/screens/notification_screen.dart';
import '../../notification/services/notification_api.dart';
import '../../../core/service/firebase_messaging_service.dart';
import 'package:permission_handler/permission_handler.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int _unreadCount = 0; 

  StreamSubscription? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _fetchUnreadCount(); 

    _checkAndRequestNotificationPermission();

    _notificationSubscription = FirebaseMessagingService.onNotificationArrived.listen((_) {
      _fetchUnreadCount(); 
    });
  }

  Future<void> _checkAndRequestNotificationPermission() async {
    var status = await Permission.notification.status;
    
    if (status.isDenied) {
      if (!mounted) return;
      
      bool isAgreed = await PermissionDialog.showCustomPrompt(
        context: context,
        icon: Icons.notifications_active_rounded,
        title: 'Đừng bỏ lỡ đơn hàng!',
        description: 'Nhận thông báo ngay lập tức khi có khách hàng đặt lịch hoặc hủy lịch tại cửa hàng của bạn.',
        confirmText: 'Bật thông báo',
      );

      if (isAgreed) {
        await FirebaseMessagingService.init();
      }
    } else if (status.isGranted) {
      await FirebaseMessagingService.init();
    }
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final count = await NotificationApi.getUnreadCount();
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    } catch (e) {
      debugPrint('Lỗi lấy số thông báo: $e');
    }
  }

  List<Widget> get _screens => [
    const StoreDashboardScreen(),
    NotificationScreen(onCountChanged: _fetchUnreadCount),
    const BookingManagementScreen(),
    const StoreManagementScreen(), 
    Container(color: Colors.white, child: const Center(child: Text('Test Store'))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    _fetchUnreadCount(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, 
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens, 
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, 
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary, 
        unselectedItemColor: AppColors.textSub, 
        selectedLabelStyle: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w500),
        elevation: 10,
        items: [
  const BottomNavigationBarItem(
    icon: Icon(Icons.space_dashboard_outlined), 
    activeIcon: Icon(Icons.space_dashboard_rounded),
    label: 'Trang chủ',
  ),
  
  BottomNavigationBarItem(
    icon: Badge(
      isLabelVisible: _unreadCount > 0, 
      backgroundColor: AppColors.error,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), 
      offset: const Offset(4, -4), 
      label: Text(
        _unreadCount > 99 ? '99+' : '$_unreadCount', 
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.white, 
          fontSize: 10, 
          fontWeight: FontWeight.bold,
          height: 1.2, 
        ), 
      ),
      child: const Icon(Icons.notifications_outlined), 
    ),
    activeIcon: Badge( 
      isLabelVisible: _unreadCount > 0,
      backgroundColor: AppColors.error,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      offset: const Offset(4, -4),
      label: Text(
        _unreadCount > 99 ? '99+' : '$_unreadCount', 
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.white, 
          fontSize: 10, 
          fontWeight: FontWeight.bold,
          height: 1.2,
        ), 
      ),
      child: const Icon(Icons.notifications_rounded),
    ),
    label: 'Thông báo',
  ),
  
  const BottomNavigationBarItem(
    icon: Icon(Icons.calendar_today_outlined),
    activeIcon: Icon(Icons.calendar_today_rounded),
    label: 'Lịch hẹn',
  ),
  const BottomNavigationBarItem(
    icon: Icon(Icons.storefront_outlined), 
    activeIcon: Icon(Icons.storefront_rounded),
    label: 'Cửa hàng',
  ),
],
      ),
    );
  }
}