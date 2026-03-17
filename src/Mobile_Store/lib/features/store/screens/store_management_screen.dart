import 'package:flutter/material.dart';
import 'package:mobile_store/features/support/screens/contact_support_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart'; 
import 'update_profile_screen.dart'; 
import '../../../shared/token_storage.dart';
import '../../service/screens/service_management_screen.dart';
import '../../staff/screens/staff_management_screen.dart';
import '../../voucher/screens/voucher_management_screen.dart';
import '../../payment/screens/store_payment_screen.dart';
import '../../auth/services/auth_service.dart';
import 'package:mobile_store/features/auth/screens/login_screen.dart';
import '../../../core/constant/global_keys.dart'; 
import '../../review/screens/store_reviews_screen.dart';
import '../../account/screens/account_menu_screen.dart';
import '../../customer/screens/customer_list_screen.dart';


class StoreManagementScreen extends StatelessWidget {
  const StoreManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quản lý cửa hàng', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Thẻ chứa các menu quản lý
            Card(
              elevation: 0, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildListTile(
                    context,
                    Icons.grid_view, 
                    'Cập nhật thông tin', 
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UpdateProfileScreen()),
                      );
                    }
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildListTile(
  context, 
  Icons.account_balance_wallet_outlined, // Icon cái ví tiền cực hợp
  'Sổ thu chi / Thanh toán', 
  onTap: () {
    // Lệnh chuyển sang màn hình StorePaymentScreen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StorePaymentScreen()),
    );
  },
),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  
                 _buildListTile(
                    context, 
                    Icons.info_outline, 
                    'Thông tin dịch vụ',
                    onTap: () async {
                      // 1. Lấy storeId động từ TokenStorage
                      final currentStoreId = await TokenStorage.getStoreId();

                      // Kiểm tra context.mounted trước khi dùng UI (bắt buộc khi dùng async/await trong Flutter)
                      if (!context.mounted) return;

                      // 2. Kiểm tra xem có lấy được storeId không
                      if (currentStoreId == null || currentStoreId == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Không tìm thấy thông tin cửa hàng. Vui lòng đăng nhập lại!')),
                        );
                        return;
                      }

                      // 3. Chuyển trang và truyền ID động vào
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServiceManagementScreen(storeId: currentStoreId),
                        ),
                      );
                    },
                  ),
                 
                  const Divider(height: 1, indent: 16, endIndent: 16),

                  _buildListTile(
                    context, 
                    Icons.people_outline, 
                    'Quản lý nhân viên',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          // Không cần truyền storeId nữa, cực kỳ nhàn!
                          builder: (context) => const StaffManagementScreen(), 
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildListTile(
                    context, 
                    Icons.local_offer_outlined, // Icon hình thẻ giảm giá
                    'Quản lý chương trình khuyến mãi',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VoucherManagementScreen(), 
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildListTile(
                    context, 
                    Icons.rate_review_outlined, // Icon hình hộp thoại đánh giá
                    'Quản lý đánh giá',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StoreReviewsScreen(), 
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildListTile(
            context,
            Icons.person_outline, // Icon hình người đại diện cho tài khoản
            'Quản lý tài khoản',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // CHÚ Ý: Xóa chữ 'const' ở đây để tránh lỗi biên dịch
                  builder: (context) => AccountMenuScreen(), 
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildListTile(
                    context,
                    Icons.group_outlined, // Icon này đẹp hơn
                    'Quản lý khách hàng',
                    onTap: () async {
                      // 1. Lấy storeId động từ TokenStorage giống y hệt phần Dịch vụ
                      final currentStoreId = await TokenStorage.getStoreId();
                      if (!context.mounted) return;

                      if (currentStoreId == null || currentStoreId == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Không tìm thấy thông tin cửa hàng.')),
                        );
                        return;
                      }

                      // 2. Chuyển trang và truyền ID lấy được vào
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerListScreen(
                            storeId: currentStoreId, 
                          ), 
                        ),
                      );
                    },
                  ),

                  const Divider(height: 1, indent: 16, endIndent: 16), // Gạch ngang phân cách
                  _buildListTile(
                    context,
                    Icons.description_outlined, // Icon tờ giấy/tài liệu hợp với chính sách
                    'Chính sách và Điều khoản',
                    onTap: () async {
                      // Nếu bạn đã tạo hàm _openTermsWebPage() ở trên rồi thì chỉ cần gọi:
                      // _openTermsWebPage();
                      
                      // Còn nếu chưa thì viết trực tiếp logic mở link vào đây luôn:
                      final Uri url = Uri.parse('https://google.com'); // Thay link Notion/Web của bạn vào đây
                      if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
                        debugPrint('Không thể mở link: $url');
                      }
                    },
                  ),
                   const Divider(height: 1, indent: 16, endIndent: 16), 
                  _buildListTile(
                    context,
                    Icons.support_agent_outlined, // Icon nhân viên hỗ trợ cực chuẩn
                    'Liên hệ & Hỗ trợ',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ContactSupportScreen(), 
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),


            // Nút đăng xuất (Tách riêng ra cho nổi bật)
          Card(
  elevation: 0, 
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  child: ListTile( // Đổi _buildListTile thành ListTile hoặc giữ nguyên hàm _buildListTile của bạn
    leading: const Icon(Icons.logout, color: Colors.red),
    title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
    onTap: () {
      // 1. Hiển thị Popup xác nhận
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Xác nhận', style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(), // Đóng popup
                child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  // Đóng popup xác nhận
                  Navigator.of(dialogContext).pop();

                  // Hiển thị Loading (dùng navigatorKey để không bị nhầm context)
                  showDialog(
                    context: navigatorKey.currentContext!,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.red)),
                  );

                  // Gọi API Đăng xuất (Thay bằng class gọi API thực tế của bạn)
                  await AuthService.logout(); 

                  // Đóng cái Loading Dialog
                  navigatorKey.currentState!.pop();

                  // Đẩy về trang Login và xóa sạch lịch sử các trang trước đó
                  navigatorKey.currentState!.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
                child: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    }
  )
)
          ],
        ),
      ),
    );
  }

  // Hàm build giao diện từng dòng
  Widget _buildListTile(BuildContext context, IconData icon, String title, {VoidCallback? onTap, Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primary),
      title: Text(title, style: TextStyle(fontSize: 15, color: color ?? Colors.black87, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }
}