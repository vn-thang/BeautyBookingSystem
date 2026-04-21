import 'package:flutter/material.dart';
import 'package:mobile_store/core/screens/custom_webview_screen.dart';
import 'package:mobile_store/features/statistics/screens/statistics_screen.dart';
import 'package:mobile_store/features/support/screens/contact_support_screen.dart';
import 'package:mobile_store/features/voucher/screens/marketing_menu_screen.dart';
import 'package:mobile_store/features/wallet/screens/store_wallet_screen.dart';
import 'package:mobile_store/shared/widgets/feedback/snackbar_helper.dart';
import 'package:mobile_store/shared/widgets/inputs/app_header.dart';
import 'update_profile_screen.dart'; 
import '../../../shared/token_storage.dart';
import '../../service/screens/service_management_screen.dart';
import '../../staff/screens/staff_management_screen.dart';
import '../../payment/screens/store_payment_screen.dart';
import '../../auth/services/auth_service.dart';
import 'package:mobile_store/features/auth/screens/login_screen.dart';
import '../../../core/constant/global_keys.dart'; 
import '../../review/screens/store_reviews_screen.dart';
import '../../account/screens/account_menu_screen.dart';
import '../../customer/screens/customer_list_screen.dart';
import '../../../core/theme/app_colors.dart'; 
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';

class StoreManagementScreen extends StatelessWidget {
  const StoreManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'Quản lý cửa hàng'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.paddingMedium),
        child: Column(
          children: [
            Card(
              elevation: 0, 
              color: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
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
                  const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.surface),
                  
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
                  const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.surface),

                  _buildListTile(
                    context, 
                    Icons.account_balance_wallet,
                    'Ví hệ thống & Hoa hồng', 
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const StoreWalletScreen()), 
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.surface),
                  
                  _buildListTile(
                    context, 
                    Icons.info_outline, 
                    'Thông tin dịch vụ',
                    onTap: () async {
                      final currentStoreId = await TokenStorage.getStoreId();

                      if (!context.mounted) return;

                      if (currentStoreId == null || currentStoreId == 0) {
                        SnackBarHelper.showError(context, 'Không tìm thấy thông tin cửa hàng. Vui lòng đăng nhập lại!');
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
                  const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.surface),

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
                  const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.surface),
                  
                  _buildListTile(
                    context, 
                    Icons.local_offer_outlined, 
                    'Khuyến mãi & Banner',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MarketingMenuScreen(), 
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.surface),
                  
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
                  const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.surface),
                  
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
                  const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.surface),
                  
                  _buildListTile(
                    context,
                    Icons.group_outlined, 
                    'Quản lý khách hàng',
                    onTap: () async {
                      final currentStoreId = await TokenStorage.getStoreId();
                      if (!context.mounted) return;

                      if (currentStoreId == null || currentStoreId == 0) {
                        SnackBarHelper.showError(context, 'Không tìm thấy thông tin cửa hàng.');
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
                  const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.surface),

                  _buildListTile(
                    context,
                    Icons.bar_chart_rounded, 
                    'Báo cáo thống kê',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StoreStatisticsScreen(), 
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.surface), 
                  _buildListTile(
                      context,
                      Icons.description_outlined,
                      ' Điều khoản sử dụng và Chính sách bảo mật',
                      onTap: () { 
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CustomWebViewScreen(
                              title: 'Chính sách và Điều khoản',
                              url: 'http://localhost:5173/chinh-sach-chung', 
                            ),
                          ),
                        );
                      },
                    ),
                  const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.surface), 
                  
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
            
            const SizedBox(height: AppDimens.paddingLarge),
            Card(
              elevation: 0, 
              color: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
              child: ListTile( 
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: Text('Đăng xuất', style: AppTextStyles.bodyText.copyWith(color: AppColors.error, fontWeight: FontWeight.w600)),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        backgroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusLarge)),
                        title: Text('Xác nhận', style: AppTextStyles.heading1.copyWith(fontSize: 20)),
                        content: Text('Bạn có chắc chắn muốn đăng xuất không?', style: AppTextStyles.bodyText),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: Text('Hủy', style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub, fontWeight: FontWeight.w600)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusSmall)),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              Navigator.of(dialogContext).pop();

                              showDialog(
                                context: navigatorKey.currentContext!,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(color: AppColors.error) // Màu đỏ hệ thống
                                ),
                              );

                              await AuthService.logout(); 

                              navigatorKey.currentState!.pop();

                              navigatorKey.currentState!.pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                                (route) => false,
                              );
                            },
                            child: Text('Đăng xuất', style: AppTextStyles.bodyText.copyWith(color: AppColors.white, fontWeight: FontWeight.bold)),
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
      title: Text(
        title, 
        style: AppTextStyles.bodyText.copyWith(
          fontSize: 15, 
          color: color ?? AppColors.textMain, 
          fontWeight: FontWeight.w500
        )
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSub),
      onTap: onTap,
    );
  }
}