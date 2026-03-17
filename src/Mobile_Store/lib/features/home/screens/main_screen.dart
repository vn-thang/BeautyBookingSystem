import 'dart:async'; // THÊM DÒNG NÀY ĐỂ DÙNG STREAM
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart'; 
import '../../dashboard/screens/store_dashboard_screen.dart';
import '../../store/screens/store_management_screen.dart';  
import '../../booking/screens/booking_management_screen.dart';  
import '../../notification/screens/notification_screen.dart';
import '../../notification/services/notification_api.dart';
import '../../../core/service/firebase_messaging_service.dart';
import 'package:permission_handler/permission_handler.dart';

// 2. Import file Giao diện xin quyền dùng chung mà bạn vừa tạo
// (Lưu ý: Bạn kiểm tra lại số lượng dấu '../' cho khớp với cấu trúc thư mục thực tế của bạn nhé)
import '../../../shared/widgets/permission_dialog.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int _unreadCount = 0; // Biến lưu số lượng chưa đọc

  // THÊM: Biến giữ kết nối với Stream
  StreamSubscription? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _fetchUnreadCount(); // Lấy số lượng ngay khi mở app

    // 1. Gọi hàm kiểm tra và xin quyền thông báo (Có chứa bảng giả)
    _checkAndRequestNotificationPermission();

    // 2. Lắng nghe tín hiệu Real-time từ Firebase
    _notificationSubscription = FirebaseMessagingService.onNotificationArrived.listen((_) {
      // Khi có thông báo mới rơi xuống, tự động gọi API đếm lại!
      _fetchUnreadCount(); 
    });
  }

  Future<void> _checkAndRequestNotificationPermission() async {
    // Kiểm tra trạng thái quyền thông báo hiện tại
    var status = await Permission.notification.status;
    
    if (status.isDenied) {
      // Nếu chưa cấp quyền -> Hiện bảng xin quyền giả (Soft Prompt) do mình tự thiết kế
      if (!mounted) return;
      
      bool isAgreed = await PermissionDialog.showCustomPrompt(
        context: context,
        icon: Icons.notifications_active_rounded,
        title: 'Đừng bỏ lỡ đơn hàng!',
        description: 'Nhận thông báo ngay lập tức khi có khách hàng đặt lịch hoặc hủy lịch tại cửa hàng của bạn.',
        confirmText: 'Bật thông báo',
      );

      // Nếu user bấm "Bật thông báo" ở bảng giả -> Gọi hàm khởi tạo Firebase (Bảng xin quyền THẬT sẽ hiện ra)
      if (isAgreed) {
        await FirebaseMessagingService.init();
      }
    } else if (status.isGranted) {
      // Nếu user ĐÃ CẤP QUYỀN từ những lần mở app trước đó -> Khởi tạo Firebase âm thầm luôn
      await FirebaseMessagingService.init();
    }
    // Nếu status.isPermanentlyDenied (đã chặn vĩnh viễn) thì mình bỏ qua, không làm phiền họ nữa.
  }

  @override
  void dispose() {
    // THÊM: Hủy lắng nghe khi thoát màn hình để không bị rò rỉ bộ nhớ
    _notificationSubscription?.cancel();
    super.dispose();
  }

  // Hàm gọi API lấy số lượng chưa đọc
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

  // Dùng dạng getter (=>) thay vì gán cứng (final) để có thể truyền hàm _fetchUnreadCount xuống
  List<Widget> get _screens => [
    const StoreDashboardScreen(),
    // Truyền hàm _fetchUnreadCount vào trong màn hình Notification
    NotificationScreen(onCountChanged: _fetchUnreadCount),
    const BookingManagementScreen(),
    const StoreManagementScreen(), 
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Gọi lại API cập nhật số lượng mỗi khi chuyển tab cho chắc cú
    _fetchUnreadCount(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens, // Dùng IndexedStack để giữ nguyên trạng thái màn hình cũ
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, 
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primary, 
        unselectedItemColor: Colors.grey.shade500,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        backgroundColor: Colors.white,
        elevation: 10,
        
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Trang chủ',
          ),
          
          // ==========================================
          // ĐÂY LÀ TAB THÔNG BÁO CÓ CHỨA CHUÔNG (BADGE)
          // ==========================================
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: _unreadCount > 0, // Ẩn đi nếu count = 0
              label: Text(
                _unreadCount > 99 ? '99+' : '$_unreadCount', 
                style: const TextStyle(color: Colors.white, fontSize: 11)
              ),
              child: const Icon(Icons.notifications_none_outlined), 
            ),
            activeIcon: Badge( // Gắn cả vào activeIcon để lúc đang chọn tab vẫn hiện số
              isLabelVisible: _unreadCount > 0,
              label: Text(
                _unreadCount > 99 ? '99+' : '$_unreadCount', 
                style: const TextStyle(color: Colors.white, fontSize: 11)
              ),
              child: const Icon(Icons.notifications),
            ),
            label: 'Thông báo',
          ),
          
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Lịch hẹn',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined), 
            activeIcon: Icon(Icons.storefront),
            label: 'Cửa hàng',
          ),
        ],
      ),
    );
  }
}