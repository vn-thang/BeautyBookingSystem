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
  Icons.account_balance_wallet_outlined, 
  'Sổ thu chi / Thanh toán', 
  onTap: () {
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
                      final currentStoreId = await TokenStorage.getStoreId();

                      if (!context.mounted) return;

                      if (currentStoreId == null || currentStoreId == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Không tìm thấy thông tin cửa hàng. Vui lòng đăng nhập lại!')),
                        );
                        return;
                      }

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
                          builder: (context) => const StaffManagementScreen(), 
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildListTile(
                    context, 
                    Icons.local_offer_outlined, 
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
                    Icons.rate_review_outlined, 
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
            Icons.person_outline, 
            'Quản lý tài khoản',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountMenuScreen(), 
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildListTile(
                    context,
                    Icons.group_outlined, 
                    'Quản lý khách hàng',
                    onTap: () async {
                      final currentStoreId = await TokenStorage.getStoreId();
                      if (!context.mounted) return;

                      if (currentStoreId == null || currentStoreId == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Không tìm thấy thông tin cửa hàng.')),
                        );
                        return;
                      }
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

                  const Divider(height: 1, indent: 16, endIndent: 16), 
                  _buildListTile(
                    context,
                    Icons.description_outlined,
                    'Chính sách và Điều khoản',
                    onTap: () async {
                      final Uri url = Uri.parse('https://google.com'); 
                      if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
                        debugPrint('Không thể mở link: $url');
                      }
                    },
                  ),
                   const Divider(height: 1, indent: 16, endIndent: 16), 
                  _buildListTile(
                    context,
                    Icons.support_agent_outlined, 
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
          Card(
  elevation: 0, 
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  child: ListTile( 
    leading: const Icon(Icons.logout, color: Colors.red),
    title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
    onTap: () {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Xác nhận', style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  Navigator.of(dialogContext).pop();

                  showDialog(
                    context: navigatorKey.currentContext!,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.red)),
                  );

                  await AuthService.logout(); 

                  navigatorKey.currentState!.pop();

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

  Widget _buildListTile(BuildContext context, IconData icon, String title, {VoidCallback? onTap, Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primary),
      title: Text(title, style: TextStyle(fontSize: 15, color: color ?? Colors.black87, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }
}